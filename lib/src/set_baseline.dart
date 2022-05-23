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
import 'package:flutter/widgets.dart';

class SetBaseline extends SingleChildRenderObjectWidget {
  const SetBaseline({
    super.key,
    required Widget super.child,
    required this.baseline,
  });

  final double baseline;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSetBaseline(baseline: baseline);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSetBaseline renderObject) {
    renderObject.baseline = baseline;
  }
}

class RenderSetBaseline extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderSetBaseline({required double baseline}) {
    this.baseline = baseline;
  }

  double? _baseline;
  double get baseline => _baseline!;
  set baseline(double value) {
    if (value == _baseline) return;
    _baseline = value;
    markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return this.baseline;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return child == null ? 0 : child!.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return child == null ? 0 : child!.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return child == null ? 0 : child!.getMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return child == null ? 0 : child!.getMaxIntrinsicHeight(width);
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
    } else {
      performResize();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    return child!.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
