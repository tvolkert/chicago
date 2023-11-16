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

import 'dart:ui' as ui;

import 'package:chicago/chicago.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return Localizations(
      locale: Locale('en', 'US'),
      delegates: [
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: MediaQuery(
        data: MediaQueryData.fromView(ui.window),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (BuildContext context) => child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('If autofocus is false, widget is not focused', (WidgetTester tester) async {
    expect(tester.binding.focusManager.primaryFocus, isNull);
    await tester.pumpWidget(wrap(TextInput(autofocus: false)));
    BuildContext focusContext = tester.binding.focusManager.primaryFocus!.context!;
    expect(focusContext.findAncestorWidgetOfExactType<TextInput>(), isNull);
  });

  testWidgets('If autofocus is true, widget is focused', (WidgetTester tester) async {
    expect(tester.binding.focusManager.primaryFocus, isNull);
    await tester.pumpWidget(wrap(TextInput(autofocus: true)));
    BuildContext focusContext = tester.binding.focusManager.primaryFocus!.context!;
    expect(focusContext.findAncestorWidgetOfExactType<TextInput>(), isNotNull);
  });

  testWidgets('Can render a TextInput with an onKeyEvent handler', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(TextInput(onKeyEvent: (RawKeyEvent event) {})));
    expect(find.byType(TextInput), findsOneWidget);
  });

  testWidgets('autofocus works with onKeyEvent handler', (WidgetTester tester) async {
    expect(tester.binding.focusManager.primaryFocus, isNull);
    await tester.pumpWidget(wrap(
      TextInput(
        autofocus: true,
        onKeyEvent: (RawKeyEvent event) {},
      ),
    ));
    BuildContext focusContext = tester.binding.focusManager.primaryFocus!.context!;
    expect(focusContext.findAncestorWidgetOfExactType<TextInput>(), isNotNull);
  });
}
