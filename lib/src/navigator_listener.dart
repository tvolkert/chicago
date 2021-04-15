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

import 'package:flutter/widgets.dart';

/// Signature for a function that receives [NavigatorObserver] notifications.
///
/// See also:
///
///  * [NavigatorListenerController.addObserver], where this signature is used.
typedef NavigatorObserverCallback = void Function(
  Route<dynamic> route,
  Route<dynamic>? previousRoute,
);

/// Signature for a function that receives [NavigatorObserver.didReplace]
/// notifications.
///
/// See also:
///
///  * [NavigatorListenerController.addObserver], where this signature is used.
typedef NavigatorObserverOnReplacedCallback = void Function(
  Route<dynamic>? route,
  Route<dynamic>? previousRoute,
);

/// The result of a call to [NavigatorListenerController.addObserver].
///
/// This object represents a handle on the registration of a listener. Callers
/// should call [dispose] to unregister their listener.
class NavigatorListenerRegistration {
  const NavigatorListenerRegistration._(this._aggregateObserver, this._proxy);

  final _AggregateObserver _aggregateObserver;
  final _ProxyObserver _proxy;

  /// Causes the listener to stop receiving [NavigatorObserver] notifications.
  ///
  /// Failure to dispose of a registration can lead to memory leaks.
  void dispose() {
    _aggregateObserver.proxies.remove(_proxy);
  }
}

/// A widget that allows for dynamic registration of [NavigatorObserver]
/// notifications.
///
/// This widget should be placed above the [Navigator] in the widget hierarchy:
///
/// ```dart
/// void main() {
///   runApp(
///     NavigatorListener(
///       child: MyApp(),
///     ),
///   );
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       observers: [NavigatorListener.of(context).observer],
///       home: MyHome(),
///     );
///   }
/// }
/// ```
class NavigatorListener extends StatefulWidget {
  const NavigatorListener({Key? key, required this.child}) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// This widget will match the size of its child.
  final Widget child;

  @override
  _NavigatorListenerState createState() => _NavigatorListenerState();

  /// The controller from the closest instance of this class that encloses the
  /// given context.
  static NavigatorListenerController of(BuildContext context) {
    _Scope scope = context.dependOnInheritedWidgetOfExactType<_Scope>()!;
    return scope.navigatorListenerState;
  }
}

abstract class NavigatorListenerController {
  /// The underlying observer that will broadcast notifications to all
  /// child observers added via [addObserver].
  ///
  /// This observer should be included in the [Navigator.observers] list when
  /// the navigator is created. This can be done by including a
  /// [NavigatorListener] widget as an ancestor of the [Navigator] widget,
  /// then specifying it like so:
  ///
  /// ```dart
  /// Navigator(
  ///   observers: [
  ///     NavigatorListener.of(context).observer,
  ///   ],
  /// )
  /// ```
  NavigatorObserver get observer;

  /// Adds a child observer to be notified of [NavigatorObserver] events.
  ///
  /// Callers should only specify the callbacks that they're interested in.
  ///
  /// The returned [NavigatorListenerRegistration] can be used to unregister
  /// the listener via [NavigatorListenerRegistration.dispose].
  NavigatorListenerRegistration addObserver({
    NavigatorObserverCallback? onPushed,
    NavigatorObserverCallback? onPopped,
    NavigatorObserverCallback? onRemoved,
    NavigatorObserverOnReplacedCallback? onReplaced,
    NavigatorObserverCallback? onStartUserGesture,
    VoidCallback? onStopUserGesture,
  });
}

class _NavigatorListenerState extends State<NavigatorListener>
    implements NavigatorListenerController {
  @override
  final _AggregateObserver observer = _AggregateObserver();

  @override
  NavigatorListenerRegistration addObserver({
    NavigatorObserverCallback? onPushed,
    NavigatorObserverCallback? onPopped,
    NavigatorObserverCallback? onRemoved,
    NavigatorObserverOnReplacedCallback? onReplaced,
    NavigatorObserverCallback? onStartUserGesture,
    VoidCallback? onStopUserGesture,
  }) {
    final _ProxyObserver proxy = _ProxyObserver(
      onPushed: onPushed,
      onPopped: onPopped,
      onRemoved: onRemoved,
      onReplaced: onReplaced,
      onStartUserGesture: onStartUserGesture,
      onStopUserGesture: onStopUserGesture,
    );
    observer.proxies.add(proxy);
    return NavigatorListenerRegistration._(observer, proxy);
  }

  @override
  Widget build(BuildContext context) {
    return _Scope(
      navigatorListenerState: this,
      child: widget.child,
    );
  }
}

class _Scope extends InheritedWidget {
  const _Scope({
    required this.navigatorListenerState,
    required Widget child,
  }) : super(child: child);

  final _NavigatorListenerState navigatorListenerState;

  @override
  bool updateShouldNotify(_Scope old) {
    return navigatorListenerState.observer != old.navigatorListenerState.observer;
  }
}

class _AggregateObserver extends NavigatorObserver {
  final Set<_ProxyObserver> proxies = <_ProxyObserver>{};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (NavigatorObserver proxy in proxies) {
      proxy.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (NavigatorObserver proxy in proxies) {
      proxy.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (NavigatorObserver proxy in proxies) {
      proxy.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? oldRoute, Route<dynamic>? newRoute}) {
    for (NavigatorObserver proxy in proxies) {
      proxy.didReplace(oldRoute: oldRoute, newRoute: newRoute);
    }
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (NavigatorObserver proxy in proxies) {
      proxy.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    for (NavigatorObserver proxy in proxies) {
      proxy.didStopUserGesture();
    }
  }
}

class _ProxyObserver extends NavigatorObserver {
  _ProxyObserver({
    this.onPushed,
    this.onPopped,
    this.onRemoved,
    this.onReplaced,
    this.onStartUserGesture,
    this.onStopUserGesture,
  });

  final NavigatorObserverCallback? onPushed;
  final NavigatorObserverCallback? onPopped;
  final NavigatorObserverCallback? onRemoved;
  final NavigatorObserverOnReplacedCallback? onReplaced;
  final NavigatorObserverCallback? onStartUserGesture;
  final VoidCallback? onStopUserGesture;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onPushed != null) {
      onPushed!(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onPopped != null) {
      onPopped!(route, previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onRemoved != null) {
      onRemoved!(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? oldRoute, Route<dynamic>? newRoute}) {
    if (onReplaced != null) {
      onReplaced!(newRoute, oldRoute);
    }
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onStartUserGesture != null) {
      onStartUserGesture!(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    if (onStopUserGesture != null) {
      onStopUserGesture!();
    }
  }
}
