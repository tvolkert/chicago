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

/// Class that serves as the defining property of [SegmentConstraints].
///
/// This allows callers to find out what the parent's viewport will be given a
/// child's size. Classes that are set as the [ScrollPane.view] will be passed
/// [SegmentConstraints] and can use the [SegmentConstraints.viewportResolver]
/// to optimize their building, layout, and/or painting.
@immutable
abstract class ViewportResolver {
  Rect resolve(Size size);
}

/// A [ViewportResolver] whose viewport does not depend on the size passed to
/// [resolve].
class StaticViewportResolver implements ViewportResolver {
  const StaticViewportResolver(this.viewport);

  StaticViewportResolver.fromParts({
    required Offset offset,
    required Size size,
  }) : viewport = offset & size;

  final Rect viewport;

  @override
  Rect resolve(Size size) => viewport;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaticViewportResolver && other.viewport == viewport;
  }

  @override
  int get hashCode => viewport.hashCode;

  @override
  String toString() {
    return 'StaticViewportResolver(viewport=$viewport)';
  }
}

/// Constraints that are passed by [RenderScrollPane].
///
/// Segment constraints are specialized box constraints; in addition to the
/// basic box constraints properties, they provide a [ViewportResolver], which
/// tells the child what the scroll pane's viewport will be given the child's
/// size.
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
  BoxConstraints deflate(EdgeInsetsGeometry edges) {
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
    return Object.hash(super.hashCode, viewportResolver);
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
