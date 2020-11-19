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

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Mixin that allows subclasses to defer [markNeedsLayout] calls until the
/// next transient frame callback.
///
/// See also:
///
///  * https://github.com/flutter/flutter/issues/64661, which describes when
///    this might be necessary.
mixin DeferredLayoutMixin on RenderObject {
  bool _needsLayoutDeferred = false;

  @override
  void markNeedsLayout() {
    if (!_deferMarkNeedsLayout) {
      super.markNeedsLayout();
    } else if (!_needsLayoutDeferred) {
      _needsLayoutDeferred = true;
      SchedulerBinding.instance!.scheduleFrameCallback((Duration timeStamp) {
        if (_needsLayoutDeferred) {
          _needsLayoutDeferred = false;
          super.markNeedsLayout();
        }
      });
    }
  }

  bool _deferMarkNeedsLayout = false;

  void deferMarkNeedsLayout(VoidCallback callback) {
    assert(!_deferMarkNeedsLayout);
    _deferMarkNeedsLayout = true;
    try {
      callback();
    } finally {
      _deferMarkNeedsLayout = false;
    }
  }
}
