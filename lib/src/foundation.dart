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
import 'package:flutter/services.dart';

int binarySearch<T>(
  List<T> sortedList,
  T value, {
  int Function(T, T) compare,
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
bool isPlatformCommandKeyPressed([TargetPlatform platform]) {
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

class Vote {
  const Vote._(this._name);

  final String _name;

  static const Vote approve = Vote._('approve');
  static const Vote deny = Vote._('deny');
  static const Vote abstain = Vote._('abstain');

  Vote tally(Vote other) {
    assert(other != null);
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
