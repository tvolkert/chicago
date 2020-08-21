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
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as flutter show Border;

class Border extends StatelessWidget {
  const Border({
    Key key,
    this.title,
    this.titleStyle,
    this.titlePadding = EdgeInsets.zero,
    this.textDirection,
    this.borderColor = const Color(0xff000000),
    this.borderThickness = 1,
    this.borderRadius = BorderRadius.zero,
    this.backgroundColor,
    this.inset = 0,
    this.child,
  })  : assert(titlePadding != null),
        assert(borderColor != null),
        assert(borderThickness != null),
        assert(borderRadius != null),
        assert(inset != null),
        super(key: key);

  final String title;
  final TextStyle titleStyle;
  final EdgeInsetsGeometry titlePadding;

  /// The directionality of this widget.
  ///
  /// This affects the placement of the [title] widget and the associated
  /// behavior of the [inset] amount.
  final TextDirection textDirection;

  /// The color of the border.
  ///
  /// If unspecified, this defaults to black.
  final Color borderColor;

  /// The thickness of the border.
  ///
  /// If unspecified, this defaults to a 1-pixel border.
  final double borderThickness;

  /// The border radius.
  ///
  /// If unspecified, this defaults to a zero-radius (square) border.
  final BorderRadiusGeometry borderRadius;

  /// The color to paint inside the border, behind the [child] and [title].
  ///
  /// If unspecified, the background will be transparent.
  final Color backgroundColor;

  /// The indentation (in pixels) for [title].
  ///
  /// If the [textDirection] is [TextDirection.ltr], then this will be a left
  /// indent. If the [textDirection] is [TextDirection.rtl], then this will be
  /// a right indent.
  final double inset;

  /// The widget to lay out inside the border.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget titleWidget;
    if (title != null) {
      TextStyle titleStyle = this.titleStyle;
      if (titleStyle == null) {
        final TextStyle baseStyle = DefaultTextStyle.of(context).style;
        titleStyle = baseStyle.copyWith(fontWeight: FontWeight.bold, color: const Color(0xff3c77b2));
      }
      titleWidget = Padding(
        padding: titlePadding,
        child: Text(title, style: titleStyle),
      );
    }

    return _BorderLayout(
      textDirection: textDirection ?? Directionality.of(context),
      inset: inset,
      title: titleWidget,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: flutter.Border.all(width: borderThickness, color: borderColor),
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        child: child,
      ),
    );
  }
}

class _BorderLayout extends RenderObjectWidget {
  _BorderLayout({
    Key key,
    @required this.title,
    @required this.child,
    @required this.inset,
    @required this.textDirection,
  })  : assert(inset != null),
        assert(textDirection != null),
        super(key: key);

  final Widget title;
  final Widget child;
  final double inset;
  final TextDirection textDirection;

  @override
  RenderObjectElement createElement() => _BorderLayoutElement(this);

  @override
  _RenderBorderLayout createRenderObject(BuildContext context) {
    return _RenderBorderLayout(inset: inset, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderBorderLayout renderObject) {
    renderObject
      ..inset = inset
      ..textDirection = textDirection;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('inset', inset));
    properties.add(DiagnosticsProperty<TextDirection>('textDirection', textDirection));
  }
}

enum _BorderLayoutSlot {
  title,
  child,
}

class _BorderLayoutElement extends RenderObjectElement {
  _BorderLayoutElement(_BorderLayout widget) : super(widget);

  Element _title;
  Element _child;

  @override
  _BorderLayout get widget => super.widget as _BorderLayout;

  @override
  _RenderBorderLayout get renderObject => super.renderObject as _RenderBorderLayout;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_title != null) {
      visitor(_title);
    }
    if (_child != null) {
      visitor(_child);
    }
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _title = updateChild(_title, widget.title, _BorderLayoutSlot.title);
    _child = updateChild(_child, widget.child, _BorderLayoutSlot.child);
  }

  @override
  void insertRenderObjectChild(RenderBox child, _BorderLayoutSlot slot) {
    assert(slot != null);
    switch (slot) {
      case _BorderLayoutSlot.title:
        renderObject.title = child;
        break;
      case _BorderLayoutSlot.child:
        renderObject.child = child;
        break;
    }
  }

  @override
  void moveRenderObjectChild(RenderObject _, _BorderLayoutSlot __, _BorderLayoutSlot ___) {
    assert(false);
  }

  @override
  void update(RenderObjectWidget newWidget) {
    super.update(newWidget);
    _title = updateChild(_title, widget.title, _BorderLayoutSlot.title);
    _child = updateChild(_child, widget.child, _BorderLayoutSlot.child);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _title || child == _child);
    if (child == _title) {
      _title = null;
    } else if (child == _child) {
      _child = null;
    }
    super.forgetChild(child);
  }

  @override
  void removeRenderObjectChild(RenderObject child, _BorderLayoutSlot slot) {
    assert(child == renderObject.title || child == renderObject.child);
    switch (slot) {
      case _BorderLayoutSlot.title:
        renderObject.title = null;
        break;
      case _BorderLayoutSlot.child:
        renderObject.child = null;
        break;
    }
  }
}

class _RenderBorderLayout extends RenderBox {
  _RenderBorderLayout({
    double inset = 0,
    TextDirection textDirection = TextDirection.ltr,
  })  : assert(inset != null),
        assert(textDirection != null) {
    this.inset = inset;
    this.textDirection = textDirection;
  }

  double _inset;
  double get inset => _inset;
  set inset(double value) {
    assert(value != null);
    if (value == _inset) return;
    _inset = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    assert(value != null);
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox _title;
  RenderBox get title => _title;
  set title(RenderBox value) {
    if (value == _title) return;
    if (_title != null) dropChild(_title);
    _title = value;
    if (_title != null) adoptChild(_title);
  }

  RenderBox _child;
  RenderBox get child => _child;
  set child(RenderBox value) {
    if (value == _child) return;
    if (_child != null) dropChild(_child);
    _child = value;
    if (_child != null) adoptChild(_child);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (title != null) title.attach(owner);
    if (child != null) child.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (title != null) title.detach();
    if (child != null) child.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (title != null) visitor(title);
    if (child != null) visitor(child);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    bool isHit = false;
    for (RenderBox child in [title, this.child]) {
      if (child != null) {
        final BoxParentData parentData = child.parentData;
        isHit |= result.addWithPaintOffset(
          offset: parentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - parentData.offset);
            return child.hitTest(result, position: transformed);
          },
        );
      }
    }

    return isHit;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  double computeMinIntrinsicWidth(double height) {
    double intrinsicWidth = 0;

    double titleHalfHeight = 0;
    if (title != null) {
      intrinsicWidth = title.getMinIntrinsicWidth(double.infinity);
      titleHalfHeight = (title.getMinIntrinsicHeight(intrinsicWidth) / 2).ceilToDouble();
    }

    if (child != null) {
      if (height.isFinite) {
        height = math.max(height - titleHalfHeight, 0);
      }
      intrinsicWidth = math.max(child.getMinIntrinsicWidth(height), intrinsicWidth);
    }

    return intrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) => computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    double intrinsicHeight = 0;

    if (title != null) {
      double titleHeight = title.getMinIntrinsicHeight(width - inset);
      intrinsicHeight += (titleHeight / 2).ceilToDouble();
    }

    if (child != null) {
      intrinsicHeight += child.getMinIntrinsicHeight(width);
    }

    return intrinsicHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  void performLayout() {
    double titleHeight = 0;
    if (title != null) {
      title.layout(constraints.deflate(EdgeInsets.only(left: inset)).loosen(), parentUsesSize: true);
      titleHeight = title.size.height;
    }
    final double titleHalfHeight = (titleHeight / 2).roundToDouble();

    Size childSize = Size.zero;
    if (child != null) {
      BoxConstraints childConstraints = constraints.deflate(EdgeInsets.only(top: titleHalfHeight));
      child.layout(childConstraints, parentUsesSize: true);
      childSize = child.size;
      final BoxParentData childParentData = child.parentData;
      childParentData.offset = Offset(0, titleHalfHeight);
    }

    size = constraints.constrainDimensions(childSize.width, childSize.height + titleHalfHeight);

    if (title != null) {
      final BoxParentData titleParentData = title.parentData;
      if (textDirection == TextDirection.ltr) {
        titleParentData.offset = Offset(inset, 0);
      } else {
        titleParentData.offset = Offset(size.width - title.size.width - inset, 0);
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final BoxParentData childParentData = child.parentData;
      if (title != null) {
        context.canvas.save();
        try {
          final BoxParentData titleParentData = title.parentData;
          context.canvas.clipRect((offset + titleParentData.offset) & title.size, clipOp: ClipOp.difference);
          context.paintChild(child, offset + childParentData.offset);
        } finally {
          context.canvas.restore();
        }
      } else {
        context.paintChild(child, offset + childParentData.offset);
      }
    }

    if (title != null) {
      final BoxParentData titleParentData = title.parentData;
      context.paintChild(title, offset + titleParentData.offset);
    }
  }

  @override
  void redepthChildren() {
    if (title != null) redepthChild(title);
    if (child != null) redepthChild(child);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> result = <DiagnosticsNode>[];
    void add(RenderBox child, String name) {
      if (child != null) result.add(child.toDiagnosticsNode(name: name));
    }

    add(title, 'title');
    add(child, 'child');
    return result;
  }
}
