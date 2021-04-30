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
import 'package:chicago/chicago.dart';

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
  runApp(KitchenSink());
}

class KitchenSink extends StatelessWidget {
  const KitchenSink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChicagoApp(
      title: 'Chicago "Kitchen Sink" Demo',
      home: ColoredBox(
        color: const Color(0xffdddcd5),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: BorderPane(
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
              child: ScrollPane(
                view: BoxPane(
                  padding: const EdgeInsets.all(6),
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
  }
}
