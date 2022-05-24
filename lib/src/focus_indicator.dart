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

import 'dart:ui';

import 'package:flutter/widgets.dart';

class FocusIndicator extends StatelessWidget {
  const FocusIndicator({
    super.key,
    required this.isFocused,
    this.insets = EdgeInsets.zero,
    this.color = const Color(0xff999999),
    this.child,
  });

  final bool isFocused;
  final EdgeInsets insets;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FocusPainter(isFocused, insets, color),
      child: child,
    );
  }
}

class _FocusPainter extends CustomPainter {
  const _FocusPainter(this.isFocused, this.padding, this.color);

  final bool isFocused;
  final EdgeInsets padding;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (isFocused) {
      Rect rect = Offset.zero & size;
      rect = rect.deflate(0.5);
      rect = padding.deflateRect(rect);
      final Path path = Path()..addRect(rect);
      final Path dashedPath = _dashPath(path, <double>[1, 1]);
      canvas.drawPath(
          dashedPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = color);
    }
  }

  @override
  bool shouldRepaint(_FocusPainter oldDelegate) {
    return isFocused != oldDelegate.isFocused || padding != oldDelegate.padding || color != oldDelegate.color;
  }
}

/// The `dash` parameter is a list of dash offsets and lengths. For example,
/// the array `[5, 10]` would result in dashes 5 pixels long followed by blank
/// spaces 10 pixels long.  The array `[5, 10, 5]` would result in a 5 pixel
/// dash, a 10 pixel gap, a 5 pixel dash, a 5 pixel gap, a 10 pixel dash, etc.
Path _dashPath(
  Path source,
  List<double> dash, {
  double offset = 0.5,
}) {
  final Path dest = Path();
  for (final PathMetric metric in source.computeMetrics()) {
    double distance = offset;
    bool draw = true;
    for (int i = 0; distance < metric.length; i = (i + 1) % dash.length) {
      final double len = dash[i];
      if (draw) {
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      draw = !draw;
    }
  }

  return dest;
}
