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
import 'package:flutter/widgets.dart' hide TableCell, TableRow;
import 'package:flutter_test/flutter_test.dart';

const String kShortString = 'Short';
const String kLongString = 'Very Very Very Long';
const String kPlaceholderString = '-';
const double kAhemGlyphEmSize = 14;
const Size kShortStringSize =
    Size(kAhemGlyphEmSize * kShortString.length, kAhemGlyphEmSize);
const Size kLongStringSize =
    Size(kAhemGlyphEmSize * kLongString.length, kAhemGlyphEmSize);
const Size kPlaceholderStringSize =
    Size(kAhemGlyphEmSize * kPlaceholderString.length, kAhemGlyphEmSize);
const EdgeInsets kContentPadding =
    EdgeInsets.symmetric(horizontal: 5, vertical: 2);
const EdgeInsets kBorder = EdgeInsets.all(1);
const double kPulldownWidth = 15;
const double kDividerWidth = 1;
const double kMinHeight = 20;
final Offset kNonContentBounds = Offset(
  kContentPadding.horizontal +
      kBorder.horizontal +
      kPulldownWidth +
      kDividerWidth,
  kContentPadding.vertical + kBorder.vertical,
);

class TypeLiteral<T> {
  Type get type => T;
}

Widget buildItem(
    BuildContext context, String? item, bool isForMeasurementOnly) {
  final TextStyle style = DefaultTextStyle.of(context).style;
  final TextDirection textDirection = Directionality.of(context);
  return Text(
    item ?? kPlaceholderString,
    maxLines: 1,
    softWrap: false,
    textDirection: textDirection,
    style: style,
  );
}

void main() {
  late ListViewSelectionController selectionController;

  setUp(() {
    selectionController = ListViewSelectionController();
  });

  Widget buildListButtonScaffold({
    ListButtonWidth width = ListButtonWidth.shrinkWrapCurrentItem,
    BoxConstraints? constraints,
  }) {
    Widget result = RepaintBoundary(
      child: ListButton<String>(
        width: width,
        items: const <String>[kShortString, kLongString],
        builder: buildItem,
        selectionController: selectionController,
      ),
    );

    if (constraints != null) {
      result = ConstrainedBox(constraints: constraints, child: result);
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: UnconstrainedBox(child: result),
    );
  }

  testWidgets('Produces correct pixels', (WidgetTester tester) async {
    selectionController.selectedIndex = 1;
    await tester.pumpWidget(buildListButtonScaffold());
    await expectLater(
      find.byType(TypeLiteral<ListButton<String>>().type),
      matchesGoldenFile('list_button_test.golden.png'),
    );
  });

  testWidgets('Only builds currently selected item',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildListButtonScaffold());

    expect(find.text(kShortString), findsNothing);
    expect(find.text(kLongString), findsNothing);
    expect(find.text(kPlaceholderString), findsOneWidget);

    selectionController.selectedIndex = 0;
    await tester.pump();
    expect(find.text(kShortString), findsOneWidget);
    expect(find.text(kLongString), findsNothing);
    expect(find.text(kPlaceholderString), findsNothing);

    selectionController.selectedIndex = 1;
    await tester.pump();
    expect(find.text(kShortString), findsNothing);
    expect(find.text(kLongString), findsOneWidget);
    expect(find.text(kPlaceholderString), findsNothing);
  });

  testWidgets(
      'ListButtonWidth.shrinkWrapAllItems sets correct width with unbounded constraints',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        buildListButtonScaffold(width: ListButtonWidth.shrinkWrapAllItems));
    expect(tester.getSize(find.text(kPlaceholderString)), kLongStringSize);

    selectionController.selectedIndex = 0;
    await tester.pump();
    expect(tester.getSize(find.text(kShortString)), kLongStringSize);

    selectionController.selectedIndex = 1;
    await tester.pump();
    expect(tester.getSize(find.text(kLongString)), kLongStringSize);
  });

  testWidgets(
      'ListButtonWidth.shrinkWrapAllItems renders correctly with bounded constraints',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildListButtonScaffold(
      width: ListButtonWidth.shrinkWrapAllItems,
      constraints: BoxConstraints(
          minWidth: kLongStringSize.width / 2,
          maxWidth: kLongStringSize.width + 50),
    ));

    expect(tester.getSize(find.text(kPlaceholderString)), kLongStringSize);
    expect(tester.getSize(find.byType(TypeLiteral<ListButton<String>>().type)),
        kLongStringSize + kNonContentBounds);
  });

  testWidgets('ListButtonWidth.shrinkWrapAllItems grows content when required',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildListButtonScaffold(
      width: ListButtonWidth.shrinkWrapAllItems,
      constraints: BoxConstraints(minWidth: kLongStringSize.width + 50),
    ));

    final Size expectedListButtonSize =
        kLongStringSize + Offset(50, kNonContentBounds.dy);
    expect(tester.getSize(find.text(kPlaceholderString)),
        expectedListButtonSize - kNonContentBounds);
    expect(tester.getSize(find.byType(TypeLiteral<ListButton<String>>().type)),
        expectedListButtonSize);
  });

  testWidgets(
      'ListButtonWidth.shrinkWrapAllItems shrinks content when required',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildListButtonScaffold(
      width: ListButtonWidth.shrinkWrapAllItems,
      constraints: BoxConstraints(maxWidth: kShortStringSize.width),
    ));

    final Size expectedListButtonSize =
        kShortStringSize + Offset(0, kNonContentBounds.dy);
    expect(tester.getSize(find.text(kPlaceholderString)),
        expectedListButtonSize - kNonContentBounds);
    expect(tester.getSize(find.byType(TypeLiteral<ListButton<String>>().type)),
        expectedListButtonSize);
  });

  testWidgets(
      'ListButtonWidth.shrinkWrapCurrentItem sets correct width with unbounded constraints',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        buildListButtonScaffold(width: ListButtonWidth.shrinkWrapCurrentItem));
    expect(
        tester.getSize(find.text(kPlaceholderString)), kPlaceholderStringSize);

    selectionController.selectedIndex = 0;
    await tester.pump();
    expect(tester.getSize(find.text(kShortString)), kShortStringSize);

    selectionController.selectedIndex = 1;
    await tester.pump();
    expect(tester.getSize(find.text(kLongString)), kLongStringSize);
  });

  testWidgets('ListButtonWidth.expand sets expanded width',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildListButtonScaffold(
      width: ListButtonWidth.expand,
      constraints: const BoxConstraints(maxWidth: 500),
    ));
    final Size expectedListButtonSize =
        Size(500, kAhemGlyphEmSize + kNonContentBounds.dy);
    final Size expectedContentSize =
        expectedListButtonSize - kNonContentBounds as Size;
    expect(tester.getSize(find.text(kPlaceholderString)), expectedContentSize);

    selectionController.selectedIndex = 0;
    await tester.pump();
    expect(tester.getSize(find.text(kShortString)), expectedContentSize);

    selectionController.selectedIndex = 1;
    await tester.pump();
    expect(tester.getSize(find.text(kLongString)), expectedContentSize);
  });

  testWidgets('ListButtonWidth.expand fails with unbounded with',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(buildListButtonScaffold(width: ListButtonWidth.expand));
    expect(tester.takeException(), isFlutterError);
  });
}
