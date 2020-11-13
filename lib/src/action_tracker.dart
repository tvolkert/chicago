// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class ActionTracker<I extends Intent> extends StatefulWidget {
  const ActionTracker({Key? key, required this.intent}) : super(key: key);

  final I intent;

  @override
  @protected
  ActionTrackerStateMixin<I, ActionTracker<I>> createState();
}

mixin ActionTrackerStateMixin<I extends Intent, T extends ActionTracker<I>> on State<T> {
  Action<I>? _action;
  bool _enabled = false;

  void _attachToAction() {
    setState(() {
      _action = Actions.find<I>(context);
      _enabled = _action!.isEnabled(widget.intent);
    });
    _action!.addActionListener(_actionUpdated as void Function(Action<Intent>));
  }

  void _detachFromAction() {
    if (_action != null) {
      _action!.removeActionListener(_actionUpdated as void Function(Action<Intent>));
      setState(() {
        _action = null;
        _enabled = false;
      });
    }
  }

  void _actionUpdated(Action<I> action) {
    setState(() {
      _enabled = action.isEnabled(widget.intent);
    });
  }

  @protected
  @nonVirtual
  bool get isEnabled => _enabled;

  @protected
  @nonVirtual
  void invokeAction() {
    assert(_action != null);
    assert(_enabled);
    assert(_action!.isEnabled(widget.intent));
    Actions.of(context).invokeAction(_action!, widget.intent, context);
  }

  @override
  @protected
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detachFromAction();
    _attachToAction();
  }
}
