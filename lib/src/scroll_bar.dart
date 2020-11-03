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

// @dart=2.9

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart' as colorUtils;
import 'listener_list.dart';

class ScrollBar extends LeafRenderObjectWidget {
  const ScrollBar({
    Key key,
    this.orientation = Axis.vertical,
    this.unitIncrement = 1,
    this.blockIncrement = 1,
  }) : super(key: key);

  final Axis orientation;
  final double unitIncrement;
  final double blockIncrement;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScrollBar(
      orientation: orientation,
      unitIncrement: unitIncrement,
      blockIncrement: blockIncrement,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderScrollBar renderObject) {
    renderObject
      ..orientation = orientation
      ..unitIncrement = unitIncrement
      ..blockIncrement = blockIncrement;
  }
}

class ScrollBarConstraints extends BoxConstraints {
  const ScrollBarConstraints({
    double minWidth = 0,
    double maxWidth = double.infinity,
    double minHeight = 0,
    double maxHeight = double.infinity,
    this.enabled = true,
    @required this.start,
    @required this.end,
    @required this.value,
    @required this.extent,
  })  : assert(enabled != null),
        assert(start != null),
        assert(end != null),
        assert(value != null),
        assert(extent != null),
        super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  ScrollBarConstraints.fromBoxConstraints({
    @required BoxConstraints boxConstraints,
    this.enabled = true,
    @required this.start,
    @required this.end,
    @required this.value,
    @required this.extent,
  })  : assert(enabled != null),
        assert(start != null),
        assert(end != null),
        assert(value != null),
        assert(extent != null),
        super(
          minWidth: boxConstraints.minWidth,
          maxWidth: boxConstraints.maxWidth,
          minHeight: boxConstraints.minHeight,
          maxHeight: boxConstraints.maxHeight,
        );

  final bool enabled;
  final double start;
  final double end;
  final double value;
  final double extent;

  @override
  bool get isNormalized {
    return super.isNormalized && start < end && value >= start && value + extent <= end;
  }

  @override
  ScrollBarConstraints normalize() {
    if (isNormalized) {
      return this;
    }
    final double end = start < this.end ? this.end : start + 1;
    final double value = this.value >= start && this.value < end ? this.value : start;
    return ScrollBarConstraints.fromBoxConstraints(
      boxConstraints: super.normalize(),
      start: start,
      end: end,
      value: value,
      extent: extent <= end - value ? extent : end - value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScrollBarConstraints &&
        super == other &&
        other.enabled == enabled &&
        other.start == start &&
        other.end == end &&
        other.value == value &&
        other.extent == extent;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(super.hashCode, enabled, start, end, value, extent);
  }

  @override
  String toString() {
    return 'ScrollBarConstraints(base=${super.toString()}, enabled=$enabled, start=$start, 3nd=$end, value=$value, extent=$extent)';
  }
}

class RenderScrollBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ScrollBarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ScrollBarParentData>,
        ListenerNotifier<ScrollBarValueListener> {
  RenderScrollBar({
    Axis orientation = Axis.vertical,
    double unitIncrement = 1,
    double blockIncrement = 1,
    bool enabled = true,
    double start = 0,
    double end = 100,
    double extent = 1,
    double value = 0,
  })  : assert(orientation != null),
        assert(unitIncrement != null),
        assert(blockIncrement != null),
        assert(start != null),
        assert(end != null),
        assert(extent != null),
        assert(value != null),
        assert(enabled != null),
        _orientation = orientation,
        _unitIncrement = unitIncrement,
        _blockIncrement = blockIncrement,
        _enabled = enabled,
        _start = start,
        _end = end,
        _extent = extent,
        _value = value {
    _upButton = _RenderScrollBarButton(
      orientation: orientation,
      direction: -1,
    );
    _downButton = _RenderScrollBarButton(
      orientation: orientation,
      direction: 1,
    );
    _handle = _RenderScrollBarHandle(
      orientation: orientation,
    );
    assert(() {
      // TODO: Just set these children at the widget layer with matching elements.
      _upButton.debugCreator = this;
      _downButton.debugCreator = this;
      _handle.debugCreator = this;
      return true;
    }());
    super.insert(_handle);
    super.insert(_upButton);
    super.insert(_downButton);
    automaticScroller = _AutomaticScroller(scrollBar: this);
  }

  /// These properties are effectively final but are initialized in the body
  /// of the constructor and so can't be marked final.
  _RenderScrollBarButton _upButton;
  _RenderScrollBarButton _downButton;
  _RenderScrollBarHandle _handle;
  _AutomaticScroller automaticScroller;

  static const double _minimumHandleLength = 31;

  Axis _orientation;
  Axis get orientation => _orientation;
  set orientation(Axis value) {
    assert(value != null);
    if (_orientation == value) return;
    _orientation = value;
    markNeedsLayout();
  }

  bool _enabled;
  bool get enabled => _enabled;

  double _start;
  double get start => _start;

  double _end;
  double get end => _end;

  double _extent;
  double get extent => _extent;

  double _value;
  double get value => _value;
  set value(double value) {
    if (!_updateValue(value)) return;

    // markNeedsLayout() would yield the correct behavior but would do more
    // work than needed. If all that has changed is the value, we can just
    // update the handle's location and save the work of a full layout.
    if (parentDataFor(_handle).visible) {
      if (orientation == Axis.horizontal) {
        double handleX = (value * _pixelValueRatio) + _upButton.size.width - 1;
        parentDataFor(_handle).offset = Offset(handleX, 1);
      } else {
        double handleY = (value * _pixelValueRatio) + _upButton.size.height - 1;
        parentDataFor(_handle).offset = Offset(1, handleY);
      }
    }

    markNeedsPaint();
  }

  /// Updates the value of [RenderScrollBar.value].
  ///
  /// If and only if the value was updated, this will notify listeners.
  ///
  /// Returns true if the value was updated, or false if the value didn't change.
  bool _updateValue(double value) {
    assert(value != null);
    if (_value == value) return false;
    double previousValue = _value;
    _value = value;
    notifyListeners((ScrollBarValueListener listener) {
      listener.valueChanged(this, previousValue);
    });
    return true;
  }

  double _unitIncrement;
  double get unitIncrement => _unitIncrement;
  set unitIncrement(double value) {
    assert(value != null);
    if (_unitIncrement == value) return;
    _unitIncrement = value;
  }

  double _blockIncrement;
  double get blockIncrement => _blockIncrement;
  set blockIncrement(double value) {
    assert(value != null);
    if (_blockIncrement == value) return;
    _blockIncrement = value;
  }

  /// The ratio of logical pixel to scroll bar value.
  ///
  /// For example, if every time the scroll bar moves one pixel, its value
  /// moves by two, then this ratio would be 2.0.
  double get _pixelValueRatio {
    double maxLegalRealValue = end - extent;
    double numLegalRealValues = maxLegalRealValue - start + 1;
    double numLegalPixelValues;

    // Track pixel values add two to account for the handle border overlapping
    // the button borders by 1 pixel to form a shared border.
    if (orientation == Axis.horizontal) {
      double trackWidth = size.width - _upButton.size.width - _downButton.size.width + 2;
      numLegalPixelValues = trackWidth - _handle.size.width + 1;
    } else {
      double trackHeight = size.height - _upButton.size.height - _downButton.size.height + 2;
      numLegalPixelValues = trackHeight - _handle.size.height + 1;
    }

    return numLegalPixelValues / numLegalRealValues;
  }

  _ScrollBarParentData parentDataFor(RenderBox child) => child.parentData;

  @override
  ScrollBarConstraints get constraints => super.constraints as ScrollBarConstraints;

  @override
  void insert(RenderBox child, {RenderBox after}) {
    throw UnsupportedError('Unsupported operation');
  }

  @override
  void add(RenderBox child) => throw UnsupportedError('Unsupported operation');

  @override
  void addAll(List<RenderBox> children) => throw UnsupportedError('Unsupported operation');

  @override
  void remove(RenderBox child) => throw UnsupportedError('Unsupported operation');

  @override
  void removeAll() => throw UnsupportedError('Unsupported operation');

  @override
  void move(RenderBox child, {RenderBox after}) => throw UnsupportedError('Unsupported operation');

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons & kPrimaryMouseButton != 0 && parentDataFor(_handle).visible) {
      // Begin automatic block scrolling. Calculate the direction of
      // the scroll by checking to see if the user pressed the pointer
      // in the area "before" the handle or "after" it.
      int direction;
      double realStopValue;

      if (orientation == Axis.horizontal) {
        direction = event.localPosition.dx < parentDataFor(_handle).offset.dx ? -1 : 1;

        double pixelStopValue = event.localPosition.dx - _upButton.size.width + 1;

        if (direction == 1) {
          // If we're scrolling down, account for the width of the
          // handle in our pixel stop value so that we stop as soon
          // as the *bottom* of the handle reaches our click point
          pixelStopValue -= _handle.size.width;
        }

        realStopValue = pixelStopValue / _pixelValueRatio;
      } else {
        direction = event.localPosition.dy < parentDataFor(_handle).offset.dy ? -1 : 1;

        double pixelStopValue = event.localPosition.dy - _upButton.size.height + 1;

        if (direction == 1) {
          // If we're scrolling down, account for the height of the
          // handle in our pixel stop value so that we stop as soon
          // as the *bottom* of the handle reaches our click point
          pixelStopValue -= _handle.size.height;
        }

        realStopValue = pixelStopValue / _pixelValueRatio;
      }

      // Start the automatic scroller
      automaticScroller.start(direction, _ScrollType.block, realStopValue);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    automaticScroller.stop();
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) return _onPointerDown(event);
    if (event is PointerUpEvent) return _onPointerUp(event);
    super.handleEvent(event, entry);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ScrollBarParentData) child.parentData = _ScrollBarParentData();
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (orientation == Axis.horizontal) {
      return math.max(
        _upButton.getMinIntrinsicHeight(width),
        _downButton.getMinIntrinsicHeight(width),
      );
    } else {
      return _upButton.getMinIntrinsicHeight(width) + _downButton.getMinIntrinsicHeight(width);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (orientation == Axis.horizontal) {
      return _upButton.getMinIntrinsicWidth(height) + _downButton.getMinIntrinsicWidth(height);
    } else {
      return math.max(
        _upButton.getMinIntrinsicWidth(height),
        _downButton.getMinIntrinsicWidth(height),
      );
    }
  }

  @override
  void performLayout() {
    assert(constraints.isTight);
    size = constraints.smallest;
    _enabled = constraints.enabled;
    _upButton.enabled = constraints.enabled;
    _downButton.enabled = constraints.enabled;
    _start = constraints.start;
    _end = constraints.end;
    _updateValue(constraints.value); // notifies listeners
    _extent = constraints.extent;

    double maxLegalRealValue = end - extent;
    double numLegalRealValues = maxLegalRealValue - start + 1;
    double extentPercentage = extent / (end - start);

    if (orientation == Axis.horizontal) {
      _upButton.layout(BoxConstraints.tightFor(height: size.height), parentUsesSize: true);
      parentDataFor(_upButton).visible = true;
      parentDataFor(_upButton).offset = Offset.zero;

      _downButton.layout(BoxConstraints.tightFor(height: size.height), parentUsesSize: true);
      parentDataFor(_downButton).visible = true;
      parentDataFor(_downButton).offset = Offset(size.width - _downButton.size.width, 0);

      if (size.width < _upButton.size.width + _downButton.size.width) {
        parentDataFor(_upButton).visible = false;
        parentDataFor(_downButton).visible = false;
      }

      if (enabled) {
        // Calculate the handle width first, as it dictates how much
        // room is left to represent the range of legal values. Note
        // that the handle may overlap each scroll button by 1px so
        // that its borders merge into the borders of the scroll buttons
        double availableWidth = size.width - _upButton.size.width - _downButton.size.width + 2;
        double handleWidth = math.max(_minimumHandleLength, (extentPercentage * availableWidth));

        // Calculate the position of the handle by calculating the
        // scale that maps logical value to pixel value
        double numLegalPixelValues = availableWidth - handleWidth + 1;
        double valueScale = numLegalPixelValues / numLegalRealValues;
        double handleX = (value * valueScale) + _upButton.size.width - 1;

        if (handleWidth > availableWidth) {
          // If we can't fit the handle, we hide it
          _handle.layout(BoxConstraints.tight(Size.zero));
          parentDataFor(_handle).visible = false;
        } else {
          _handle.layout(BoxConstraints.tightFor(width: handleWidth, height: size.height - 2));
          parentDataFor(_handle).visible = true;
          parentDataFor(_handle).offset = Offset(handleX, 1);
        }
      } else {
        _handle.layout(BoxConstraints.tight(Size.zero));
        parentDataFor(_handle).visible = false;
      }
    } else {
      _upButton.layout(BoxConstraints.tightFor(width: size.width), parentUsesSize: true);
      parentDataFor(_upButton).visible = true;
      parentDataFor(_upButton).offset = Offset.zero;

      _downButton.layout(BoxConstraints.tightFor(width: size.width), parentUsesSize: true);
      parentDataFor(_downButton).visible = true;
      parentDataFor(_downButton).offset = Offset(0, size.height - _downButton.size.height);

      if (size.height < _upButton.size.height + _downButton.size.height) {
        parentDataFor(_upButton).visible = false;
        parentDataFor(_downButton).visible = false;
      }

      if (enabled) {
        // Calculate the handle height first, as it dictates how much
        // room is left to represent the range of legal values. Note
        // that the handle may overlap each scroll button by 1px so
        // that its borders merge into the borders of the scroll buttons
        double availableHeight = size.height - _upButton.size.height - _downButton.size.height + 2;
        double handleHeight = math.max(_minimumHandleLength, (extentPercentage * availableHeight));

        // Calculate the position of the handle by calculating the
        // scale maps logical value to pixel value
        double numLegalPixelValues = availableHeight - handleHeight + 1;
        double valueScale = numLegalPixelValues / numLegalRealValues;
        double handleY = (value * valueScale) + _upButton.size.height - 1;

        if (handleHeight > availableHeight) {
          // If we can't fit the handle, we hide it
          _handle.layout(BoxConstraints.tight(Size.zero));
          parentDataFor(_handle).visible = false;
        } else {
          _handle.layout(BoxConstraints.tightFor(width: size.width - 2, height: handleHeight));
          parentDataFor(_handle).visible = true;
          parentDataFor(_handle).offset = Offset(1, handleY);
        }
      } else {
        _handle.layout(BoxConstraints.tight(Size.zero));
        parentDataFor(_handle).visible = false;
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint the track background.
    Paint bgPaint = Paint()..style = PaintingStyle.fill;
    Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff999999);
    List<Color> colors = <Color>[const Color(0xffc5c3bc), const Color(0xffdedcd4)];
    switch (orientation) {
      case Axis.horizontal:
        bgPaint.shader = ui.Gradient.linear(
          offset + Offset(0, 1.5),
          offset + Offset(0, size.height - 1.5),
          colors,
        );
        context.canvas.drawRect(offset & size, bgPaint);
        context.canvas.drawLine(
          offset + Offset(_upButton.size.width, 0.5),
          offset + Offset(size.width - _downButton.size.width, 0.5),
          borderPaint,
        );
        context.canvas.drawLine(
          offset + Offset(_upButton.size.width, size.height - 0.5),
          offset + Offset(size.width - _downButton.size.width, size.height - 0.5),
          borderPaint,
        );
        break;
      case Axis.vertical:
        bgPaint.shader = ui.Gradient.linear(
          offset + Offset(1.5, 0),
          offset + Offset(size.width - 1.5, 0),
          colors,
        );
        context.canvas.drawRect(offset & size, bgPaint);
        context.canvas.drawLine(
          offset + Offset(0.5, _upButton.size.height),
          offset + Offset(0.5, size.height - _downButton.size.height),
          borderPaint,
        );
        context.canvas.drawLine(
          offset + Offset(size.width - 0.5, _upButton.size.height),
          offset + Offset(size.width - 0.5, size.height - _downButton.size.height),
          borderPaint,
        );
        break;
    }

    RenderBox child = firstChild;
    while (child != null) {
      final _ScrollBarParentData childParentData = child.parentData;
      if (childParentData.visible ?? false) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {ui.Offset position}) {
    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Cannot hit test a render box that has never been laid out.'),
            describeForError('The hitTest() method was called on this RenderBox'),
            ErrorDescription("Unfortunately, this object's geometry is not known at this time, "
                'probably because it has never been laid out. '
                'This means it cannot be accurately hit-tested.'),
            ErrorHint('If you are trying '
                'to perform a hit test during the layout phase itself, make sure '
                "you only hit test nodes that have completed layout (e.g. the node's "
                'children, after their layout() method has been called).'),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription('Although this node is not marked as needing layout, '
              'its size is not set.'),
          ErrorHint('A RenderBox object must have an '
              'explicit size before it can be hit-tested. Make sure '
              'that the RenderBox in question sets its size during layout.'),
        ]);
      }
      return true;
    }());
    if (size.contains(position)) {
      if (hitTestChildren(result, position: position)) {
        // Intentionally don't add a hit test entry for the scroll bar if one
        // of the children was hit.  i.e. the children "consume" the hit
        // before it reaches the scroll bar track.
        return true;
      } else if (hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('orientation', orientation));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(DoubleProperty('start', start));
    properties.add(DoubleProperty('end', end));
    properties.add(DoubleProperty('extent', extent));
    properties.add(DoubleProperty('value', value));
    properties.add(DoubleProperty('unitIncrement', unitIncrement));
    properties.add(DoubleProperty('blockIncrement', blockIncrement));
  }
}

class _ScrollBarParentData extends ContainerBoxParentData<RenderBox> {
  /// Whether the child should be painted.
  bool visible;

  @override
  String toString() => '${super.toString()}; visible=$visible';
}

typedef ScrollBarValueChangedHandler = void Function(
  RenderScrollBar scrollBar,
  double previousValue,
);

class ScrollBarValueListener {
  const ScrollBarValueListener({
    @required this.valueChanged,
  }) : assert(valueChanged != null);

  /// Called when a scroll bar's value has changed.
  final ScrollBarValueChangedHandler valueChanged;
}

class _RenderScrollBarButton extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderBoxWithChildDefaultsMixin {
  _RenderScrollBarButton({
    this.orientation = Axis.vertical,
    this.direction = 1,
  }) {
    child = RenderMouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
    );
  }

  final Axis orientation;
  final int direction;

  static const double _length = 15;

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool value) {
    assert(value != null);
    if (_enabled == value) return;
    parent?.automaticScroller?.stop();
    _enabled = value;
    if (_enabled) {
      child.cursor = SystemMouseCursors.click;
    } else {
      child.cursor = MouseCursor.defer;
    }
    markNeedsPaint();
  }

  bool _highlighted = false;
  bool get highlighted => _highlighted;
  set highlighted(bool value) {
    assert(value != null);
    if (_highlighted == value) return;
    _highlighted = value;
    markNeedsPaint();
  }

  bool _pressed = false;
  bool get pressed => _pressed;
  set pressed(bool value) {
    assert(value != null);
    if (_pressed == value) return;
    _pressed = value;
    markNeedsPaint();
  }

  void _onEnter(PointerEnterEvent event) {
    highlighted = true;
  }

  void _onExit(PointerExitEvent event) {
    parent.automaticScroller.stop();
    highlighted = false;
    pressed = false;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons & kPrimaryMouseButton != 0) {
      parent.automaticScroller.start(direction, _ScrollType.unit, -1);
      pressed = true;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    parent.automaticScroller.stop();
    pressed = false;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    parent.automaticScroller.stop();
    pressed = false;
  }

  @override
  RenderScrollBar get parent => super.parent;

  @override
  RenderMouseRegion get child => super.child;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (!enabled) return;
    if (event is PointerDownEvent) return _onPointerDown(event);
    if (event is PointerUpEvent) return _onPointerUp(event);
    if (event is PointerCancelEvent) return _onPointerCancel(event);
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {ui.Offset position}) {
    return defaultHitTestChild(result, position: position);
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;

  @override
  double computeMinIntrinsicHeight(double width) => _length;

  @override
  double computeMinIntrinsicWidth(double height) => _length;

  @override
  void performLayout() {
    size = constraints.constrain(Size.square(_length));
    if (child != null) child.layout(BoxConstraints.tight(size));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _ScrollButtonPainter painter = _ScrollButtonPainter(
      enabled: enabled,
      pressed: pressed,
      highlighted: highlighted,
      orientation: orientation,
      arrow: _ArrowImage(orientation: orientation, direction: direction),
    );
    context.canvas.save();
    try {
      context.canvas.translate(offset.dx, offset.dy);
      painter.paint(context.canvas, size);
    } finally {
      context.canvas.restore();
    }

    if (child != null) context.paintChild(child, offset);
  }
}

class _RenderScrollBarHandle extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderBoxWithChildDefaultsMixin {
  _RenderScrollBarHandle({@required this.orientation}) : assert(orientation != null) {
    child = RenderMouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
    );
  }

  final Axis orientation;

  bool _highlighted = false;
  bool get highlighted => _highlighted;
  set highlighted(bool value) {
    assert(value != null);
    if (_highlighted == value) return;
    _highlighted = value;
    markNeedsPaint();
  }

  void _onEnter(PointerEnterEvent event) {
    highlighted = true;
  }

  void _onExit(PointerExitEvent event) {
    highlighted = false;
  }

  double _dragOffset;

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons & kPrimaryMouseButton != 0) {
      _dragOffset = orientation == Axis.horizontal
          ? event.position.dx - parentData.offset.dx + parent._upButton.size.width - 1
          : event.position.dy - parentData.offset.dy + parent._upButton.size.height - 1;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _dragOffset = null;
    markNeedsPaint();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_dragOffset != null) {
      // Calculate the new scroll bar value
      double pixelValue;
      if (orientation == Axis.horizontal) {
        pixelValue = event.position.dx - _dragOffset;
      } else {
        pixelValue = event.position.dy - _dragOffset;
      }

      double scrollBarValue = (pixelValue / parent._pixelValueRatio);
      scrollBarValue = math.min(math.max(scrollBarValue, 0), parent.end - parent.extent);
      parent.value = scrollBarValue;
    }
  }

  @override
  RenderScrollBar get parent => super.parent;

  @override
  BoxParentData get parentData => super.parentData;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) return _onPointerDown(event);
    if (event is PointerUpEvent) return _onPointerUp(event);
    if (event is PointerMoveEvent) return _onPointerMove(event);
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {ui.Offset position}) {
    return defaultHitTestChild(result, position: position);
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;

  @override
  void performLayout() {
    size = constraints.smallest;
    if (child != null) child.layout(BoxConstraints.tight(size));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _HandlePainter painter = _HandlePainter(
      highlighted: highlighted || _dragOffset != null,
      orientation: orientation,
    );
    context.canvas.save();
    try {
      context.canvas.translate(offset.dx.floorToDouble(), offset.dy.floorToDouble());
      painter.paint(context.canvas, size);
    } finally {
      context.canvas.restore();
    }

    if (child != null) context.paintChild(child, offset);
  }
}

mixin RenderBoxWithChildDefaultsMixin on RenderObjectWithChildMixin<RenderBox> {
  bool defaultHitTestChild(BoxHitTestResult result, {Offset position}) {
    if (child == null) {
      return false;
    }
    final BoxParentData childParentData = child.parentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return child.hitTest(result, position: transformed);
      },
    );
  }
}

enum _ScrollType {
  unit,
  block,
}

class _ScrollButtonPainter extends CustomPainter {
  const _ScrollButtonPainter({
    @required this.enabled,
    @required this.pressed,
    @required this.highlighted,
    @required this.orientation,
    @required this.arrow,
  })  : assert(enabled != null),
        assert(pressed != null),
        assert(highlighted != null),
        assert(orientation != null),
        assert(arrow != null);

  final bool enabled;
  final bool pressed;
  final bool highlighted;
  final Axis orientation;
  final _ArrowImage arrow;

  @override
  void paint(Canvas canvas, Size size) {
    Color backgroundColor;
    if (enabled) {
      if (pressed) {
        backgroundColor = const Color(0xffc5c3bc);
      } else if (highlighted) {
        backgroundColor = const Color(0xfff7f5ee);
      } else {
        backgroundColor = const Color(0xffdddcd5);
      }
    } else {
      backgroundColor = const Color(0xffcccccc);
    }

    Color brightBackgroundColor = colorUtils.brighten(backgroundColor);

    // Paint the background
    Color gradientStartColor = pressed ? backgroundColor : brightBackgroundColor;
    Color gradientEndColor = pressed ? brightBackgroundColor : backgroundColor;
    List<Color> colors = <Color>[gradientStartColor, gradientEndColor];

    Paint bgPaint = Paint()..style = PaintingStyle.fill;
    if (orientation == Axis.horizontal) {
      if (enabled)
        bgPaint.shader = ui.Gradient.linear(Offset(0, 1.5), Offset(0, size.height - 1.5), colors);
      else
        bgPaint.color = backgroundColor;
    } else {
      if (enabled)
        bgPaint.shader = ui.Gradient.linear(Offset(1.5, 0), Offset(size.width - 1.5, 0), colors);
      else
        bgPaint.color = backgroundColor;
    }

    canvas.drawRect(Offset(1, 1) & Size(size.width - 2, size.height - 2), bgPaint);

    // Paint the border
    Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff999999);
    canvas.drawRect((Offset.zero & size).deflate(0.5), borderPaint);

    // Paint the arrow
    double arrowX = (size.width - arrow.preferredSize.width) / 2;
    double arrowY = (size.height - arrow.preferredSize.height) / 2;
    canvas.save();
    try {
      canvas.translate(arrowX, arrowY);
      arrow.paint(canvas, arrow.preferredSize);
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

abstract class _ArrowImage {
  const _ArrowImage._(this.orientation);

  factory _ArrowImage({
    @required Axis orientation,
    @required int direction,
  }) {
    assert(orientation != null);
    assert(direction != null);
    if (direction > 0) {
      return _UpArrowImage(orientation);
    } else {
      return _DownArrowImage(orientation);
    }
  }

  final Axis orientation;

  Size get preferredSize => orientation == Axis.horizontal ? Size(5, 7) : Size(7, 5);

  void paint(Canvas canvas, Size size);
}

class _UpArrowImage extends _ArrowImage {
  const _UpArrowImage(Axis orientation) : super._(orientation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint arrowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xff000000);
    Path arrow = Path()..fillType = PathFillType.evenOdd;
    switch (orientation) {
      case Axis.horizontal:
        arrow
          ..moveTo(0, 0)
          ..lineTo(size.width + 0.5, size.height / 2)
          ..lineTo(0, size.height);
        break;
      case Axis.vertical:
        arrow
          ..moveTo(0, 0)
          ..lineTo(size.width / 2, size.height + 0.5)
          ..lineTo(size.width, 0);
        break;
    }
    arrow.close();
    canvas.drawPath(arrow, arrowPaint);
  }
}

class _DownArrowImage extends _ArrowImage {
  const _DownArrowImage(Axis orientation) : super._(orientation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint arrowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xff000000);
    Path arrow = Path()..fillType = PathFillType.evenOdd;
    switch (orientation) {
      case Axis.horizontal:
        arrow
          ..moveTo(size.width, 0)
          ..lineTo(-0.5, size.height / 2)
          ..lineTo(size.width, size.height);
        break;
      case Axis.vertical:
        arrow
          ..moveTo(0, size.height)
          ..lineTo(size.width / 2, -0.5)
          ..lineTo(size.width, size.height);
        break;
    }
    arrow.close();
    canvas.drawPath(arrow, arrowPaint);
  }
}

class _HandlePainter extends CustomPainter {
  const _HandlePainter({
    @required this.highlighted,
    @required this.orientation,
  })  : assert(highlighted != null),
        assert(orientation != null);

  final bool highlighted;
  final Axis orientation;

  @override
  void paint(Canvas canvas, Size size) {
    Color backgroundColor = highlighted ? const Color(0xfff7f5ee) : const Color(0xffdbdad3);

    Color brightBackgroundColor = colorUtils.brighten(backgroundColor);
    Color darkBackgroundColor = colorUtils.darken(backgroundColor);
    List<Color> colors = <Color>[brightBackgroundColor, backgroundColor];

    Paint paint = Paint()..style = PaintingStyle.fill;
    if (orientation == Axis.horizontal) {
      paint.shader = ui.Gradient.linear(Offset(0, 0.5), Offset(0, size.height - 0.5), colors);
    } else {
      paint.shader = ui.Gradient.linear(Offset(0.5, 0), Offset(size.width - 0.5, 0), colors);
    }

    canvas.drawRect(Offset.zero & size, paint);

    // Paint the border
    Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff999999);
    if (orientation == Axis.horizontal) {
      canvas.drawLine(Offset(0.5, 0), Offset(0.5, size.height), borderPaint);
      canvas.drawLine(
        Offset(size.width - 0.5, 0),
        Offset(size.width - 0.5, size.height),
        borderPaint,
      );
    } else {
      canvas.drawLine(Offset(0, 0.5), Offset(size.width, 0.5), borderPaint);
      canvas.drawLine(
        Offset(0, size.height - 0.5),
        Offset(size.width, size.height - 0.5),
        borderPaint,
      );
    }

    // Paint the hash marks
    Paint hashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (orientation == Axis.horizontal) {
      final double mid = size.width / 2;
      hashPaint.color = darkBackgroundColor;
      canvas.drawLine(Offset(mid - 3.5, 2.5), Offset(mid - 3.5, size.height - 2.5), hashPaint);
      canvas.drawLine(Offset(mid - 0.5, 2.5), Offset(mid - 0.5, size.height - 2.5), hashPaint);
      canvas.drawLine(Offset(mid + 2.5, 2.5), Offset(mid + 2.5, size.height - 2.5), hashPaint);
      hashPaint.color = brightBackgroundColor;
      canvas.drawLine(Offset(mid - 2.5, 2.5), Offset(mid - 2.5, size.height - 2.5), hashPaint);
      canvas.drawLine(Offset(mid + 0.5, 2.5), Offset(mid + 0.5, size.height - 2.5), hashPaint);
      canvas.drawLine(Offset(mid + 3.5, 2.5), Offset(mid + 3.5, size.height - 2.5), hashPaint);
    } else {
      final double mid = size.height / 2;
      hashPaint.color = darkBackgroundColor;
      canvas.drawLine(Offset(2.5, mid - 3.5), Offset(size.width - 2.5, mid - 3.5), hashPaint);
      canvas.drawLine(Offset(2.5, mid - 0.5), Offset(size.width - 2.5, mid - 0.5), hashPaint);
      canvas.drawLine(Offset(2.5, mid + 2.5), Offset(size.width - 2.5, mid + 2.5), hashPaint);
      hashPaint.color = brightBackgroundColor;
      canvas.drawLine(Offset(2.5, mid - 2.5), Offset(size.width - 2.5, mid - 2.5), hashPaint);
      canvas.drawLine(Offset(2.5, mid + 0.5), Offset(size.width - 2.5, mid + 0.5), hashPaint);
      canvas.drawLine(Offset(2.5, mid + 3.5), Offset(size.width - 2.5, mid + 3.5), hashPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class _AutomaticScroller {
  _AutomaticScroller({
    @required this.scrollBar,
  }) : assert(scrollBar != null);

  final RenderScrollBar scrollBar;

  int direction;
  _ScrollType incrementType;
  double stopValue;
  Timer scheduledScrollTimer;

  static const Duration _delay = Duration(milliseconds: 400);
  static const Duration _interval = Duration(milliseconds: 30);

  /// Starts scrolling this skin's scroll bar, stopping the scroll when
  /// the specified value has been reached.
  ///
  /// @param direction
  /// <tt>1</tt> to adjust the scroll bar's value larger; <tt>-1</tt> to
  /// adjust it smaller
  ///
  /// @param incrementType
  /// Determines whether we'll use the scroll bar's unit increment or the
  /// block increment when scrolling
  ///
  /// @param stopValue
  /// The value which, once reached, will stop the automatic scrolling.
  /// Use <tt>-1</tt> to specify no stop value
  ///
  /// @exception IllegalStateException
  /// If automatic scrolling of any scroll bar is already in progress.
  /// Only one scroll bar may be automatically scrolled at one time
  void start(int direction, _ScrollType incrementType, double stopValue) {
    if (scheduledScrollTimer != null) {
      throw StateError('Already running');
    }

    this.direction = direction;
    this.incrementType = incrementType;
    this.stopValue = stopValue;

    // Wait a timeout period, then begin rapidly scrolling
    scheduledScrollTimer = Timer(_delay, () {
      scheduledScrollTimer = Timer.periodic(_interval, (Timer timer) {
        scroll();
      });
    });

    // We initially scroll once to register that we've started
    scroll();
  }

  /// Stops any automatic scrolling in progress.
  void stop() {
    if (scheduledScrollTimer != null) {
      scheduledScrollTimer.cancel();
      scheduledScrollTimer = null;
    }
  }

  void scroll() {
    double start = scrollBar.start;
    double end = scrollBar.end;
    double extent = scrollBar.extent;
    double value = scrollBar.value;

    double adjustment;

    if (incrementType == _ScrollType.unit) {
      adjustment = direction * scrollBar.unitIncrement;
    } else {
      adjustment = direction * scrollBar.blockIncrement;
    }

    if (adjustment < 0) {
      double newValue = math.max(value + adjustment, start);
      scrollBar.value = newValue;

      if (stopValue != -1 && newValue < stopValue) {
        // We've reached the explicit stop value
        stop();
      }

      if (newValue == start) {
        // We implicit stop at the minimum scroll bar value
        stop();
      }
    } else {
      double newValue = math.min(value + adjustment, end - extent);
      scrollBar.value = newValue;

      if (stopValue != -1 && newValue > stopValue) {
        // We've reached the explicit stop value
        stop();
      }

      if (newValue == end - extent) {
        // We implicitly stop at the maximum scroll bar value
        stop();
      }
    }
  }
}
