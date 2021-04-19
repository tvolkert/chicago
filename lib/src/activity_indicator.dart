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

import 'visibility_aware.dart';

const Duration _duration = Duration(milliseconds: 1200);
const double _defaultSize = 128;
const int _spokes = 12;
const Color _defaultColor = Color(0xff000000);

class ActivityIndicator extends StatefulWidget {
  const ActivityIndicator({
    Key? key,
    this.color = _defaultColor,
    this.semanticLabel = 'Loading',
  }) : super(key: key);

  final Color color;
  final String semanticLabel;

  @override
  _ActivityIndicatorState createState() => _ActivityIndicatorState();
}

class _ActivityIndicatorState extends State<ActivityIndicator>
    with SingleTickerProviderStateMixin<ActivityIndicator> {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: RepaintBoundary(
        child: _RawActivityIndicator(
          color: widget.color,
          controller: _controller,
        ),
      ),
    );
  }
}

class _RawActivityIndicator extends LeafRenderObjectWidget {
  const _RawActivityIndicator({
    Key? key,
    required this.color,
    required this.controller,
  }) : super(key: key);

  final Color color;
  final AnimationController controller;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRawActivityIndicator(
      color: color,
      controller: controller,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderRawActivityIndicator renderObject) {
    renderObject
      ..color = color
      ..controller = controller;
  }
}

class _RenderRawActivityIndicator extends RenderBox with VisibilityAwareMixin {
  _RenderRawActivityIndicator({
    Color color = _defaultColor,
    required AnimationController controller,
  })  : _color = color,
        _colors = _splitColor(color),
        _controller = controller {
    assert(!_controller.isAnimating);
  }

  Color _color;
  List<Color> _colors = <Color>[];
  Color get color => _color;
  set color(Color value) {
    if (value != _color) {
      _color = value;
      _colors = _splitColor(_color);
      markNeedsPaint();
    }
  }

  AnimationController _controller;
  AnimationController get controller => _controller;
  set controller(AnimationController value) {
    if (value != _controller) {
      AnimationController oldController = _controller;
      _controller = value;
      if (attached) {
        oldController.removeListener(markNeedsPaint);
        _controller.addListener(markNeedsPaint);
        if (isVisible) {
          oldController.stop();
          _controller.repeat();
        }
      }
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(markNeedsPaint);
    assert(!controller.isAnimating);
    if (isVisible) {
      _controller.repeat();
    }
  }

  @override
  void detach() {
    _controller.removeListener(markNeedsPaint);
    if (isVisible) {
      assert(controller.isAnimating);
      _controller.stop();
    }
    super.detach();
  }

  @override
  void handleIsVisibleChanged() {
    if (attached) {
      if (isVisible) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _defaultSize;

  @override
  double computeMaxIntrinsicWidth(double height) => _defaultSize;

  @override
  double computeMinIntrinsicHeight(double width) => _defaultSize;

  @override
  double computeMaxIntrinsicHeight(double width) => _defaultSize;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    double size = math.min(constraints.maxWidth, constraints.maxHeight);
    if (size.isInfinite) {
      size = _defaultSize;
    }
    return constraints.constrain(Size.square(size));
  }

  static List<Color> _splitColor(Color color) {
    return List<Color>.generate(_spokes, (int index) {
      final int alpha = (255 * index / _spokes).floor();
      return color.withAlpha(alpha);
    });
  }

  static final Tween<double> _rotationTween = _StepTween(
    begin: 0,
    end: 2 * math.pi,
    step: 2 * math.pi / _spokes,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    canvas.translate(offset.dx, offset.dy);

    if (size.width > size.height) {
      canvas.translate((size.width - size.height) / 2, 0);
      final double scale = size.height / _defaultSize;
      canvas.scale(scale);
    } else if (size.width != _defaultSize || size.height != _defaultSize) {
      canvas.translate(0, (size.height - size.width) / 2);
      final double scale = size.width / _defaultSize;
      canvas.scale(scale);
    }

    final double rotationValue = _rotationTween.evaluate(_controller);
    canvas.translate(_defaultSize / 2, _defaultSize / 2);
    canvas.rotate(rotationValue);

    final double increment = 2 * math.pi / _spokes;
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _spokes; i++) {
      paint.color = _colors[i];
      canvas.drawRRect(RRect.fromLTRBR(24, -4, 56, 4, Radius.circular(4)), paint);
      canvas.rotate(increment);
    }
  }
}

class _StepTween extends Tween<double> {
  _StepTween({
    required double begin,
    required double end,
    required this.step,
  }) : super(begin: begin, end: end);

  final double step;

  @override
  @protected
  double lerp(double t) {
    double value = super.lerp(t);
    int steps = (value / step).floor();
    return steps * step;
  }
}
