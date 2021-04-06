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

import 'dart:ui' show window;

// Needed because chicago.TextInput still depends on Material
import 'package:flutter/material.dart' show Material, DefaultMaterialLocalizations;
import 'package:flutter/widgets.dart';
import 'package:chicago/chicago.dart' as chicago;

import 'src/activity_indicators.dart';
import 'src/alerts.dart';
import 'src/asset_image_precache.dart';
import 'src/buttons.dart';
import 'src/calendars.dart';
import 'src/lists.dart';
import 'src/navigation.dart';
import 'src/spinners.dart';
import 'src/splitters.dart';
import 'src/tables.dart';

void main() {
  runApp(
    const chicago.NavigatorListener(
      child: KitchenSink(),
    ),
  );
}

class KitchenSink extends StatelessWidget {
  const KitchenSink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Chicago "Kitchen Sink" Demo',
      color: Color(0xffffffff),
      localizationsDelegates: [DefaultMaterialLocalizations.delegate],
      home: Container(),
      builder: (BuildContext context, Widget? navigator) => DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Dialog',
          fontSize: 14,
          color: Color(0xff000000),
        ),
        child: Material(
          child: MediaQuery(
            data: MediaQueryData.fromWindow(window),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Navigator(
                observers: [chicago.NavigatorListener.of(context).observer],
                onGenerateRoute: (RouteSettings settings) {
                  return PageRouteBuilder<void>(
                    settings: settings,
                    pageBuilder: (BuildContext context, Animation<double> _, Animation<double> __) {
                      return ColoredBox(
                        color: const Color(0xffdddcd5),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: chicago.Border(
                            borderColor: const Color(0xff999999),
                            backgroundColor: const Color(0xfff7f5ee),
                            child: AssetImagePrecache(
                              paths: const <String>[
                                'assets/anchor.png',
                                'assets/bell.png',
                                'assets/clock.png',
                                'assets/cup.png',
                                'assets/flag_red.png',
                                'assets/house.png',
                                'assets/star.png',
                              ],
                              loadingIndicator: Container(),
                              child: chicago.ScrollPane(
                                view: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const <Widget>[
                                      ButtonsDemo(),
                                      ListsDemo(),
                                      CalendarsDemo(),
                                      NavigationDemo(),
                                      SplittersDemo(),
                                      ActivityIndicatorsDemo(),
                                      SpinnersDemo(),
                                      TablesDemo(),
                                      AlertsDemo(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
