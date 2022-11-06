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

enum SortDirection {
  ascending,
  descending,
}

class SortIndicatorPainter extends CustomPainter {
  const SortIndicatorPainter({
    required this.sortDirection,
    this.isAntiAlias = true,
    this.color = const Color(0xff999999),
  });

  final SortDirection sortDirection;
  final bool isAntiAlias;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = isAntiAlias;
    Path path = Path();
    const double zero = 0;
    final double x1 = (size.width - 1) / 2;
    final double x2 = size.width - 1;
    final double y1 = size.height - 1;
    switch (sortDirection) {
      case SortDirection.ascending:
        path
          ..moveTo(zero, y1)
          ..lineTo(x1, zero)
          ..lineTo(x2, y1);
        break;
      case SortDirection.descending:
        path
          ..moveTo(zero, zero)
          ..lineTo(x1, y1)
          ..lineTo(x2, zero);
        break;
    }

    path.close();
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    assert(old is SortIndicatorPainter);
    SortIndicatorPainter oldPainter = old as SortIndicatorPainter;
    return sortDirection != oldPainter.sortDirection;
  }
}
