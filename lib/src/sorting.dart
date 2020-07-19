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

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

enum SortDirection {
  ascending,
  descending,
}

class SortIndicatorPainter extends CustomPainter {
  const SortIndicatorPainter({
    this.sortDirection,
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
    switch (sortDirection) {
      case SortDirection.ascending:
        path
          ..moveTo(0, 3)
          ..lineTo(3, 0)
          ..lineTo(6, 3);
        break;
      case SortDirection.descending:
        path
          ..moveTo(0, 0)
          ..lineTo(3, 3)
          ..lineTo(6, 0);
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
    SortIndicatorPainter oldPainter = old;
    return sortDirection != oldPainter.sortDirection;
  }
}
