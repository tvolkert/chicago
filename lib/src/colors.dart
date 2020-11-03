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

import 'dart:math' as math;

import 'package:flutter/painting.dart';

Color brighten(Color color) {
  return _adjustBrightness(color, 0.1);
}

Color darken(Color color) {
  return _adjustBrightness(color, -0.1);
}

Color _adjustBrightness(Color color, double adjustment) {
  HSVColor hsv = HSVColor.fromColor(color);
  HSVColor adjusted = HSVColor.fromAHSV(
    hsv.alpha,
    hsv.hue,
    hsv.saturation,
    math.min(math.max(hsv.value + adjustment, 0), 1),
  );
  return adjusted.toColor();
}
