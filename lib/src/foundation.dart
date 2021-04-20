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
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef Predicate<T> = bool Function(T item);

int binarySearch<T>(
  List<T> sortedList,
  T value, {
  int Function(T, T)? compare,
}) {
  compare ??= _defaultCompare<T>();
  int min = 0;
  int max = sortedList.length;
  while (min < max) {
    int mid = min + ((max - min) >> 1);
    T element = sortedList[mid];
    int comp = compare(element, value);
    if (comp == 0) {
      return mid;
    } else if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return -(min + 1);
}

enum SelectMode {
  none,
  single,
  multi,
}

/// Returns a [Comparator] that asserts that its first argument is comparable.
Comparator<T> _defaultCompare<T>() {
  return (T value1, T value2) => (value1 as Comparable<T>).compareTo(value2);
}

/// Returns true if any shift key is pressed on a physical keyboard.
bool isShiftKeyPressed() {
  final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;
  return keys.contains(LogicalKeyboardKey.shiftLeft) ||
      keys.contains(LogicalKeyboardKey.shiftRight);
}

/// Returns true if any "command" key is pressed on a physical keyboard.
///
/// A command key is the "Command" (⌘) key on MacOS, and the "Control" (⌃)
/// key on other platforms.
bool isPlatformCommandKeyPressed([TargetPlatform? platform]) {
  platform ??= defaultTargetPlatform;
  final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;
  switch (platform) {
    case TargetPlatform.macOS:
      return keys.contains(LogicalKeyboardKey.metaLeft) ||
          keys.contains(LogicalKeyboardKey.metaRight);
    default:
      return keys.contains(LogicalKeyboardKey.controlLeft) ||
          keys.contains(LogicalKeyboardKey.controlRight);
  }
}

bool isActivateKey(LogicalKeyboardKey key) {
  final Iterable<LogicalKeyboardKey> activateKeys = WidgetsApp.defaultShortcuts.entries
      .where((MapEntry<LogicalKeySet, Intent> entry) => entry.value is ActivateIntent)
      .map<LogicalKeySet>((MapEntry<LogicalKeySet, Intent> entry) => entry.key)
      .where((LogicalKeySet keySet) => keySet.keys.length == 1)
      .map<LogicalKeyboardKey>((LogicalKeySet keySet) => keySet.keys.single);
  return activateKeys.contains(key);
}

class Vote {
  const Vote._(this._name);

  final String _name;

  static const Vote approve = Vote._('approve');
  static const Vote deny = Vote._('deny');
  static const Vote abstain = Vote._('abstain');

  Vote tally(Vote other) {
    switch (other) {
      case approve:
        return this;
      case deny:
        return other;
      case abstain:
        return this == deny ? this : other;
    }
    throw StateError('Unreachable code');
  }

  @override
  String toString() => _name;
}

class LinearConstraints extends Constraints {
  const LinearConstraints({
    this.min = 0,
    this.max = double.infinity,
  });

  const LinearConstraints.tight(double value)
      : min = value,
        max = value;

  LinearConstraints.width(BoxConstraints constraints)
      : min = constraints.minWidth,
        max = constraints.maxWidth;

  LinearConstraints.height(BoxConstraints constraints)
      : min = constraints.minHeight,
        max = constraints.maxHeight;

  final double min;
  final double max;

  static const LinearConstraints zero = LinearConstraints(max: 0);

  double constrainMainAxisSize(MainAxisSize mainAxisSize) {
    switch (mainAxisSize) {
      case MainAxisSize.min:
        return min;
      case MainAxisSize.max:
        return max;
    }
  }

  bool isSatisfiedBy(double value) => (min <= value) && (value <= max);

  bool get isBounded => max < double.infinity;

  @override
  bool get isNormalized => min >= 0 && min <= max;

  @override
  bool get isTight => min >= max;

  bool operator <(double value) => min < value && max < value;

  bool operator <=(double value) => min <= value && max <= value;

  bool operator >(double value) => min > value && max > value;

  bool operator >=(double value) => min >= value && max >= value;

  @override
  String toString() => 'LinearConstraints($min <= x <= $max)';
}

class MessageType {
  const MessageType._(this._assetKey);

  final String _assetKey;

  static const MessageType error = MessageType._('error');
  static const MessageType warning = MessageType._('warning');
  static const MessageType question = MessageType._('question');
  static const MessageType info = MessageType._('info');

  Widget toImage() {
    return Image.asset('assets/message_type-$_assetKey-32x32.png', package: 'chicago');
  }

  Widget toSmallImage() {
    return Image.asset('assets/message_type-$_assetKey-16x16.png', package: 'chicago');
  }
}

class FakeSubscription<T> implements StreamSubscription<T> {
  const FakeSubscription();

  @override
  Future<E> asFuture<E>([E? futureValue]) async {
    assert(false);
    return futureValue as E;
  }

  @override
  Future<void> cancel() async {}

  @override
  bool get isPaused => false;

  @override
  void onData(void Function(T data)? handleData) {
    assert(false);
  }

  @override
  void onDone(void Function()? handleDone) {
    assert(false);
  }

  @override
  void onError(Function? handleError) {
    assert(false);
  }

  @override
  void pause([Future<void>? resumeSignal]) {
    assert(false);
  }

  @override
  void resume() {
    assert(false);
  }
}

mixin RenderBoxWithChildDefaultsMixin on RenderObjectWithChildMixin<RenderBox> {
  bool defaultHitTestChild(BoxHitTestResult result, {required ui.Offset position}) {
    if (child == null) {
      return false;
    }
    final BoxParentData childParentData = child!.parentData as BoxParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return child!.hitTest(result, position: transformed);
      },
    );
  }

  void defaultPaintChild(PaintingContext context, Offset offset) {
    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      context.paintChild(child!, offset + childParentData.offset);
    }
  }
}
