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

// Needed because chicago.TextInput still depends on Material
import 'package:flutter/material.dart' show DefaultMaterialLocalizations, Material;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'navigator_listener.dart';
import 'scroll_pane.dart';

class ChicagoApp extends StatefulWidget {
  const ChicagoApp({
    Key? key,
    this.title = 'Chicago App',
    this.home,
  }) : super(key: key);

  final String title;
  final Widget? home;

  @override
  _ChicagoAppState createState() => _ChicagoAppState();
}

class _ChicagoAppState extends State<ChicagoApp> with WidgetsBindingObserver {
  bool _scrollToVisibleScheduled = false;

  @override
  void didChangeMetrics() {
    FocusNode? focusNode = FocusManager.instance.primaryFocus;
    BuildContext? focusContext = focusNode?.context;
    if (focusNode != null && focusContext != null) {
      final ScrollPaneState? scrollPane = ScrollPane.of(focusContext);
      if (scrollPane != null && !_scrollToVisibleScheduled) {
        _scrollToVisibleScheduled = true;
        SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          _scrollToVisibleScheduled = false;
          assert(mounted && scrollPane.mounted && focusNode.hasPrimaryFocus);
          final RenderObject? focusRenderObject = focusContext.findRenderObject();
          if (focusRenderObject is RenderBox) {
            final Rect focusRect = Offset.zero & focusRenderObject.size;
            scrollPane.scrollToVisible(focusRect, context: focusContext);
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorListener(
      child: WidgetsApp(
        title: widget.title,
        color: Color(0xffffffff),
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate, // TODO: Remove
        ],
        builder: (BuildContext context, Widget? navigator) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'Dialog',
                fontSize: 14,
                color: Color(0xff000000),
              ),
              child: SafeArea(
                child: Material( // TODO: Remove
                  child: Navigator(
                    observers: [NavigatorListener.of(context).observer],
                    onGenerateRoute: (RouteSettings settings) {
                      return PageRouteBuilder<void>(
                        settings: settings,
                        pageBuilder: (BuildContext _, Animation<double> __, Animation<double> ___) {
                          return widget.home ?? Container();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
