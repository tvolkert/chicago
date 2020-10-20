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

/// Class that allows callers to measure the size of arbitrary widgets when
/// laid out with specific constraints.
///
/// The widget surveyor creates synthetic widget trees to hold the widgets it
/// measures. This is important because if the widgets (or any widgets in their
/// subtrees) depend on any inherited widgets (e.g. [Directionality]) that they
/// assume exist in their ancestry, those assumptions may hold true when the
/// widget is rendered by the application but prove false when the widget is
/// rendered via the widget surveyor. Due to this, callers are advised to
/// either:
///
///  1. pass in widgets that don't depend on inherited widgets, or
///  1. ensure all inherited widget dependencies exist in the widget tree
///     that's passed to the widget surveyor's measure methods.
class WidgetSurveyor {
  const WidgetSurveyor();

  /// Builds a widget from the specified builder, inserts the widget into a
  /// synthetic widget tree, lays out the resulting render tree, and returns
  /// the size of the laid-out render tree.
  ///
  /// The build context that's passed to the `builder` argument will represent
  /// the root of the synthetic tree.
  ///
  /// The `constraints` argument specify the constraints that will be passed
  /// to the render tree during layout. If unspecified, the widget will be laid
  /// out unconstrained.
  Size measureBuilder(
    WidgetBuilder builder, {
    BoxConstraints constraints = const BoxConstraints(),
  }) {
    return measureWidget(Builder(builder: builder), constraints: constraints);
  }

  /// Inserts the specified widget into a synthetic widget tree, lays out the
  /// resulting render tree, and returns the size of the laid-out render tree.
  ///
  /// The `constraints` argument specify the constraints that will be passed
  /// to the render tree during layout. If unspecified, the widget will be laid
  /// out unconstrained.
  Size measureWidget(
    Widget widget, {
    BoxConstraints constraints = const BoxConstraints(),
  }) {
    PipelineOwner pipelineOwner = PipelineOwner(
      onNeedVisualUpdate: () {},
      onSemanticsOwnerCreated: () {},
      onSemanticsOwnerDisposed: () {},
    );
    pipelineOwner.rootNode = _MeasurementView();
    BuildOwner buildOwner = BuildOwner(onBuildScheduled: () {});
    RenderObjectToWidgetAdapter<RenderBox>(
      container: pipelineOwner.rootNode,
      debugShortDescription: '[root]',
      child: widget,
    ).attachToRenderTree(buildOwner);
    _MeasurementView rootView = pipelineOwner.rootNode;
    rootView.scheduleInitialLayout();
    rootView.childConstraints = constraints;
    pipelineOwner.flushLayout();
    assert(rootView.size != null);
    return rootView.size;
  }
}

class _MeasurementView extends RenderObject with RenderObjectWithChildMixin<RenderBox> {
  Size size;
  BoxConstraints childConstraints;

  @override
  void performLayout() {
    assert(child != null);
    assert(childConstraints != null);
    child.layout(childConstraints, parentUsesSize: true);
    size = child.size;
  }

  @override
  void debugAssertDoesMeetConstraints() {
    assert(false);
  }

  @override
  void performResize() {
    assert(false);
  }

  @override
  Rect get paintBounds => Rect.zero;

  @override
  Rect get semanticBounds => Rect.zero;
}
