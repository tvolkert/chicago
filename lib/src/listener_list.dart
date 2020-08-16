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

typedef ListenerVisitor<T> = void Function(T listener);

mixin ListenerNotifier<T> {
  ListenerList<T> _listeners = ListenerList<T>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  void addListener(T listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  void removeListener(T listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  @protected
  void notifyListeners(ListenerVisitor<T> visitor) => _listeners.forEach(visitor);
}

// TODO: make private
class ListenerList<T> extends Iterable<T> {
  // First node in the list (we don't maintain a reference to the last
  // node, since we need to walk the list looking for duplicates on add)
  _Node<T> _first;

  /// Adds a listener to the list, if it has not previously been added.
  void add(T listener) {
    if (listener == null) {
      throw ArgumentError('listener is null.');
    }

    _Node<T> node = _first;

    if (node == null) {
      _first = _Node<T>(listener: listener);
    } else {
      while (node.next != null && node.listener != listener) {
        node = node.next;
      }

      if (node.next == null && node.listener != listener) {
        node.next = _Node<T>(previous: node, listener: listener);
      } else {
        throw ArgumentError('Duplicate listener $listener added to $this');
      }
    }
  }

  /// Removes a listener from the list, if it has previously been added.
  void remove(T listener) {
    if (listener == null) {
      throw ArgumentError('listener is null.');
    }

    _Node<T> node = _first;
    while (node != null && node.listener != listener) {
      node = node.next;
    }

    if (node == null) {
      throw ArgumentError('Nonexistent listener $listener removed from $this');
    } else {
      if (node.previous == null) {
        _first = node.next;

        if (_first != null) {
          _first.previous = null;
        }
      } else {
        node.previous.next = node.next;

        if (node.next != null) {
          node.next.previous = node.previous;
        }
      }
    }
  }

  @override
  Iterator<T> get iterator => _NodeIterator<T>(_first);
}

class _Node<T> {
  _Node<T> previous;
  _Node<T> next;
  T listener;

  _Node({_Node<T> previous, _Node<T> next, T listener}) {
    this.previous = previous;
    this.next = next;
    this.listener = listener;
  }
}

class _NodeIterator<T> implements Iterator<T> {
  _Node<T> node;

  _NodeIterator(_Node<T> first) {
    node = _Node<T>(next: first);
  }

  @override
  T get current => node.listener;

  @override
  bool moveNext() {
    if (node == null) return false;
    node = node.next;
    return node != null;
  }
}
