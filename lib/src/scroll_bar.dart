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

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart' as colorUtils;
import 'listener_list.dart';

class ScrollBar extends StatelessWidget {
  const ScrollBar({
    Key? key,
    this.orientation = Axis.vertical,
    this.unitIncrement = 1,
    this.blockIncrement = 1,
  }) : super(key: key);

  /// This scroll bar's orientation.
  ///
  /// This defaults to [Axis.vertical] if it's not specified in the
  /// constructor.
  ///
  /// changing a scroll bar's orientation when rebuilding the widget is
  /// currently not supported.
  final Axis orientation;

  /// The value adjustment that will be made (up or down) when the user presses
  /// the scroll bar buttons.
  final double unitIncrement;

  /// The value adjustment that will be made (up or down) when the user taps
  /// on the scroll bar track (on either side of the scroll bar handle).
  final double blockIncrement;

  @override
  Widget build(BuildContext context) {
    return _ScrollBar(
      orientation: orientation,
      unitIncrement: unitIncrement,
      blockIncrement: blockIncrement,
      upButton: _ScrollBarButton(orientation: orientation, direction: -1),
      downButton: _ScrollBarButton(orientation: orientation, direction: 1),
      handle: _ScrollBarHandle(orientation: orientation),
      track: _ScrollBarTrack(orientation: orientation),
    );
  }
}

class _ScrollBarButton extends LeafRenderObjectWidget {
  const _ScrollBarButton({
    Key? key,
    required this.orientation,
    required this.direction,
  }) : super(key: key);

  final Axis orientation;
  final int direction;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderScrollBarButton(
      orientation: orientation,
      direction: direction,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderScrollBarButton renderObject) {
    assert(orientation == renderObject.orientation);
  }
}

class _ScrollBarHandle extends LeafRenderObjectWidget {
  const _ScrollBarHandle({
    Key? key,
    required this.orientation,
  }) : super(key: key);

  final Axis orientation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderScrollBarHandle(
      orientation: orientation,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderScrollBarHandle renderObject) {
    assert(orientation == renderObject.orientation);
  }
}

class _ScrollBarTrack extends LeafRenderObjectWidget {
  const _ScrollBarTrack({
    Key? key,
    required this.orientation,
  }) : super(key: key);

  final Axis orientation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderScrollBarTrack(orientation: orientation);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderScrollBarTrack renderObject) {
    assert(orientation == renderObject.orientation);
  }
}

class _ScrollBar extends RenderObjectWidget {
  const _ScrollBar({
    Key? key,
    required this.orientation,
    required this.unitIncrement,
    required this.blockIncrement,
    required this.upButton,
    required this.downButton,
    required this.handle,
    required this.track,
  }) : super(key: key);

  final Axis orientation;
  final double unitIncrement;
  final double blockIncrement;
  final Widget upButton;
  final Widget downButton;
  final Widget handle;
  final Widget track;

  @override
  RenderObjectElement createElement() => _ScrollBarElement(this);

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

enum _ScrollBarSlot {
  upButton,
  downButton,
  handle,
  track,
}

class _ScrollBarElement extends RenderObjectElement {
  _ScrollBarElement(_ScrollBar widget) : super(widget);

  Element? _upButton;
  Element? _downButton;
  Element? _handle;
  Element? _track;

  @override
  _ScrollBar get widget => super.widget as _ScrollBar;

  @override
  RenderScrollBar get renderObject => super.renderObject as RenderScrollBar;

  @override
  void update(_ScrollBar newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChildren(newWidget);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _updateChildren(widget);
  }

  void _updateChildren(_ScrollBar widget) {
    _upButton = updateChild(_upButton, widget.upButton, _ScrollBarSlot.upButton);
    _downButton = updateChild(_downButton, widget.downButton, _ScrollBarSlot.downButton);
    _handle = updateChild(_handle, widget.handle, _ScrollBarSlot.handle);
    _track = updateChild(_track, widget.track, _ScrollBarSlot.track);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_upButton != null) visitor(_upButton!);
    if (_downButton != null) visitor(_downButton!);
    if (_handle != null) visitor(_handle!);
    if (_track != null) visitor(_track!);
  }

  @override
  void insertRenderObjectChild(RenderBox child, _ScrollBarSlot slot) {
    _updateChildSlot(slot, child);
  }

  @override
  void moveRenderObjectChild(RenderObject child, dynamic oldSlot, dynamic newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderBox child, _ScrollBarSlot slot) {
    assert(child.parent == renderObject);
    _updateChildSlot(slot, null);
  }

  void _updateChildSlot(_ScrollBarSlot slot, RenderBox? child) {
    switch (slot) {
      case _ScrollBarSlot.upButton:
        renderObject.upButton = child as _RenderScrollBarButton?;
        break;
      case _ScrollBarSlot.downButton:
        renderObject.downButton = child as _RenderScrollBarButton?;
        break;
      case _ScrollBarSlot.handle:
        renderObject.handle = child as _RenderScrollBarHandle?;
        break;
      case _ScrollBarSlot.track:
        renderObject.track = child as _RenderScrollBarTrack?;
        break;
    }
  }
}

class ScrollBarConstraints extends BoxConstraints {
  const ScrollBarConstraints({
    double minWidth = 0,
    double maxWidth = double.infinity,
    double minHeight = 0,
    double maxHeight = double.infinity,
    this.enabled = true,
    required this.start,
    required this.end,
    required this.value,
    required this.extent,
  }) : super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  ScrollBarConstraints.fromBoxConstraints({
    required BoxConstraints boxConstraints,
    this.enabled = true,
    required this.start,
    required this.end,
    required this.value,
    required this.extent,
  }) : super(
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

class RenderScrollBar extends RenderBox with ListenerNotifier<ScrollBarValueListener> {
  RenderScrollBar({
    Axis orientation = Axis.vertical,
    double unitIncrement = 1,
    double blockIncrement = 1,
    bool enabled = true,
    double start = 0,
    double end = 100,
    double extent = 1,
    double value = 0,
  })  : _orientation = orientation,
        _unitIncrement = unitIncrement,
        _blockIncrement = blockIncrement,
        _enabled = enabled,
        _start = start,
        _end = end,
        _extent = extent,
        _value = value {
    automaticScroller = _AutomaticScroller(scrollBar: this);
  }

  late final _AutomaticScroller automaticScroller;

  late Size _upButtonSize;
  late Size _downButtonSize;
  late Size _handleSize;

  static const double _minimumHandleLength = 31;

  Axis _orientation;
  Axis get orientation => _orientation;
  set orientation(Axis value) {
    if (_orientation == value) return;
    _orientation = value;
    markNeedsLayout();
  }

  _RenderScrollBarButton? _upButton;
  _RenderScrollBarButton? get upButton => _upButton;
  set upButton(_RenderScrollBarButton? value) {
    if (value == _upButton) return;
    if (_upButton != null) dropChild(_upButton!);
    _upButton = value;
    if (_upButton != null) adoptChild(_upButton!);
  }

  _RenderScrollBarButton? _downButton;
  _RenderScrollBarButton? get downButton => _downButton;
  set downButton(_RenderScrollBarButton? value) {
    if (value == _downButton) return;
    if (_downButton != null) dropChild(_downButton!);
    _downButton = value;
    if (_downButton != null) adoptChild(_downButton!);
  }

  _RenderScrollBarHandle? _handle;
  _RenderScrollBarHandle? get handle => _handle;
  set handle(_RenderScrollBarHandle? value) {
    if (value == _handle) return;
    if (_handle != null) dropChild(_handle!);
    _handle = value;
    if (_handle != null) adoptChild(_handle!);
  }

  _RenderScrollBarTrack? _track;
  _RenderScrollBarTrack? get track => _track;
  set track(_RenderScrollBarTrack? value) {
    if (value == _track) return;
    if (_track != null) dropChild(_track!);
    _track = value;
    if (_track != null) adoptChild(_track!);
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
    if (handle!.parentData!.visible) {
      if (orientation == Axis.horizontal) {
        final double handleX = (value * _pixelValueRatio) + _upButtonSize.width - 1;
        handle!.parentData!.offset = Offset(handleX, 1);
      } else {
        final double handleY = (value * _pixelValueRatio) + _upButtonSize.height - 1;
        handle!.parentData!.offset = Offset(1, handleY);
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
    if (_unitIncrement == value) return;
    _unitIncrement = value;
  }

  double _blockIncrement;
  double get blockIncrement => _blockIncrement;
  set blockIncrement(double value) {
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
      double trackWidth = size.width - _upButtonSize.width - _downButtonSize.width + 2;
      numLegalPixelValues = trackWidth - _handleSize.width + 1;
    } else {
      double trackHeight = size.height - _upButtonSize.height - _downButtonSize.height + 2;
      numLegalPixelValues = trackHeight - _handleSize.height + 1;
    }

    return numLegalPixelValues / numLegalRealValues;
  }

  @override
  ScrollBarConstraints get constraints => super.constraints as ScrollBarConstraints;

  _AutomaticScrollerParameters? _getTrackScrollParameters(Offset position) {
    if (!handle!.parentData!.visible) {
      return null;
    }

    // Calculate the direction of the scroll by checking to see if the user
    // pressed the pointer in the area "before" the handle or "after" it.
    final int direction;
    final double realStopValue;

    if (orientation == Axis.horizontal) {
      direction = position.dx < handle!.parentData!.offset.dx ? -1 : 1;
      double pixelStopValue = position.dx - _upButtonSize.width + 1;

      if (direction == 1) {
        // If we're scrolling down, account for the width of the
        // handle in our pixel stop value so that we stop as soon
        // as the *bottom* of the handle reaches our click point
        pixelStopValue -= _handleSize.width;
      }

      realStopValue = pixelStopValue / _pixelValueRatio;
    } else {
      direction = position.dy < handle!.parentData!.offset.dy ? -1 : 1;
      double pixelStopValue = position.dy - _upButtonSize.height + 1;

      if (direction == 1) {
        // If we're scrolling down, account for the height of the
        // handle in our pixel stop value so that we stop as soon
        // as the *bottom* of the handle reaches our click point
        pixelStopValue -= _handleSize.height;
      }

      realStopValue = pixelStopValue / _pixelValueRatio;
    }

    return _AutomaticScrollerParameters(direction, realStopValue);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ScrollBarParentData) child.parentData = _ScrollBarParentData();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    upButton?.attach(owner);
    downButton?.attach(owner);
    handle?.attach(owner);
    track?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    upButton?.detach();
    downButton?.detach();
    handle?.detach();
    track?.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (upButton != null) visitor(upButton!);
    if (downButton != null) visitor(downButton!);
    if (handle != null) visitor(handle!);
    if (track != null) visitor(track!);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (orientation == Axis.horizontal) {
      return math.max(
        upButton!.getMinIntrinsicHeight(width),
        downButton!.getMinIntrinsicHeight(width),
      );
    } else {
      return upButton!.getMinIntrinsicHeight(width) + downButton!.getMinIntrinsicHeight(width);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (orientation == Axis.horizontal) {
      return upButton!.getMinIntrinsicWidth(height) + downButton!.getMinIntrinsicWidth(height);
    } else {
      return math.max(
        upButton!.getMinIntrinsicWidth(height),
        downButton!.getMinIntrinsicWidth(height),
      );
    }
  }

  @override
  void performLayout() {
    assert(constraints.isTight);
    size = constraints.smallest;
    _enabled = constraints.enabled;
    upButton!.enabled = constraints.enabled;
    downButton!.enabled = constraints.enabled;
    _start = constraints.start;
    _end = constraints.end;
    _updateValue(constraints.value); // notifies listeners
    _extent = constraints.extent;

    double maxLegalRealValue = end - extent;
    double numLegalRealValues = maxLegalRealValue - start + 1;
    double extentPercentage = extent / (end - start);

    track!.layout(constraints);
    track!.parentData!.visible = true;

    if (orientation == Axis.horizontal) {
      upButton!.layout(BoxConstraints.tightFor(height: size.height), parentUsesSize: true);
      upButton!.parentData!.visible = true;
      upButton!.parentData!.offset = Offset.zero;

      downButton!.layout(BoxConstraints.tightFor(height: size.height), parentUsesSize: true);
      downButton!.parentData!.visible = true;
      downButton!.parentData!.offset = Offset(size.width - downButton!.size.width, 0);

      if (size.width < upButton!.size.width + downButton!.size.width) {
        upButton!.parentData!.visible = false;
        downButton!.parentData!.visible = false;
      }

      if (enabled) {
        // Calculate the handle width first, as it dictates how much
        // room is left to represent the range of legal values. Note
        // that the handle may overlap each scroll button by 1px so
        // that its borders merge into the borders of the scroll buttons
        double availableWidth = size.width - upButton!.size.width - downButton!.size.width + 2;
        double handleWidth = math.max(_minimumHandleLength, (extentPercentage * availableWidth));

        // Calculate the position of the handle by calculating the
        // scale that maps logical value to pixel value
        double numLegalPixelValues = availableWidth - handleWidth + 1;
        double valueScale = numLegalPixelValues / numLegalRealValues;
        double handleX = (value * valueScale) + upButton!.size.width - 1;

        if (handleWidth > availableWidth) {
          // If we can't fit the handle, we hide it
          handle!.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
          handle!.parentData!.visible = false;
        } else {
          handle!.layout(BoxConstraints.tightFor(width: handleWidth, height: size.height - 2),
              parentUsesSize: true);
          handle!.parentData!.visible = true;
          handle!.parentData!.offset = Offset(handleX, 1);
        }
      } else {
        handle!.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
        handle!.parentData!.visible = false;
      }
    } else {
      upButton!.layout(BoxConstraints.tightFor(width: size.width), parentUsesSize: true);
      upButton!.parentData!.visible = true;
      upButton!.parentData!.offset = Offset.zero;

      downButton!.layout(BoxConstraints.tightFor(width: size.width), parentUsesSize: true);
      downButton!.parentData!.visible = true;
      downButton!.parentData!.offset = Offset(0, size.height - downButton!.size.height);

      if (size.height < upButton!.size.height + downButton!.size.height) {
        upButton!.parentData!.visible = false;
        downButton!.parentData!.visible = false;
      }

      if (enabled) {
        // Calculate the handle height first, as it dictates how much
        // room is left to represent the range of legal values. Note
        // that the handle may overlap each scroll button by 1px so
        // that its borders merge into the borders of the scroll buttons
        double availableHeight = size.height - upButton!.size.height - downButton!.size.height + 2;
        double handleHeight = math.max(_minimumHandleLength, (extentPercentage * availableHeight));

        // Calculate the position of the handle by calculating the
        // scale maps logical value to pixel value
        double numLegalPixelValues = availableHeight - handleHeight + 1;
        double valueScale = numLegalPixelValues / numLegalRealValues;
        double handleY = (value * valueScale) + upButton!.size.height - 1;

        if (handleHeight > availableHeight) {
          // If we can't fit the handle, we hide it
          handle!.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
          handle!.parentData!.visible = false;
        } else {
          handle!.layout(BoxConstraints.tightFor(width: size.width - 2, height: handleHeight),
              parentUsesSize: true);
          handle!.parentData!.visible = true;
          handle!.parentData!.offset = Offset(1, handleY);
        }
      } else {
        handle!.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
        handle!.parentData!.visible = false;
      }
    }

    _upButtonSize = upButton!.size;
    _downButtonSize = downButton!.size;
    _handleSize = handle!.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (RenderBox child in <RenderBox>[track!, upButton!, downButton!, handle!]) {
      final _ScrollBarParentData childParentData = child.parentData as _ScrollBarParentData;
      if (childParentData.visible) {
        context.paintChild(child, childParentData.offset + offset);
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (RenderBox child in <RenderBox>[upButton!, downButton!, handle!, track!]) {
      final _ScrollBarParentData childParentData = child.parentData as _ScrollBarParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }

    return false;
  }

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

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> result = <DiagnosticsNode>[];
    void add(RenderBox? child, String name) {
      if (child != null) result.add(child.toDiagnosticsNode(name: name));
    }

    add(upButton, 'upButton');
    add(downButton, 'downButton');
    add(handle, 'handle');
    add(track, 'track');
    return result;
  }
}

class _ScrollBarParentData extends ContainerBoxParentData<RenderBox> {
  /// Whether the child should be painted.
  bool visible = false;

  @override
  String toString() => '${super.toString()}; visible=$visible';
}

typedef ScrollBarValueChangedHandler = void Function(
  RenderScrollBar scrollBar,
  double previousValue,
);

class ScrollBarValueListener {
  const ScrollBarValueListener({
    required this.valueChanged,
  });

  /// Called when a scroll bar's value has changed.
  final ScrollBarValueChangedHandler valueChanged;
}

class _RenderScrollBarButton extends RenderBox implements MouseTrackerAnnotation {
  _RenderScrollBarButton({
    this.orientation = Axis.vertical,
    this.direction = 1,
  });

  final Axis orientation;
  final int direction;
  late final LongPressGestureRecognizer _longPress;

  static const double _length = 15;

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    parent!.automaticScroller.stop();
    _enabled = value;
    markNeedsPaint();
  }

  bool _highlighted = false;
  bool get highlighted => _highlighted;
  set highlighted(bool value) {
    if (_highlighted == value) return;
    _highlighted = value;
    markNeedsPaint();
  }

  bool _pressed = false;
  bool get pressed => _pressed;
  set pressed(bool value) {
    if (_pressed == value) return;
    _pressed = value;
    markNeedsPaint();
  }

  void _onEnter(PointerEnterEvent event) {
    highlighted = true;
  }

  void _onExit(PointerExitEvent event) {
    parent!.automaticScroller.stop();
    highlighted = false;
    pressed = false;
  }

  void _handleLongPressDown(LongPressDownDetails details) {
    parent!.automaticScroller.scroll(direction, _ScrollType.unit);
    pressed = true;
  }

  void _handleLongPressCancel() {
    parent!.automaticScroller.stop();
    pressed = false;
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    parent!.automaticScroller.start(direction, _ScrollType.unit);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    parent!.automaticScroller.stop();
    pressed = false;
  }

  @override
  RenderScrollBar? get parent => super.parent as RenderScrollBar?;

  @override
  _ScrollBarParentData? get parentData => super.parentData as _ScrollBarParentData?;

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => _onEnter;

  @override
  PointerExitEventListener? get onExit => _onExit;

  @override
  bool get validForMouseTracker => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _longPress = LongPressGestureRecognizer(debugOwner: this, duration: _AutomaticScroller._delay)
      ..onLongPressDown = _handleLongPressDown
      ..onLongPressCancel = _handleLongPressCancel
      ..onLongPressStart = _handleLongPressStart
      ..onLongPressEnd = _handleLongPressEnd;
  }

  @override
  void detach() {
    _longPress.dispose();
    super.detach();
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (!enabled) return;
    if (event is PointerDownEvent) return _longPress.addPointer(event);
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;

  @override
  double computeMinIntrinsicHeight(double width) => _length;

  @override
  double computeMinIntrinsicWidth(double height) => _length;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(Size.square(_length));
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
  }
}

class _RenderScrollBarHandle extends RenderBox implements MouseTrackerAnnotation {
  _RenderScrollBarHandle({required this.orientation});

  final Axis orientation;
  late final PanGestureRecognizer _pan;

  bool _highlighted = false;
  bool get highlighted => _highlighted;
  set highlighted(bool value) {
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

  double? _dragOffset;

  void _handlePanDown(DragDownDetails details) {
    _dragOffset = orientation == Axis.horizontal
        ? details.localPosition.dx - parentData!.offset.dx + parent!._upButtonSize.width - 1
        : details.localPosition.dy - parentData!.offset.dy + parent!._upButtonSize.height - 1;
  }

  void _handlePanCancel() {
    _resetPan();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dragOffset != null) {
      // Calculate the new scroll bar value
      double pixelValue;
      if (orientation == Axis.horizontal) {
        pixelValue = details.localPosition.dx - _dragOffset!;
      } else {
        pixelValue = details.localPosition.dy - _dragOffset!;
      }

      double scrollBarValue = (pixelValue / parent!._pixelValueRatio);
      scrollBarValue = math.min(math.max(scrollBarValue, 0), parent!.end - parent!.extent);
      parent!.value = scrollBarValue;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _resetPan();
  }

  void _resetPan() {
    _dragOffset = null;
    markNeedsPaint();
  }

  @override
  RenderScrollBar? get parent => super.parent as RenderScrollBar?;

  @override
  _ScrollBarParentData? get parentData => super.parentData as _ScrollBarParentData?;

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => _onEnter;

  @override
  PointerExitEventListener? get onExit => _onExit;

  @override
  bool get validForMouseTracker => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _pan = PanGestureRecognizer(debugOwner: this)
      ..onDown = _handlePanDown
      ..onCancel = _handlePanCancel
      ..onUpdate = _handlePanUpdate
      ..onEnd = _handlePanEnd;
  }

  @override
  void detach() {
    _pan.dispose();
    super.detach();
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) return _pan.addPointer(event);
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.smallest;

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
  }
}

class _RenderScrollBarTrack extends RenderBox implements MouseTrackerAnnotation {
  _RenderScrollBarTrack({required this.orientation});

  final Axis orientation;
  late final LongPressGestureRecognizer _longPress;

  _AutomaticScrollerParameters? _scroll;

  void _handleLongPressDown(LongPressDownDetails details) {
    _scroll = parent._getTrackScrollParameters(details.localPosition + parentData!.offset);
    if (_scroll != null) {
      parent.automaticScroller.scroll(_scroll!.direction, _ScrollType.block);
    }
  }

  void _handleLongPressCancel() {
    parent.automaticScroller.stop();
    _scroll = null;
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (_scroll != null) {
      parent.automaticScroller.start(_scroll!.direction, _ScrollType.block, _scroll!.stopValue);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    parent.automaticScroller.stop();
    _scroll = null;
  }

  void _handleExit(PointerExitEvent event) {
    parent.automaticScroller.stop();
  }

  @override
  RenderScrollBar get parent => super.parent as RenderScrollBar;

  @override
  _ScrollBarParentData? get parentData => super.parentData as _ScrollBarParentData?;

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => null;

  @override
  PointerExitEventListener? get onExit => _handleExit;

  @override
  bool get validForMouseTracker => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _longPress = LongPressGestureRecognizer(debugOwner: this, duration: _AutomaticScroller._delay)
      ..onLongPressDown = _handleLongPressDown
      ..onLongPressCancel = _handleLongPressCancel
      ..onLongPressStart = _handleLongPressStart
      ..onLongPressEnd = _handleLongPressEnd;
  }

  @override
  void detach() {
    _longPress.dispose();
    super.detach();
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) return _longPress.addPointer(event);
  }

  @override
  bool hitTestSelf(ui.Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.smallest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint bgPaint = Paint()..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff999999);
    const List<Color> colors = <Color>[Color(0xffc5c3bc), Color(0xffdedcd4)];
    switch (orientation) {
      case Axis.horizontal:
        bgPaint.shader = ui.Gradient.linear(
          offset + Offset(0, 1.5),
          offset + Offset(0, size.height - 1.5),
          colors,
        );
        context.canvas.drawRect(offset & size, bgPaint);
        context.canvas.drawLine(
          offset + Offset(0, 0.5),
          offset + Offset(size.width, 0.5),
          borderPaint,
        );
        context.canvas.drawLine(
          offset + Offset(0, size.height - 0.5),
          offset + Offset(size.width, size.height - 0.5),
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
          offset + Offset(0.5, 0),
          offset + Offset(0.5, size.height),
          borderPaint,
        );
        context.canvas.drawLine(
          offset + Offset(size.width - 0.5, 0),
          offset + Offset(size.width - 0.5, size.height),
          borderPaint,
        );
        break;
    }
  }
}

enum _ScrollType {
  unit,
  block,
}

class _ScrollButtonPainter extends CustomPainter {
  const _ScrollButtonPainter({
    required this.enabled,
    required this.pressed,
    required this.highlighted,
    required this.orientation,
    required this.arrow,
  });

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
    required Axis orientation,
    required int direction,
  }) {
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
    required this.highlighted,
    required this.orientation,
  });

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

@immutable
class _AutomaticScrollerParameters {
  const _AutomaticScrollerParameters(this.direction, this.stopValue);

  final int direction;
  final double stopValue;
}

class _AutomaticScroller {
  _AutomaticScroller({
    required this.scrollBar,
  });

  final RenderScrollBar scrollBar;

  Timer? scheduledScrollTimer;

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
  void start(int direction, _ScrollType incrementType, [double? stopValue]) {
    if (scheduledScrollTimer != null) {
      throw StateError('Already running');
    }

    scheduledScrollTimer = Timer.periodic(_interval, (Timer timer) {
      scroll(direction, incrementType, stopValue);
    });

    // We initially scroll once to register that we've started
    scroll(direction, incrementType, stopValue);
  }

  /// Stops any automatic scrolling in progress.
  void stop() {
    if (scheduledScrollTimer != null) {
      scheduledScrollTimer!.cancel();
      scheduledScrollTimer = null;
    }
  }

  void scroll(int direction, _ScrollType incrementType, [double? stopValue]) {
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

      if (stopValue != null && newValue < stopValue) {
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

      if (stopValue != null && newValue > stopValue) {
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
