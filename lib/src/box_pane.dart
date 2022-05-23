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

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'segment.dart';
import 'visibility_aware.dart';

class BoxPane extends MultiChildRenderObjectWidget {
  BoxPane({
    super.key,
    this.axis = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = EdgeInsets.zero,
    this.spacing = 4,
    super.children,
  });

  final Axis axis;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;
  final double spacing;

  @override
  RenderBoxPane createRenderObject(BuildContext context) {
    return RenderBoxPane(
      axis: axis,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      padding: padding,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBoxPane renderObject) {
    renderObject
      ..axis = axis
      ..mainAxisAlignment = mainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..padding = padding
      ..spacing = spacing;
  }
}

class BoxPaneParentData extends ContainerBoxParentData<RenderBox> {}

class RenderBoxPane extends RenderSegment
    with
        ContainerRenderObjectMixin<RenderBox, BoxPaneParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BoxPaneParentData> {
  RenderBoxPane({
    Axis axis = Axis.horizontal,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    EdgeInsets padding = EdgeInsets.zero,
    double spacing = 4,
  })  : _axis = axis,
        _mainAxisAlignment = mainAxisAlignment,
        _crossAxisAlignment = crossAxisAlignment,
        _padding = padding,
        _spacing = spacing;

  Axis _axis;
  Axis get axis => _axis;
  set axis(Axis value) {
    if (value != _axis) {
      _axis = value;
      markNeedsLayout();
    }
  }

  MainAxisAlignment _mainAxisAlignment;
  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (value != _mainAxisAlignment) {
      _mainAxisAlignment = value;
      markNeedsLayout();
    }
  }

  CrossAxisAlignment _crossAxisAlignment;
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (value != _crossAxisAlignment) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  EdgeInsets _padding;
  EdgeInsets get padding => _padding;
  set padding(EdgeInsets value) {
    if (value != _padding) {
      _padding = value;
      markNeedsLayout();
    }
  }

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    if (value != _spacing) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  double _getCrossSize(Size size) {
    switch (_axis) {
      case Axis.horizontal:
        return size.height;
      case Axis.vertical:
        return size.width;
    }
  }

  double _getMainSize(Size size) {
    switch (_axis) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  Size _getSize(double mainSize, double crossSize) {
    switch (_axis) {
      case Axis.horizontal:
        return Size(mainSize, crossSize);
      case Axis.vertical:
        return Size(crossSize, mainSize);
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxPaneParentData) {
      child.parentData = BoxPaneParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  void performLayout() {
    final BoxConstraints paddedConstraints = constraints.deflate(padding);
    double crossSize = 0;
    double mainSize = 0;
    int childCount = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      childCount++;
      final BoxPaneParentData childParentData =
          child.parentData! as BoxPaneParentData;
      final BoxConstraints innerConstraints;
      if (crossAxisAlignment == CrossAxisAlignment.stretch) {
        switch (axis) {
          case Axis.horizontal:
            innerConstraints =
                BoxConstraints.tightFor(height: paddedConstraints.maxHeight);
            break;
          case Axis.vertical:
            innerConstraints =
                BoxConstraints.tightFor(width: paddedConstraints.maxWidth);
            break;
        }
      } else {
        switch (axis) {
          case Axis.horizontal:
            innerConstraints =
                BoxConstraints(maxHeight: paddedConstraints.maxHeight);
            break;
          case Axis.vertical:
            innerConstraints =
                BoxConstraints(maxWidth: paddedConstraints.maxWidth);
            break;
        }
      }
      child.layout(innerConstraints, parentUsesSize: true);
      final Size childSize = child.size;
      mainSize += _getMainSize(childSize);
      crossSize = math.max(crossSize, _getCrossSize(childSize));
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    mainSize += math.max(childCount - 1, 0) * spacing;
    size = constraints
        .constrain(padding.inflateSize(_getSize(mainSize, crossSize)));

    child = firstChild;
    double mainOffset;
    double crossPadding;
    switch (axis) {
      case Axis.horizontal:
        mainOffset = padding.left;
        crossPadding = padding.top;
        break;
      case Axis.vertical:
        mainOffset = padding.top;
        crossPadding = padding.left;
        break;
    }
    while (child != null) {
      final BoxPaneParentData childParentData =
          child.parentData! as BoxPaneParentData;
      switch (axis) {
        case Axis.horizontal:
          double dx = mainOffset;
          switch (mainAxisAlignment) {
            case MainAxisAlignment.start:
              // Existing dx is correct
              break;
            case MainAxisAlignment.center:
              dx =
                  mainOffset + (size.width - mainSize - padding.horizontal) / 2;
              break;
            case MainAxisAlignment.end:
              dx = mainOffset + (size.width - mainSize - padding.horizontal);
              break;
            case MainAxisAlignment.spaceAround:
            case MainAxisAlignment.spaceBetween:
            case MainAxisAlignment.spaceEvenly:
              throw UnimplementedError();
          }
          double dy = crossPadding;
          switch (crossAxisAlignment) {
            case CrossAxisAlignment.start:
            // Fallthrough
            case CrossAxisAlignment.stretch:
              // Initial value of dy is correct.
              break;
            case CrossAxisAlignment.center:
              dy = padding.top +
                  (size.height - padding.vertical - child.size.height) / 2;
              break;
            case CrossAxisAlignment.baseline:
              throw UnimplementedError();
            case CrossAxisAlignment.end:
              dy = size.height - child.size.height - padding.bottom;
              break;
          }
          childParentData.offset = Offset(dx, dy);
          mainOffset += child.size.width + spacing;
          break;
        case Axis.vertical:
          double dx = crossPadding;
          switch (crossAxisAlignment) {
            case CrossAxisAlignment.start:
            // Fallthrough
            case CrossAxisAlignment.stretch:
              // Initial value of dx is correct.
              break;
            case CrossAxisAlignment.center:
              dx = padding.left +
                  (size.width - padding.horizontal - child.size.width) / 2;
              break;
            case CrossAxisAlignment.baseline:
              assert(() {
                throw FlutterError.fromParts(<DiagnosticsNode>[
                  ErrorSummary(
                      'CrossAxisAlignment.baseline is not supported for vertical axes'),
                ]);
              }());
              // In non-debug mode, fall through to initial value of dx.
              break;
            case CrossAxisAlignment.end:
              dx = size.width - child.size.width - padding.right;
              break;
          }
          double dy = mainOffset;
          switch (mainAxisAlignment) {
            case MainAxisAlignment.start:
              // Existing dy is correct
              break;
            case MainAxisAlignment.center:
              dy = mainOffset + (size.height - mainSize - padding.vertical) / 2;
              break;
            case MainAxisAlignment.end:
              dy = mainOffset + (size.height - mainSize - padding.vertical);
              break;
            case MainAxisAlignment.spaceAround:
            case MainAxisAlignment.spaceBetween:
            case MainAxisAlignment.spaceEvenly:
              throw UnimplementedError();
          }
          childParentData.offset = Offset(dx, dy);
          mainOffset += child.size.height + spacing;
          break;
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect viewport = constraints.viewportResolver.resolve(size);
    RenderBox? child = firstChild;
    while (child != null) {
      final BoxPaneParentData childParentData =
          child.parentData! as BoxPaneParentData;
      if (viewport.overlaps(childParentData.offset & child.size)) {
        VisibilityAwareMixin.setChildVisible(child, true);
        context.paintChild(child, childParentData.offset + offset);
      } else {
        VisibilityAwareMixin.setChildVisible(child, false);
      }
      child = childParentData.nextSibling;
    }
  }
}
