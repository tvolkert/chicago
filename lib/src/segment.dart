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

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class SegmentConstraints extends BoxConstraints {
  const SegmentConstraints({
    double minWidth = 0,
    double maxWidth = double.infinity,
    double minHeight = 0,
    double maxHeight = double.infinity,
    this.viewport,
  }) : super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  SegmentConstraints.fromBoxConstraints({
    BoxConstraints boxConstraints,
    this.viewport,
  }) : super(
          minWidth: boxConstraints.minWidth,
          maxWidth: boxConstraints.maxWidth,
          minHeight: boxConstraints.minHeight,
          maxHeight: boxConstraints.maxHeight,
        );

  final Rect viewport;

  BoxConstraints asBoxConstraints() {
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (!(super == (other)))
      return false;
    return other is SegmentConstraints && other.viewport == viewport;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(super.hashCode, viewport);
  }

  @override
  String toString() {
    return 'SegmentConstraints(base=${super.toString()}, viewport=$viewport)';
  }
}

abstract class RenderSegment extends RenderBox {
  @override
  SegmentConstraints get constraints {
    final BoxConstraints constraints = super.constraints;
    assert(() {
      if (constraints is! SegmentConstraints) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: 'RenderSegment was given constraints other than SegmentConstraints',
          stack: StackTrace.current,
          library: 'chicago',
        ));
      }
      return true;
    }());
    return constraints as SegmentConstraints;
  }
}
