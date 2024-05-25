// Licensed to the Apache Software Foundation (ASF) under one or more
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

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'focus_indicator.dart';
import 'hover_builder.dart';
import 'widget_surveyor.dart';

typedef SpinnerItemBuilder = Widget Function(BuildContext context, int index, bool isEnabled);

class _Worker {
  _Worker(this._spinner, this._controller);

  Spinner _spinner;
  SpinnerController _controller;
  Timer? _timer;

  static const Duration _delay = Duration(milliseconds: 400);
  static const Duration _period = Duration(milliseconds: 30);

  void start(int direction) {
    if (_timer != null) {
      // Already running
      return;
    }

    // Wait a timeout period, then begin rapidly spinning
    _timer = Timer(_delay, () {
      _timer = Timer.periodic(_period, (Timer timer) {
        assert(() {
          if (_controller._debugDisposed) {
            stop();
            throw FlutterError(
              'A ${_controller.runtimeType} was used after being disposed.\n'
              'Once you have called dispose() on an object, it can no longer be used.',
            );
          }
          return true;
        }());
        spin(direction);
      });
    });

    // We initially spin once to register that we've started
    spin(direction);
  }

  void stop() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void spin(int direction) {
    final bool circular = _spinner.isCircular;
    final int length = _spinner.length;

    if (direction > 0) {
      if (_controller.selectedIndex < length - 1) {
        _controller.selectedIndex++;
      } else if (circular) {
        _controller.selectedIndex = 0;
      } else {
        stop();
      }
    } else {
      if (_controller.selectedIndex > 0) {
        _controller.selectedIndex--;
      } else if (circular) {
        _controller.selectedIndex = length - 1;
      } else {
        stop();
      }
    }
  }

  void _didUpdateWidget(Spinner spinner, SpinnerController controller) {
    this._spinner = spinner;
    this._controller = controller;
  }
}

class SpinnerController extends ChangeNotifier {
  SpinnerController();

  SpinnerController._withIndex(this._index);

  bool _debugDisposed = false;
  void dispose() {
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    super.dispose();
  }

  int _index = -1;
  int get selectedIndex => _index;
  set selectedIndex(int value) {
    assert(value >= 0);
    _index = value;
    notifyListeners();
  }
}

class Spinner extends StatefulWidget {
  const Spinner({
    Key? key,
    required this.length,
    required this.itemBuilder,
    this.controller,
    this.isEnabled = true,
    this.isCircular = false,
    this.sizeToContent = false,
    this.semanticLabel,
  }) : super(key: key);

  final int length;
  final SpinnerItemBuilder itemBuilder;
  final SpinnerController? controller;
  final bool isEnabled;
  final bool isCircular;
  final bool sizeToContent;
  final String? semanticLabel;

  static Widget defaultItemBuilder(BuildContext context, String value) {
    return Builder(
      builder: (BuildContext context) {
        final TextStyle style = DefaultTextStyle.of(context).style;
        final TextDirection textDirection = Directionality.of(context);
        return Padding(
          padding: EdgeInsets.all(2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              textDirection: textDirection,
              style: style,
            ),
          ),
        );
      },
    );
  }

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
  FocusNode? _focusNode;
  bool _isFocused = false;
  SpinnerController? _controller;
  late _Worker _worker;
  int _index = -1;
  double? _contentWidth;

  SpinnerController get controller => widget.controller ?? _controller!;

  int _boundsCheckIndex() {
    return controller.selectedIndex < widget.length ? controller.selectedIndex : -1;
  }

  void _handleSelectedIndexUpdated() {
    setState(() {
      _index = _boundsCheckIndex();
    });
  }

  void _updateContentWidth() {
    if (!widget.sizeToContent) {
      _contentWidth = null;
    } else {
      final TextDirection textDirection = Directionality.of(context);
      final TextStyle style = DefaultTextStyle.of(context).style;
      const WidgetSurveyor surveyor = WidgetSurveyor();
      double maxWidth = 0;
      for (int i = 0; i < widget.length; i++) {
        Widget item = Directionality(
          textDirection: textDirection,
          child: DefaultTextStyle(
            style: style,
            child: widget.itemBuilder(context, i, widget.isEnabled),
          ),
        );
        final Size itemSize = surveyor.measureWidget(item);
        maxWidth = math.max(maxWidth, itemSize.width);
      }
      _contentWidth = maxWidth;
    }
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    assert(widget.isEnabled);
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (event is KeyDownEvent) {
        _worker.start(-1);
      } else {
        _worker.stop();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (event is KeyDownEvent) {
        _worker.start(1);
      } else {
        _worker.stop();
      }
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }

  void _requestFocus() {
    _focusNode!.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(canRequestFocus: widget.isEnabled);
    if (widget.controller == null) {
      _controller = SpinnerController();
    }
    controller.addListener(_handleSelectedIndexUpdated);
    _worker = _Worker(widget, controller);
    _index = _boundsCheckIndex();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateContentWidth();
  }

  @override
  void didUpdateWidget(Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (widget.controller == null) {
        assert(oldWidget.controller != null);
        assert(_controller == null);
        _controller = SpinnerController._withIndex(oldWidget.controller!.selectedIndex);
      }
      if (oldWidget.controller == null) {
        assert(widget.controller != null);
        assert(_controller != null);
        _controller!.dispose();
        _controller = null;
      }
    }
    _focusNode!.canRequestFocus = widget.isEnabled;
    _worker._didUpdateWidget(widget, controller);
    _index = _boundsCheckIndex();
    _updateContentWidth();
  }

  @override
  void dispose() {
    controller.removeListener(_handleSelectedIndexUpdated);
    if (_controller != null) {
      assert(widget.controller == null);
      _controller!.dispose();
    }
    _focusNode?.dispose();
    _focusNode = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.itemBuilder(context, _index, widget.isEnabled);
    if (widget.sizeToContent) {
      content = SizedBox(
        width: _contentWidth,
        child: content,
      );
    }
    content = GestureDetector(
      onTap: widget.isEnabled ? _requestFocus : null,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: widget.isEnabled ? _handleKey : null,
        onFocusChange: _handleFocusChange,
        child: Semantics(
          enabled: widget.isEnabled,
          focusable: widget.isEnabled,
          focused: _focusNode!.hasFocus,
          label: widget.semanticLabel ?? 'Spinner',
          onIncrease: () => _worker.spin(1),
          onDecrease: () => _worker.spin(-1),
          child: Padding(
            padding: EdgeInsets.all(1),
            child: FocusIndicator(
              isFocused: _isFocused,
              child: content,
            ),
          ),
        ),
      ),
    );

    content = ColoredBox(
      color: const Color(0xffffffff),
      child: content,
    );

    return _RawSpinner(
      content: content,
      upButton: _SpinnerButton(
        worker: _worker,
        direction: 1,
        onTapDown: _requestFocus,
        isEnabled: widget.isEnabled,
      ),
      downButton: _SpinnerButton(
        worker: _worker,
        direction: -1,
        onTapDown: _requestFocus,
        isEnabled: widget.isEnabled,
      ),
    );
  }
}

class _SpinnerButton extends StatefulWidget {
  const _SpinnerButton({
    Key? key,
    required this.worker,
    required this.direction,
    required this.onTapDown,
    required this.isEnabled,
  }) : super(key: key);

  final _Worker worker;
  final int direction;
  final VoidCallback onTapDown;
  final bool isEnabled;

  @override
  _SpinnerButtonState createState() => _SpinnerButtonState();
}

class _SpinnerButtonState extends State<_SpinnerButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    widget.worker.start(widget.direction);
    widget.onTapDown();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
    widget.worker.stop();
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
    widget.worker.stop();
  }

  Widget _buildButton(bool hover) {
    return CustomPaint(
      size: const Size.fromWidth(11),
      painter: _SpinnerButtonPainter(
        direction: widget.direction,
        isHover: hover,
        isPressed: _pressed,
        isEnabled: widget.isEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return _buildButton(false);
    }
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: HoverBuilder(
        builder: (BuildContext context, bool hover) {
          return _buildButton(hover);
        },
      ),
    );
  }
}

class _SpinnerButtonPainter extends CustomPainter {
  const _SpinnerButtonPainter({
    required this.direction,
    required this.isHover,
    required this.isPressed,
    required this.isEnabled,
  });

  final int direction;
  final bool isHover;
  final bool isPressed;
  final bool isEnabled;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // Paint the background.
    if (isPressed) {
      ui.Paint paint = ui.Paint()..color = const Color(0x80000000);
      canvas.drawRect(Offset.zero & size, paint);
    } else if (isHover) {
      ui.Paint paint = ui.Paint()..color = const Color(0x40000000);
      canvas.drawRect(Offset.zero & size, paint);
    }

    // Paint the image.
    canvas.translate((size.width - 5) / 2, (size.height - 5) / 2);
    if (direction > 0) {
      ui.Path path = ui.Path()
        ..moveTo(0, 4)
        ..lineTo(2.5, 1)
        ..lineTo(5, 4);
      ui.Paint paint = ui.Paint()..color = isEnabled ? const Color(0xff000000) : const Color(0xff999999);
      canvas.drawPath(path, paint);
    } else {
      ui.Path path = ui.Path()
        ..moveTo(0, 1)
        ..lineTo(2.5, 4)
        ..lineTo(5, 1);
      ui.Paint paint = ui.Paint()..color = isEnabled ? const Color(0xff000000) : const Color(0xff999999);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SpinnerButtonPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.isHover != isHover ||
        oldDelegate.isPressed != isPressed;
  }
}

class _RawSpinner extends RenderObjectWidget {
  const _RawSpinner({
    Key? key,
    required this.content,
    required this.upButton,
    required this.downButton,
  }) : super(key: key);

  final Widget content;
  final Widget upButton;
  final Widget downButton;

  @override
  RenderObjectElement createElement() => _SpinnerElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSpinner();
}

enum _SpinnerSlot {
  content,
  upButton,
  downButton,
}

class _SpinnerElement extends RenderObjectElement {
  _SpinnerElement(_RawSpinner widget) : super(widget);

  Element? _content;
  Element? _upButton;
  Element? _downButton;

  @override
  _RawSpinner get widget => super.widget as _RawSpinner;

  @override
  _RenderSpinner get renderObject => super.renderObject as _RenderSpinner;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_content != null) visitor(_content!);
    if (_upButton != null) visitor(_upButton!);
    if (_downButton != null) visitor(_downButton!);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _content = updateChild(_content, widget.content, _SpinnerSlot.content);
    _upButton = updateChild(_upButton, widget.upButton, _SpinnerSlot.upButton);
    _downButton = updateChild(_downButton, widget.downButton, _SpinnerSlot.downButton);
  }

  @override
  void insertRenderObjectChild(RenderBox child, _SpinnerSlot slot) {
    switch (slot) {
      case _SpinnerSlot.content:
        renderObject.content = child;
        break;
      case _SpinnerSlot.upButton:
        renderObject.upButton = child;
        break;
      case _SpinnerSlot.downButton:
        renderObject.downButton = child;
        break;
    }
  }

  @override
  void moveRenderObjectChild(RenderObject _, _SpinnerSlot? __, _SpinnerSlot? ___) {
    assert(false);
  }

  @override
  void update(RenderObjectWidget newWidget) {
    super.update(newWidget);
    _content = updateChild(_content, widget.content, _SpinnerSlot.content);
    _upButton = updateChild(_upButton, widget.upButton, _SpinnerSlot.upButton);
    _downButton = updateChild(_downButton, widget.downButton, _SpinnerSlot.downButton);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _content || child == _upButton);
    if (child == _content) {
      _content = null;
    } else if (child == _upButton) {
      _upButton = null;
    } else if (child == _downButton) {
      _downButton = null;
    }
    super.forgetChild(child);
  }

  @override
  void removeRenderObjectChild(RenderBox child, _SpinnerSlot? slot) {
    assert(child == renderObject.content ||
        child == renderObject.upButton ||
        child == renderObject.downButton);
    switch (slot) {
      case _SpinnerSlot.content:
        renderObject.content = null;
        break;
      case _SpinnerSlot.upButton:
        renderObject.upButton = null;
        break;
      case _SpinnerSlot.downButton:
        renderObject.downButton = null;
        break;
      case null:
        assert(false);
    }
  }
}

class _RenderSpinner extends RenderBox {
  static const Color baseColor = Color(0xffdddcd5);
  static final Color bevelColor = brighten(baseColor);

  RenderBox? _content;
  RenderBox? get content => _content;
  set content(RenderBox? value) {
    if (value == _content) return;
    if (_content != null) dropChild(_content!);
    _content = value;
    if (_content != null) adoptChild(_content!);
  }

  RenderBox? _upButton;
  RenderBox? get upButton => _upButton;
  set upButton(RenderBox? value) {
    if (value == _upButton) return;
    if (_upButton != null) dropChild(_upButton!);
    _upButton = value;
    if (_upButton != null) adoptChild(_upButton!);
  }

  RenderBox? _downButton;
  RenderBox? get downButton => _downButton;
  set downButton(RenderBox? value) {
    if (value == _downButton) return;
    if (_downButton != null) dropChild(_downButton!);
    _downButton = value;
    if (_downButton != null) adoptChild(_downButton!);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (content != null) content!.attach(owner);
    if (upButton != null) upButton!.attach(owner);
    if (downButton != null) downButton!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (content != null) content!.detach();
    if (upButton != null) upButton!.detach();
    if (downButton != null) downButton!.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (content != null) visitor(content!);
    if (upButton != null) visitor(upButton!);
    if (downButton != null) visitor(downButton!);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (RenderBox? child in [downButton, upButton, content]) {
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
  double computeMinIntrinsicWidth(double height) => computeMaxIntrinsicWidth(height);

  /// Intrinsic width is the sum of our maximum button width plus the content
  /// width, plus the border.
  @override
  double computeMaxIntrinsicWidth(double height) {
    // Border thickness (left, right, and in between the content & the buttons)
    double width = 3;
    final double buttonHeightConstraint = (height - 3) / 2;
    width += math.max(upButton!.getMaxIntrinsicWidth(buttonHeightConstraint),
        downButton!.getMaxIntrinsicWidth(buttonHeightConstraint));
    final double contentHeightConstraint = math.max(height - 2, 0);
    width += content!.getMaxIntrinsicWidth(contentHeightConstraint);
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) => computeMaxIntrinsicHeight(width);

  /// Intrinsic height is the maximum of the button height and the
  /// builder's intrinsic height (plus the border), where button height is
  /// defined as the larger of the two buttons' intrinsic height, doubled.
  @override
  double computeMaxIntrinsicHeight(double width) {
    final double upButtonHeight = upButton!.getMaxIntrinsicHeight(double.infinity);
    final double downButtonHeight = downButton!.getMaxIntrinsicHeight(double.infinity);
    final double height = math.max(upButtonHeight, downButtonHeight) * 2;

    if (width.isFinite) {
      // Subtract the button and border width from width constraint.
      double buttonWidth = math.max(upButton!.getMaxIntrinsicWidth(double.infinity),
          downButton!.getMaxIntrinsicWidth(double.infinity));
      width = math.max(width - buttonWidth - 2, 0);
    }

    return math.max(height, content!.getMaxIntrinsicHeight(width)) + 1;
  }

  @override
  double? computeDistanceToActualBaseline(ui.TextBaseline baseline) {
    super.computeDistanceToActualBaseline(baseline);
    double? result = content!.getDistanceToActualBaseline(baseline);
    if (result != null) {
      result += 1;
    }
    return result;
  }

  @override
  void performLayout() {
    final double buttonWidth = math.min(
      upButton!.getMaxIntrinsicWidth(double.infinity),
      math.max(constraints.maxWidth - 3, 0),
    );
    final BoxConstraints contentConstraints = constraints.deflate(
      EdgeInsets.only(left: buttonWidth + 3, top: 2),
    );
    content!.layout(contentConstraints, parentUsesSize: true);
    BoxParentData contentParentData = content!.parentData as BoxParentData;
    contentParentData.offset = Offset(1, 1);

    final double buttonHeight = (content!.size.height - 1) / 2;
    BoxConstraints buttonConstraints = BoxConstraints.tightFor(
      width: buttonWidth,
      height: buttonHeight,
    );
    upButton!.layout(buttonConstraints);
    downButton!.layout(buttonConstraints);

    size = constraints.constrain(Size(
      content!.size.width + buttonWidth + 3,
      content!.size.height + 2,
    ));

    BoxParentData upButtonParentData = upButton!.parentData as BoxParentData;
    upButtonParentData.offset = Offset(size.width - buttonWidth - 1, 1);

    BoxParentData downButtonParentData = downButton!.parentData as BoxParentData;
    downButtonParentData.offset = Offset(size.width - buttonWidth - 1, buttonHeight + 2);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(content != null);
    assert(upButton != null);
    assert(downButton != null);

    BoxParentData contentParentData = content!.parentData as BoxParentData;
    BoxParentData upButtonParentData = upButton!.parentData as BoxParentData;
    BoxParentData downButtonParentData = downButton!.parentData as BoxParentData;

    final double buttonWidth = upButton!.size.width;
    final double buttonHeight = upButton!.size.height;
    final Offset upButtonOffset = offset + upButtonParentData.offset;

    ui.Paint bgPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        upButton!.size.topCenter(upButtonOffset),
        upButton!.size.bottomCenter(upButtonOffset),
        <Color>[bevelColor, baseColor],
      );
    final Rect bgRect = Rect.fromLTWH(
      offset.dx + upButtonParentData.offset.dx,
      offset.dy,
      buttonWidth,
      size.height,
    );
    context.canvas.drawRect(bgRect, bgPaint);

    context.paintChild(content!, offset + contentParentData.offset);
    context.paintChild(upButton!, upButtonOffset);
    context.paintChild(downButton!, offset + downButtonParentData.offset);

    ui.Paint paint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff999999);
    context.canvas
        .drawRect(Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1).shift(offset), paint);
    context.canvas.drawLine(offset + Offset(size.width - buttonWidth - 1.5, 0.5),
        offset + Offset(size.width - buttonWidth - 1.5, size.height - 1), paint);
    context.canvas.drawLine(offset + Offset(size.width - buttonWidth - 1.5, buttonHeight + 1.5),
        offset + Offset(size.width - 1, buttonHeight + 1.5), paint);
  }

  @override
  void redepthChildren() {
    if (content != null) redepthChild(content!);
    if (upButton != null) redepthChild(upButton!);
    if (downButton != null) redepthChild(downButton!);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return <DiagnosticsNode>[
      if (content != null) content!.toDiagnosticsNode(name: 'content'),
      if (upButton != null) upButton!.toDiagnosticsNode(name: 'upButton'),
      if (downButton != null) downButton!.toDiagnosticsNode(name: 'downButton'),
    ];
  }
}
