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

@immutable
abstract class ViewportResolver {
  Rect resolve(Size size);
}

class StaticViewportResolver implements ViewportResolver {
  const StaticViewportResolver(this.viewport);

  StaticViewportResolver.fromParts({
    required Offset offset,
    required Size size,
  })  : viewport = offset & size;

  final Rect viewport;

  @override
  Rect resolve(Size size) => viewport;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaticViewportResolver &&
        other.viewport == viewport;
  }

  @override
  int get hashCode {
    return hashValues(super.hashCode, viewport);
  }

  @override
  String toString() {
    return 'StaticViewportResolver(viewport=$viewport)';
  }
}

class SegmentConstraints extends BoxConstraints {
  const SegmentConstraints({
    double minWidth = 0,
    double maxWidth = double.infinity,
    double minHeight = 0,
    double maxHeight = double.infinity,
    required this.viewportResolver,
  }) : super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  SegmentConstraints.tightFor({
    double? width,
    double? height,
    required this.viewportResolver,
  }) : super.tightFor(width: width, height: height);

  final ViewportResolver viewportResolver;

  BoxConstraints asBoxConstraints() {
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  BoxConstraints deflate(EdgeInsets edges) {
    final BoxConstraints baseConstraints = super.deflate(edges);
    return SegmentConstraints(
      minWidth: baseConstraints.minWidth,
      maxWidth: baseConstraints.maxWidth,
      minHeight: baseConstraints.minHeight,
      maxHeight: baseConstraints.maxHeight,
      viewportResolver: viewportResolver, // TODO adjust resolver?
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SegmentConstraints &&
        super == other &&
        other.viewportResolver == viewportResolver;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(super.hashCode, viewportResolver);
  }

  @override
  String toString() {
    return 'SegmentConstraints(base=${super.toString()}, viewportResolver=$viewportResolver)';
  }
}

abstract class RenderSegment extends RenderBox {
  void _debugCheckConstraints(Constraints constraints) {
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
  }

  @override
  SegmentConstraints get constraints {
    final BoxConstraints constraints = super.constraints;
    _debugCheckConstraints(constraints);
    return constraints as SegmentConstraints;
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    _debugCheckConstraints(constraints);
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }
}
