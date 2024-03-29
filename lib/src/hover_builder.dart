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

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

typedef HoverWidgetBuilder = Widget Function(BuildContext context, bool hover);

class HoverBuilder extends StatefulWidget {
  const HoverBuilder({
    Key? key,
    required this.builder,
    this.cursor = MouseCursor.defer,
  }) : super(key: key);

  final HoverWidgetBuilder builder;
  final MouseCursor cursor;

  @override
  _HoverBuilderState createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) => setState(() => hover = true),
      onExit: (PointerExitEvent event) => setState(() => hover = false),
      cursor: widget.cursor,
      child: widget.builder(context, hover),
    );
  }
}
