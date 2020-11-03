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

import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef ListenerVisitor<T> = void Function(T listener);

class _ListenerEntry<T> extends LinkedListEntry<_ListenerEntry<T>> {
  _ListenerEntry(this.listener);
  final T listener;
}

mixin ListenerNotifier<T> {
  LinkedList<_ListenerEntry<T>> _listeners = LinkedList<_ListenerEntry<T>>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError(
            'A $runtimeType was used after being disposed.\n'
                'Once you have called dispose() on a $runtimeType, it can no longer be used.'
        );
      }
      return true;
    }());
    return true;
  }

  void addListener(T listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(_ListenerEntry<T>(listener));
  }

  void removeListener(T listener) {
    assert(_debugAssertNotDisposed());
    for (final _ListenerEntry<T> entry in _listeners) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  @protected
  void notifyListeners(ListenerVisitor<T> visitor) {
    assert(_debugAssertNotDisposed());
    if (_listeners.isEmpty)
      return;

    final List<_ListenerEntry<T>> localListeners = List<_ListenerEntry<T>>.from(_listeners);

    for (final _ListenerEntry<T> entry in localListeners) {
      try {
        if (entry.list != null) {
          visitor(entry.listener);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'chicago library',
          context: ErrorDescription('while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ListenerNotifier<T>>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }
}
