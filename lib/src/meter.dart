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

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';

class Meter extends SingleChildRenderObjectWidget {
  const Meter({
    Key? key,
    required this.percentage,
    this.fillColor = const Color(0xff3c77b2),
    this.gridFrequency = 0.25,
    Widget? child,
  }) : super(key: key, child: child);

  Meter.simple({
    Key? key,
    required this.percentage,
    this.fillColor = const Color(0xff3c77b2),
    this.gridFrequency = 0.25,
    String? text,
  }) : super(key: key, child: _textToChild(text));

  final double percentage;
  final Color fillColor;
  final double gridFrequency;

  static Widget? _textToChild(String? text) {
    if (text == null) {
      return null;
    }
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xff000000),
      ),
    );
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMeter(
      percentage: percentage,
      fillColor: fillColor,
      gridFrequency: gridFrequency,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderMeter renderObject) {
    renderObject
      ..percentage = percentage
      ..fillColor = fillColor
      ..gridFrequency = gridFrequency;
  }
}

class RenderMeter extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderMeter({
    required double percentage,
    required Color fillColor,
    required double gridFrequency,
  })   : _percentage = percentage,
        _fillColor = fillColor,
        _gridFrequency = gridFrequency;

  static const Size _defaultSize = Size(100, 12);
  static const double _borderWidth = 1;

  double _percentage;
  double get percentage => _percentage;
  set percentage(double value) {
    if (value != _percentage) {
      _percentage = value;
      markNeedsPaint();
    }
  }

  Color _fillColor;
  Color get fillColor => _fillColor;
  set fillColor(Color value) {
    if (value != _fillColor) {
      _fillColor = value;
      markNeedsPaint();
    }
  }

  double _gridFrequency;
  double get gridFrequency => _gridFrequency;
  set gridFrequency(double value) {
    if (value != _gridFrequency) {
      _gridFrequency = value;
      markNeedsPaint();
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    if (child != null) {
      final double? childBaseline = child!.getDistanceToActualBaseline(baseline);
      if (childBaseline != null) {
        final BoxParentData childParentData = child!.parentData as BoxParentData;
        return childBaseline + childParentData.offset.dy;
      }
    }
    return null;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double result = _defaultSize.width;
    if (child != null) {
      final double childHeight = math.max(height - 2 * _borderWidth, 0);
      final double childWidth = child!.getMinIntrinsicWidth(childHeight);
      result = math.max(result, childWidth + 2 * _borderWidth);
    }
    return result;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double result = _defaultSize.width;
    if (child != null) {
      final double childHeight = math.max(height - 2 * _borderWidth, 0);
      final double childWidth = child!.getMaxIntrinsicWidth(childHeight);
      result = math.max(result, childWidth + 2 * _borderWidth);
    }
    return result;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double result = _defaultSize.height;
    if (child != null) {
      final double childWidth = math.max(width - 2 * _borderWidth, 0);
      final double childHeight = child!.getMinIntrinsicHeight(childWidth);
      result = math.max(result, childHeight + 2 * _borderWidth);
    }
    return result;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double result = _defaultSize.height;
    if (child != null) {
      final double childWidth = math.max(width - 2 * _borderWidth, 0);
      final double childHeight = child!.getMaxIntrinsicHeight(childWidth);
      result = math.max(result, childHeight + 2 * _borderWidth);
    }
    return result;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    Size dryLayoutSize = _defaultSize;
    if (child != null) {
      final BoxConstraints childConstraints = constraints.deflate(EdgeInsets.all(_borderWidth));
      final Size childSize = child!.getDryLayout(childConstraints);
      dryLayoutSize = Size(
        math.max(dryLayoutSize.width, childSize.width + 2 * _borderWidth),
        math.max(dryLayoutSize.height, childSize.height + 2 * _borderWidth),
      );
    }
    return dryLayoutSize;
  }

  @override
  void performLayout() {
    Size preferredSize = _defaultSize;
    Size? childSize;
    if (child != null) {
      final BoxConstraints childConstraints = constraints.deflate(EdgeInsets.all(_borderWidth));
      child!.layout(childConstraints, parentUsesSize: true);
      childSize = child!.size;
      preferredSize = Size(
        math.max(preferredSize.width, childSize.width + 2 * _borderWidth),
        math.max(preferredSize.height, childSize.height + 2 * _borderWidth),
      );
    }

    size = constraints.constrain(preferredSize);

    if (childSize != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      childParentData.offset = Offset(
        (size.width - childSize.width) / 2,
        (size.height - childSize.height) / 2,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Size innerSize = size - Offset(2 * _borderWidth, 2 * _borderWidth) as Size;
    final Offset innerOffset = offset.translate(_borderWidth, _borderWidth);

    // Draw the border.
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth
      ..color = const Color(0xffdddcd5);
    context.canvas.drawRect((offset & size).deflate(_borderWidth / 2), paint);

    // Draw the grid lines after the progress bar
    final double meterStopX = innerSize.width * percentage;
    _paintGridLines(context, offset, paint, startAt: meterStopX);

    // Save the layer so as to draw the progress bar on a transparent canvas,
    // thus allowing the BlendMode.xor to work as intended when we composite
    // the progress bar with the child.
    context.canvas.saveLayer(offset & size, Paint()..blendMode = BlendMode.srcOver);
    try {
      // Draw the progress bar.
      final Paint fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          offset + Offset(0, 0),
          offset + Offset(0, size.height),
          <Color>[
            brighten(fillColor),
            darken(fillColor),
          ],
        );
      context.canvas.drawRect(innerOffset & Size(meterStopX, innerSize.height), fillPaint);

      // Paint the grid lines in the progress bar.
      _paintGridLines(context, offset, paint, stopAt: meterStopX);

      if (child != null) {
        context.canvas.saveLayer(offset & size, Paint()..blendMode = BlendMode.xor);
        try {
          final BoxParentData childParentData = child!.parentData as BoxParentData;
          context.paintChild(child!, offset + childParentData.offset);
        } finally {
          context.canvas.restore();
        }
      }
    } finally {
      context.canvas.restore();
    }
  }

  void _paintGridLines(
    PaintingContext context,
    Offset offset,
    Paint paint, {
    double startAt = 0,
    double stopAt = double.infinity,
  }) {
    assert(startAt < stopAt);
    final int nLines = (1 / gridFrequency).ceil() - 1;
    final double gridSeparation = size.width * gridFrequency;
    for (int i = 0; i < nLines; i++) {
      final double gridX = ((i + 1) * gridSeparation);
      if (gridX < startAt) {
        continue;
      } else if (gridX > stopAt) {
        break;
      }
      context.canvas.drawLine(
        offset + Offset(gridX, 0.5),
        offset + Offset(gridX, size.height - 0.5),
        paint,
      );
    }
  }
}
