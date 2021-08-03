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

import 'package:chicago/chicago.dart';
import 'package:flutter/widgets.dart' hide ListView, TableCell, TableRow;
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildDummy(
      BuildContext context, int index, bool isSelected, bool isHighlighted, bool isDisabled) {
    return Container();
  }

  Widget wrap(Widget widget) {
    return ScrollPane(
      horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
      verticalScrollBarPolicy: ScrollBarPolicy.stretch,
      view: widget,
    );
  }

  // Regression test for https://github.com/tvolkert/chicago/issues/10
  testWidgets('Can reuse selectionController across render objects', (WidgetTester tester) async {
    final ListViewSelectionController controller = ListViewSelectionController();
    await tester.pumpWidget(
      wrap(
        ListView(
          selectionController: controller,
          itemHeight: 20,
          length: 1,
          itemBuilder: buildDummy,
        ),
      ),
    );
    await tester.pumpWidget(
      Padding(
        padding: EdgeInsets.zero,
        child: wrap(
          ListView(
            selectionController: controller,
            itemHeight: 20,
            length: 1,
            itemBuilder: buildDummy,
          ),
        ),
      ),
    );
    controller.selectedIndex = 0;
  });

  // Regression test for https://github.com/tvolkert/chicago/issues/6
  testWidgets('updating itemBuilder invokes new builder when widget is rebuilt', (WidgetTester tester) async {
    ListItemBuilder builder(String text) {
      return (BuildContext ctx, int index, bool isSelected, bool isHighlighted, bool isDisabled) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(text),
        );
      };
    }

    await tester.pumpWidget(
      ScrollableListView(
        itemHeight: 20,
        length: 1,
        itemBuilder: builder('one'),
      ),
    );
    expect(find.text('one'), findsOneWidget);
    await tester.pumpWidget(
      ScrollableListView(
        itemHeight: 20,
        length: 1,
        itemBuilder: builder('two'),
      ),
    );
    expect(find.text('two'), findsOneWidget);
  });

  group('ListViewSelectionController', () {
    test('selectedItems', () {
      final ListViewSelectionController controller = ListViewSelectionController(
        selectMode: SelectMode.multi,
      );
      controller.selectedRanges = <Span>[Span(5, 2), Span.single(10)];
      expect(controller.selectedItems, <int>[2, 3, 4, 5, 10]);
    });

    test('setSelectedRanges only notifies if selection changes', () {
      final ListViewSelectionController controller = ListViewSelectionController(
        selectMode: SelectMode.multi,
      );
      int notifications = 0;
      controller.addListener(() => notifications++);
      controller.selectedRanges = const <Span>[];
      expect(notifications, 0);
      controller.selectedRanges = const <Span>[Span(0, 3), Span(5, 6)];
      expect(notifications, 1);
      controller.selectedRanges = const <Span>[Span(0, 3), Span(5, 6)];
      expect(notifications, 1);
    });

    test('addSelectedRange only notifies if range not already selected', () {
      final ListViewSelectionController controller = ListViewSelectionController(
        selectMode: SelectMode.multi,
      );
      int notifications = 0;
      controller.addListener(() => notifications++);
      controller.addSelectedRange(0, 3);
      expect(notifications, 1);
      controller.addSelectedRange(1, 2);
      expect(notifications, 1);
    });

    test('removeSelectedRange only notifies if range already selected', () {
      final ListViewSelectionController controller = ListViewSelectionController(
        selectMode: SelectMode.multi,
      );
      int notifications = 0;
      controller.addListener(() => notifications++);
      controller.removeSelectedRange(0, 3);
      expect(notifications, 0);
    });

    test('clearSelection only notifies if range already selected', () {
      final ListViewSelectionController controller = ListViewSelectionController(
        selectMode: SelectMode.multi,
      );
      int notifications = 0;
      controller.addListener(() => notifications++);
      controller.clearSelection();
      expect(notifications, 0);
    });
  });
}
