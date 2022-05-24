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
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum SplitPaneResizePolicy {
  maintainSplitRatio,
  maintainBeforeSplitSize,
  maintainAfterSplitSize,
}

class SplitPane extends StatelessWidget {
  const SplitPane({
    super.key,
    this.orientation = Axis.horizontal,
    this.initialSplitRatio = 0.5,
    this.splitterThickness = 6,
    this.roundToWholePixel = false,
    this.resizePolicy = SplitPaneResizePolicy.maintainSplitRatio,
    required this.before,
    required this.after,
  });

  final Axis orientation;
  final double initialSplitRatio;
  final double splitterThickness;
  final bool roundToWholePixel;
  final SplitPaneResizePolicy resizePolicy;
  final Widget before;
  final Widget after;

  @override
  Widget build(BuildContext context) {
    return _RawSplitPane(
      orientation: orientation,
      initialSplitRatio: initialSplitRatio,
      splitterThickness: splitterThickness,
      roundToWholePixel: roundToWholePixel,
      resizePolicy: resizePolicy,
      before: before,
      after: after,
      splitter: _Splitter(orientation: orientation),
    );
  }
}

class _Splitter extends StatelessWidget {
  const _Splitter({required this.orientation});

  final Axis orientation;

  MouseCursor _cursorForOrientation() {
    switch (orientation) {
      case Axis.horizontal:
        return SystemMouseCursors.resizeLeftRight;
      case Axis.vertical:
        return SystemMouseCursors.resizeUpDown;
    }
  }

  GestureDragUpdateCallback _handleDrag(BuildContext context) {
    return (DragUpdateDetails details) {
      final _RenderSplitPane renderObject = context.findAncestorRenderObjectOfType<_RenderSplitPane>()!;
      renderObject._handleDrag(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    final GestureDragUpdateCallback handleDrag = _handleDrag(context);
    return MouseRegion(
      cursor: _cursorForOrientation(),
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragUpdate: orientation == Axis.horizontal ? handleDrag : null,
        onVerticalDragUpdate: orientation == Axis.vertical ? handleDrag : null,
        child: CustomPaint(
          painter: _SplitterPainter(orientation),
        ),
      ),
    );
  }
}

class _SplitterPainter extends CustomPainter {
  const _SplitterPainter(this.orientation);

  final Axis orientation;

  @override
  void paint(Canvas canvas, Size size) {
    late final double imageWidth, imageHeight;
    switch (orientation) {
      case Axis.horizontal:
        imageWidth = size.width - 4;
        imageHeight = math.min(size.height - 4, 8);
        break;
      case Axis.vertical:
        imageWidth = math.min(size.width - 4, 8);
        imageHeight = size.height - 4;
        break;
    }

    if (imageWidth > 0 && imageHeight > 0) {
      double translateX = (size.width - imageWidth) / 2;
      double translateY = (size.height - imageHeight) / 2;
      canvas.translate(translateX, translateY);

      Color dark = const Color(0xffc4c4bc);
      Color light = const Color(0xffdddcd5);

      ui.Paint paint = ui.Paint();
      switch (orientation) {
        case Axis.horizontal:
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          paint.color = dark;
          canvas.drawLine(const Offset(0, 0.5), Offset(imageWidth, 0.5), paint);
          canvas.drawLine(const Offset(0, 3.5), Offset(imageWidth, 3.5), paint);
          canvas.drawLine(const Offset(0, 6.5), Offset(imageWidth, 6.5), paint);

          paint.color = light;
          canvas.drawLine(const Offset(0, 1.5), Offset(imageWidth, 1.5), paint);
          canvas.drawLine(const Offset(0, 4.5), Offset(imageWidth, 4.5), paint);
          canvas.drawLine(const Offset(0, 7.5), Offset(imageWidth, 7.5), paint);
          break;
        case Axis.vertical:
          paint.style = PaintingStyle.fill;
          final double half = imageHeight / 2;

          paint.color = dark;
          canvas.drawRect(ui.Rect.fromLTWH(0, 0, 2, half), paint);
          canvas.drawRect(ui.Rect.fromLTWH(3, 0, 2, half), paint);
          canvas.drawRect(ui.Rect.fromLTWH(6, 0, 2, half), paint);

          paint.color = light;
          canvas.drawRect(ui.Rect.fromLTWH(0, half, 2, half), paint);
          canvas.drawRect(ui.Rect.fromLTWH(3, half, 2, half), paint);
          canvas.drawRect(ui.Rect.fromLTWH(6, half, 2, half), paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(_SplitterPainter oldDelegate) {
    return orientation != oldDelegate.orientation;
  }
}

class _RawSplitPane extends RenderObjectWidget {
  const _RawSplitPane({
    this.orientation = Axis.horizontal,
    required this.initialSplitRatio,
    required this.splitterThickness,
    required this.roundToWholePixel,
    required this.resizePolicy,
    required this.before,
    required this.after,
    required this.splitter,
  });

  final Axis orientation;
  final double initialSplitRatio;
  final double splitterThickness;
  final bool roundToWholePixel;
  final SplitPaneResizePolicy resizePolicy;
  final Widget before;
  final Widget after;
  final Widget splitter;

  @override
  RenderObjectElement createElement() => _SplitPaneElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSplitPane(
      orientation: orientation,
      splitRatio: initialSplitRatio,
      splitterThickness: splitterThickness,
      roundToWholePixel: roundToWholePixel,
      resizePolicy: resizePolicy,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSplitPane renderObject) {
    renderObject
      ..orientation = orientation
      ..splitterThickness = splitterThickness
      ..roundToWholePixel = roundToWholePixel
      ..resizePolicy = resizePolicy;
  }
}

enum _SplitPaneSlot {
  before,
  after,
  splitter,
}

class _SplitPaneElement extends RenderObjectElement {
  _SplitPaneElement(_RawSplitPane super.widget);

  Element? _before;
  Element? _after;
  Element? _splitter;

  @override
  _RawSplitPane get widget => super.widget as _RawSplitPane;

  @override
  _RenderSplitPane get renderObject => super.renderObject as _RenderSplitPane;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_before != null) visitor(_before!);
    if (_after != null) visitor(_after!);
    if (_splitter != null) visitor(_splitter!);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _before = updateChild(_before, widget.before, _SplitPaneSlot.before);
    _after = updateChild(_after, widget.after, _SplitPaneSlot.after);
    _splitter = updateChild(_splitter, widget.splitter, _SplitPaneSlot.splitter);
  }

  @override
  void insertRenderObjectChild(RenderBox child, _SplitPaneSlot slot) {
    switch (slot) {
      case _SplitPaneSlot.before:
        renderObject.before = child;
        break;
      case _SplitPaneSlot.after:
        renderObject.after = child;
        break;
      case _SplitPaneSlot.splitter:
        renderObject.splitter = child;
        break;
    }
  }

  @override
  void moveRenderObjectChild(RenderObject _, _SplitPaneSlot? __, _SplitPaneSlot? ___) {
    assert(false);
  }

  @override
  void update(RenderObjectWidget newWidget) {
    super.update(newWidget);
    _before = updateChild(_before, widget.before, _SplitPaneSlot.before);
    _after = updateChild(_after, widget.after, _SplitPaneSlot.after);
    _splitter = updateChild(_splitter, widget.splitter, _SplitPaneSlot.splitter);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _before || child == _after);
    if (child == _before) {
      _before = null;
    } else if (child == _after) {
      _after = null;
    } else if (child == _splitter) {
      _splitter = null;
    }
    super.forgetChild(child);
  }

  @override
  void removeRenderObjectChild(RenderBox child, _SplitPaneSlot? slot) {
    assert(child == renderObject.before || child == renderObject.after || child == renderObject.splitter);
    switch (slot) {
      case _SplitPaneSlot.before:
        renderObject.before = null;
        break;
      case _SplitPaneSlot.after:
        renderObject.after = null;
        break;
      case _SplitPaneSlot.splitter:
        renderObject.splitter = null;
        break;
      case null:
        assert(false);
    }
  }
}

class _RenderSplitPane extends RenderBox {
  _RenderSplitPane({
    Axis orientation = Axis.horizontal,
    double splitRatio = 0.5,
    double splitterThickness = 6,
    bool roundToWholePixel = false,
    SplitPaneResizePolicy resizePolicy = SplitPaneResizePolicy.maintainSplitRatio,
  }) {
    this.orientation = orientation;
    this.splitRatio = splitRatio;
    this.splitterThickness = splitterThickness;
    this.roundToWholePixel = roundToWholePixel;
    this.resizePolicy = resizePolicy;
  }

  Axis? _orientation;
  Axis get orientation => _orientation!;
  set orientation(Axis value) {
    if (value == _orientation) return;
    _orientation = value;
    markNeedsLayout();
  }

  double? _splitRatio;
  double get splitRatio => _splitRatio!;
  set splitRatio(double value) {
    assert(value >= 0 && value <= 1);
    if (value == _splitRatio) return;
    _splitRatio = value;
    markNeedsLayout();
  }

  double? _splitterThickness;
  double get splitterThickness => _splitterThickness!;
  set splitterThickness(double value) {
    assert(value > 0);
    if (value == _splitterThickness) return;
    _splitterThickness = value;
    markNeedsLayout();
  }

  bool? _roundToWholePixel;
  bool get roundToWholePixel => _roundToWholePixel!;
  set roundToWholePixel(bool value) {
    if (value == _roundToWholePixel) return;
    _roundToWholePixel = value;
    markNeedsLayout();
  }

  SplitPaneResizePolicy? _resizePolicy;
  SplitPaneResizePolicy get resizePolicy => _resizePolicy!;
  set resizePolicy(SplitPaneResizePolicy value) {
    if (value == _resizePolicy) return;
    _resizePolicy = value;
  }

  RenderBox? _before;
  RenderBox? get before => _before;
  set before(RenderBox? value) {
    if (value == _before) return;
    if (_before != null) dropChild(_before!);
    _before = value;
    if (_before != null) adoptChild(_before!);
  }

  RenderBox? _after;
  RenderBox? get after => _after;
  set after(RenderBox? value) {
    if (value == _after) return;
    if (_after != null) dropChild(_after!);
    _after = value;
    if (_after != null) adoptChild(_after!);
  }

  RenderBox? _splitter;
  RenderBox? get splitter => _splitter;
  set splitter(RenderBox? value) {
    if (value == _splitter) return;
    if (_splitter != null) dropChild(_splitter!);
    _splitter = value;
    if (_splitter != null) adoptChild(_splitter!);
  }

  double _constrainSplitX(double splitX) {
    return math.max(math.min(splitX, size.width - splitterThickness), 0);
  }

  double _constrainSplitY(double splitY) {
    return math.max(math.min(splitY, size.height - splitterThickness), 0);
  }

  void _handleDrag(DragUpdateDetails details) {
    late final double newSplitRatio;
    switch (orientation) {
      case Axis.horizontal:
        final double oldSplitX = splitRatio * size.width;
        final double newSplitX = _constrainSplitX(oldSplitX + details.delta.dx);
        newSplitRatio = newSplitX / size.width;
        break;
      case Axis.vertical:
        final double oldSplitY = splitRatio * size.height;
        final double newSplitY = _constrainSplitY(oldSplitY + details.delta.dy);
        newSplitRatio = newSplitY / size.height;
        break;
    }
    splitRatio = newSplitRatio;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (before != null) before!.attach(owner);
    if (after != null) after!.attach(owner);
    if (splitter != null) splitter!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (before != null) before!.detach();
    if (after != null) after!.detach();
    if (splitter != null) splitter!.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (before != null) visitor(before!);
    if (after != null) visitor(after!);
    if (splitter != null) visitor(splitter!);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (RenderBox? child in [splitter, after, before]) {
      if (child != null) {
        final BoxParentData parentData = child.parentData as BoxParentData;
        final bool isHit = result.addWithPaintOffset(
          offset: parentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - parentData.offset);
            return child.hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  void performLayout() {
    switch (orientation) {
      case Axis.horizontal:
        assert(constraints.hasTightWidth);
        assert(constraints.hasBoundedHeight);
        final double? previousWidth = hasSize ? size.width : null;
        size = constraints.biggest;

        late double splitX;
        if (previousWidth == null || previousWidth == size.width) {
          splitX = size.width * splitRatio;
        } else {
          switch (resizePolicy) {
            case SplitPaneResizePolicy.maintainSplitRatio:
              splitX = _constrainSplitX(size.width * splitRatio);
              break;
            case SplitPaneResizePolicy.maintainBeforeSplitSize:
              final double oldSplitX = previousWidth * splitRatio;
              splitX = _constrainSplitX(oldSplitX);
              _splitRatio = splitX / size.width;
              break;
            case SplitPaneResizePolicy.maintainAfterSplitSize:
              final double oldSplitX = previousWidth * splitRatio;
              final double deltaWidth = size.width - previousWidth;
              splitX = _constrainSplitX(oldSplitX + deltaWidth);
              _splitRatio = splitX / size.width;
              break;
          }
        }

        if (roundToWholePixel) {
          splitX = splitX.roundToDouble();
        }
        final BoxConstraints beforeConstraints = BoxConstraints.tightFor(
          width: splitX,
          height: size.height,
        );
        before!.layout(beforeConstraints);

        double splitterThickness = this.splitterThickness;
        if (roundToWholePixel) {
          splitterThickness = splitterThickness.roundToDouble();
        }
        splitter!.layout(BoxConstraints.tightFor(width: splitterThickness, height: size.height));
        BoxParentData splitterParentData = splitter!.parentData as BoxParentData;
        splitterParentData.offset = Offset(splitX, 0);

        final double afterX = splitX + splitterThickness;
        final BoxConstraints afterConstraints = BoxConstraints.tightFor(
          width: size.width - afterX,
          height: size.height,
        );
        after!.layout(afterConstraints);
        BoxParentData afterParentData = after!.parentData as BoxParentData;
        afterParentData.offset = Offset(afterX, 0);

        break;
      case Axis.vertical:
        assert(constraints.hasTightHeight);
        assert(constraints.hasBoundedWidth);
        final double? previousHeight = hasSize ? size.height : null;
        size = constraints.biggest;

        late double splitY;
        if (previousHeight == null || previousHeight == size.height) {
          splitY = size.height * splitRatio;
        } else {
          switch (resizePolicy) {
            case SplitPaneResizePolicy.maintainSplitRatio:
              splitY = _constrainSplitY(size.height * splitRatio);
              break;
            case SplitPaneResizePolicy.maintainBeforeSplitSize:
              final double oldSplitY = previousHeight * splitRatio;
              splitY = _constrainSplitY(oldSplitY);
              _splitRatio = splitY / size.height;
              break;
            case SplitPaneResizePolicy.maintainAfterSplitSize:
              final double oldSplitY = previousHeight * splitRatio;
              final double deltaHeight = size.height - previousHeight;
              splitY = _constrainSplitY(oldSplitY + deltaHeight);
              _splitRatio = splitY / size.height;
              break;
          }
        }

        if (roundToWholePixel) {
          splitY = splitY.roundToDouble();
        }
        final BoxConstraints beforeConstraints = BoxConstraints.tightFor(
          width: size.width,
          height: splitY,
        );
        before!.layout(beforeConstraints);

        double splitterThickness = this.splitterThickness;
        if (roundToWholePixel) {
          splitterThickness = splitterThickness.roundToDouble();
        }
        splitter!.layout(BoxConstraints.tightFor(width: size.width, height: splitterThickness));
        BoxParentData splitterParentData = splitter!.parentData as BoxParentData;
        splitterParentData.offset = Offset(0, splitY);

        final double afterY = splitY + splitterThickness;
        final BoxConstraints afterConstraints = BoxConstraints.tightFor(
          width: size.width,
          height: size.height - afterY,
        );
        after!.layout(afterConstraints);
        BoxParentData afterParentData = after!.parentData as BoxParentData;
        afterParentData.offset = Offset(0, afterY);

        break;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(before != null);
    assert(after != null);
    context.paintChild(before!, offset);
    BoxParentData afterParentData = after!.parentData as BoxParentData;
    context.paintChild(after!, offset + afterParentData.offset);
    BoxParentData splitterParentData = splitter!.parentData as BoxParentData;
    context.paintChild(splitter!, offset + splitterParentData.offset);
  }

  @override
  void redepthChildren() {
    if (before != null) redepthChild(before!);
    if (after != null) redepthChild(after!);
    if (splitter != null) redepthChild(splitter!);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return <DiagnosticsNode>[
      if (before != null) before!.toDiagnosticsNode(name: 'before'),
      if (after != null) after!.toDiagnosticsNode(name: 'after'),
      if (splitter != null) splitter!.toDiagnosticsNode(name: 'splitter'),
    ];
  }
}
