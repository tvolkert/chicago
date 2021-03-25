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

import 'dart:math' as math;
import 'dart:ui' show window;

import 'package:flutter/widgets.dart';
import 'package:chicago/chicago.dart' as chicago;

const List<Color> colors = [
  Color(0xffff0000),
  Color(0xffffa500),
  Color(0xffffff00),
  Color(0xff00ff00),
  Color(0xff0000ff),
  Color(0xff4b0082),
  Color(0xff8f008f),
];

const List<String> colorNames = [
  'Red',
  'Orange',
  'Yellow',
  'Green',
  'Blue',
  'Indigo',
  'Violet',
];

VoidCallback acknowledgeAction(BuildContext context, [String action = 'an action']) {
  return () {
    chicago.Prompt.open(
      context: context,
      messageType: chicago.MessageType.info,
      message: 'Registered $action.',
      body: Container(),
      options: ['OK'],
      selectedOption: 0,
    );
  };
}

VoidCallback acknowledgeButtonPress(BuildContext context) {
  return acknowledgeAction(
    context,
    'a button press',
  );
}

VoidCallback acknowledgeLinkPress(BuildContext context) {
  return acknowledgeAction(
    context,
    'a link',
  );
}

void main() {
  tableSortController['i'] = chicago.SortDirection.ascending;
  tableSortController.addListener(chicago.TableViewSortListener(
    onChanged: (chicago.TableViewSortController controller) {
      final String sortKey = controller.keys.first;
      final chicago.SortDirection direction = controller[sortKey]!;

      Map<String, int>? selectedItem;
      if (tableSelectionController.selectedIndex != -1) {
        selectedItem = tableData[tableSelectionController.selectedIndex];
      }

      final TableRowComparator comparator = _getTableRowComparator(sortKey, direction);
      tableData.sort(comparator);

      if (selectedItem != null) {
        int selectedIndex = chicago.binarySearch(tableData, selectedItem, compare: comparator);
        assert(selectedIndex >= 0);
        tableSelectionController.selectedIndex = selectedIndex;
        final Rect rowBounds = tableMetricsController.metrics.getRowBounds(selectedIndex);
        tableScrollController.scrollToVisible(rowBounds);
      }
    },
  ));
  runApp(KitchenSink());
}

typedef TableRowComparator = int Function(Map<String, int> row1, Map<String, int> row2);
TableRowComparator _getTableRowComparator(String sortKey, chicago.SortDirection direction) {
  return (Map<String, int> row1, Map<String, int> row2) {
    int value1 = row1[sortKey]!;
    int value2 = row2[sortKey]!;
    int result = value1.compareTo(value2);
    if (direction == chicago.SortDirection.descending) {
      result *= -1;
    }
    return result;
  };
}

chicago.TableColumnController _createTableColumn(String key, String name) {
  return chicago.TableColumnController(
    key: key,
    width: chicago.ConstrainedTableColumnWidth(width: 48),
    headerRenderer: ({
      required BuildContext context,
      required int columnIndex,
    }) {
      return Text(name);
    },
    cellRenderer: ({
      required BuildContext context,
      required int rowIndex,
      required int columnIndex,
      required bool rowSelected,
      required bool rowHighlighted,
      required bool isEditing,
      required bool isRowDisabled,
    }) {
      final int? value = tableData[rowIndex][key];
      TextStyle style = DefaultTextStyle.of(context).style;
      if (rowSelected) {
        style = style.copyWith(color: Color(0xffffffff));
      }
      return Text('$value', style: style);
    },
  );
}

chicago.TableColumnController _createFlexTableColumn() {
  return chicago.TableColumnController(
    key: 'flex',
    headerRenderer: ({
      required BuildContext context,
      required int columnIndex,
    }) {
      return Text('');
    },
    cellRenderer: ({
      required BuildContext context,
      required int rowIndex,
      required int columnIndex,
      required bool rowSelected,
      required bool rowHighlighted,
      required bool isEditing,
      required bool isRowDisabled,
    }) {
      return Container();
    },
  );
}

final math.Random rand = math.Random();
const int tableLength = 10000;

final List<Map<String, int>> tableData = List<Map<String, int>>.generate(tableLength, (int index) {
  return <String, int>{
    'i': index,
    'a': rand.nextInt(20),
    'b': rand.nextInt(100),
    'c': rand.nextInt(500),
    'd': rand.nextInt(10000),
  };
});

final List<String> customTableData = <String>[
  'anchor',
  'bell',
  'clock',
  'cup',
  'house',
  'star',
];

final List<bool> customTableCheckmarks = <bool>[
  true,
  false,
  false,
  false,
  false,
  false,
];

const Color grey = Color(0xff999999);
final chicago.ListViewSelectionController basicSelectionController =
    chicago.ListViewSelectionController();
final chicago.ListViewSelectionController lazySelectionController =
    chicago.ListViewSelectionController();
final chicago.ListViewSelectionController multiSelectionController =
    chicago.ListViewSelectionController(selectMode: chicago.SelectMode.multi)
      ..selectedRanges = [chicago.Span(0, 0), chicago.Span(2, 3)];
final chicago.ListViewSelectionController imageSelectionController =
    chicago.ListViewSelectionController();
final chicago.ListViewItemDisablerController imageDisabledController =
    chicago.ListViewItemDisablerController()..filter = (int index) => index == 2 || index == 3;
final chicago.ListViewSelectionController basicButtonSelectionController =
    chicago.ListViewSelectionController()..selectedIndex = 0;
final chicago.ListViewSelectionController imageButtonSelectionController =
    chicago.ListViewSelectionController()..selectedIndex = 2;
final chicago.SpinnerController basicSpinnerController = chicago.SpinnerController()
  ..selectedIndex = 0;
final chicago.SpinnerController numericSpinnerController = chicago.SpinnerController()
  ..selectedIndex = 0;
final chicago.SpinnerController dateSpinnerController = chicago.SpinnerController()
  ..selectedIndex = 0;
final chicago.TableViewSelectionController tableSelectionController =
    chicago.TableViewSelectionController();
final chicago.TableViewSortController tableSortController = chicago.TableViewSortController();
final chicago.TableViewMetricsController tableMetricsController =
    chicago.TableViewMetricsController();
final chicago.ScrollController tableScrollController = chicago.ScrollController();
final chicago.TableViewSelectionController customTableSelectionController =
    chicago.TableViewSelectionController(selectMode: chicago.SelectMode.multi);

class KitchenSink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'asd',
      color: Color(0xffffffff),
      builder: (BuildContext context, Widget? navigator) => DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Dialog',
          fontSize: 14,
          color: Color(0xff000000),
        ),
        child: MediaQuery(
          data: MediaQueryData.fromWindow(window),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return PageRouteBuilder<void>(
                  settings: settings,
                  pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
                    final TextStyle whiteStyle = baseStyle.copyWith(color: Color(0xffffffff));
                    final TextStyle greyStyle = baseStyle.copyWith(color: Color(0xff999999));
                    final TextStyle boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
                    final TextStyle headerStyle = boldStyle.copyWith(color: Color(0xff2b5580));
                    return ColoredBox(
                      color: const Color(0xffdddcd5),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: chicago.Border(
                          borderColor: Color(0xff999999),
                          backgroundColor: const Color(0xfff7f5ee),
                          child: chicago.ScrollPane(
                            view: Padding(
                              padding: EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Buttons', style: headerStyle),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      chicago.Border(
                                        borderColor: Color(0xff999999),
                                        backgroundColor: const Color(0xffffffff),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Basic Push Buttons', style: boldStyle),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  chicago.PushButton(
                                                    label: 'One',
                                                    onPressed: acknowledgeButtonPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.PushButton(
                                                    label: 'Two',
                                                    onPressed: acknowledgeButtonPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.PushButton(label: 'Three'),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text('Image Buttons', style: boldStyle),
                                              SizedBox(height: 4),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  chicago.PushButton(
                                                    label: 'Bell',
                                                    icon: 'assets/bell.png',
                                                    onPressed: acknowledgeButtonPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.PushButton(
                                                    label: 'Clock',
                                                    icon: 'assets/clock.png',
                                                    axis: Axis.vertical,
                                                    onPressed: acknowledgeButtonPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.PushButton(
                                                    label: 'House',
                                                    icon: 'assets/house.png',
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text('Toolbar Buttons', style: boldStyle),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  chicago.PushButton(
                                                    icon: 'assets/bell.png',
                                                    isToolbar: true,
                                                    onPressed: acknowledgeButtonPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.PushButton(
                                                    icon: 'assets/clock.png',
                                                    isToolbar: true,
                                                    onPressed: acknowledgeButtonPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.PushButton(
                                                    icon: 'assets/house.png',
                                                    isToolbar: true,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      chicago.Border(
                                        borderColor: Color(0xff999999),
                                        backgroundColor: const Color(0xffffffff),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Basic Checkboxes', style: boldStyle),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  chicago.Checkbox(trailing: Text('One')),
                                                  SizedBox(width: 4),
                                                  chicago.Checkbox(trailing: Text('Two')),
                                                  SizedBox(width: 4),
                                                  chicago.Checkbox(trailing: Text('Three')),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text('Image Checkboxes', style: boldStyle),
                                              SizedBox(height: 4),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  chicago.Checkbox(
                                                    trailing: Row(
                                                      children: [
                                                        Image.asset('assets/clock.png'),
                                                        SizedBox(width: 4),
                                                        Text('Clock'),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  chicago.Checkbox(
                                                    trailing: Row(
                                                      children: [
                                                        Image.asset('assets/bell.png'),
                                                        SizedBox(width: 4),
                                                        Text('Bell'),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  chicago.Checkbox(
                                                    trailing: Row(
                                                      children: [
                                                        Image.asset('assets/house.png'),
                                                        SizedBox(width: 4),
                                                        Text('House'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      chicago.Border(
                                        borderColor: Color(0xff999999),
                                        backgroundColor: const Color(0xffffffff),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Basic Link Buttons', style: boldStyle),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  chicago.LinkButton(
                                                    text: 'One',
                                                    onPressed: acknowledgeLinkPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.LinkButton(
                                                    text: 'Two',
                                                    onPressed: acknowledgeLinkPress(context),
                                                  ),
                                                  SizedBox(width: 4),
                                                  chicago.LinkButton(text: 'Three'),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text('Image Link Buttons', style: boldStyle),
                                              SizedBox(height: 4),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  chicago.LinkButton(
                                                    text: 'Bell',
                                                    image: AssetImage('assets/bell.png'),
                                                    onPressed: acknowledgeLinkPress(context),
                                                  ),
                                                  SizedBox(height: 4),
                                                  chicago.LinkButton(
                                                    text: 'Clock',
                                                    image: AssetImage('assets/clock.png'),
                                                    onPressed: acknowledgeLinkPress(context),
                                                  ),
                                                  SizedBox(height: 4),
                                                  chicago.LinkButton(
                                                    text: 'House',
                                                    image: AssetImage('assets/house.png'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('Lists', style: headerStyle),
                                  chicago.Border(
                                    borderColor: Color(0xff999999),
                                    backgroundColor: const Color(0xffffffff),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Basic', style: boldStyle),
                                              SizedBox(height: 4),
                                              SizedBox(
                                                width: 72,
                                                height: 90,
                                                child: chicago.Border(
                                                  borderColor: Color(0xff999999),
                                                  child: chicago.ScrollableListView(
                                                    itemHeight: 19,
                                                    length: 6,
                                                    selectionController: basicSelectionController,
                                                    itemBuilder: ({
                                                      required BuildContext context,
                                                      required int index,
                                                      required bool isSelected,
                                                      required bool isHighlighted,
                                                      required bool isDisabled,
                                                    }) {
                                                      const List<String> colors = [
                                                        'Blue',
                                                        'Green',
                                                        'Orange',
                                                        'Purple',
                                                        'Red',
                                                        'Yellow',
                                                      ];
                                                      return Text(colors[index],
                                                          style:
                                                              isSelected ? whiteStyle : baseStyle);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Lazy', style: boldStyle),
                                              SizedBox(height: 4),
                                              SizedBox(
                                                width: 90,
                                                height: 90,
                                                child: chicago.Border(
                                                  borderColor: Color(0xff999999),
                                                  child: chicago.ScrollableListView(
                                                    itemHeight: 19,
                                                    length: 1000000,
                                                    selectionController: lazySelectionController,
                                                    itemBuilder: ({
                                                      required BuildContext context,
                                                      required int index,
                                                      required bool isSelected,
                                                      required bool isHighlighted,
                                                      required bool isDisabled,
                                                    }) {
                                                      return Text('${index + 1}',
                                                          style:
                                                              isSelected ? whiteStyle : baseStyle);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Multi-Select', style: boldStyle),
                                              SizedBox(height: 4),
                                              SizedBox(
                                                width: 90,
                                                height: 90,
                                                child: chicago.Border(
                                                  borderColor: Color(0xff999999),
                                                  child: chicago.ScrollableListView(
                                                    itemHeight: 19,
                                                    length: 6,
                                                    selectionController: multiSelectionController,
                                                    itemBuilder: ({
                                                      required BuildContext context,
                                                      required int index,
                                                      required bool isSelected,
                                                      required bool isHighlighted,
                                                      required bool isDisabled,
                                                    }) {
                                                      const List<String> shapes = [
                                                        'Circle',
                                                        'Ellipse',
                                                        'Square',
                                                        'Rectangle',
                                                        'Hexagon',
                                                        'Octagon',
                                                      ];
                                                      return Text(shapes[index],
                                                          style:
                                                              isSelected ? whiteStyle : baseStyle);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Image', style: boldStyle),
                                              SizedBox(height: 4),
                                              SizedBox(
                                                width: 90,
                                                height: 90,
                                                child: chicago.Border(
                                                  borderColor: Color(0xff999999),
                                                  child: chicago.ScrollableListView(
                                                    itemHeight: 19,
                                                    length: 6,
                                                    selectionController: imageSelectionController,
                                                    itemDisabledController: imageDisabledController,
                                                    itemBuilder: ({
                                                      required BuildContext context,
                                                      required int index,
                                                      required bool isSelected,
                                                      required bool isHighlighted,
                                                      required bool isDisabled,
                                                    }) {
                                                      const List<String> assets = [
                                                        'assets/anchor.png',
                                                        'assets/bell.png',
                                                        'assets/clock.png',
                                                        'assets/cup.png',
                                                        'assets/house.png',
                                                        'assets/star.png',
                                                      ];
                                                      const List<String> items = [
                                                        'Anchor',
                                                        'Bell',
                                                        'Clock',
                                                        'Cup',
                                                        'House',
                                                        'Star',
                                                      ];
                                                      return Row(
                                                        children: [
                                                          Image.asset(assets[index]),
                                                          SizedBox(width: 4),
                                                          Text(items[index],
                                                              style: isDisabled
                                                                  ? greyStyle
                                                                  : isSelected
                                                                      ? whiteStyle
                                                                      : baseStyle),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('List Buttons', style: boldStyle),
                                              SizedBox(height: 4),
                                              chicago.Form(
                                                children: [
                                                  chicago.FormField(
                                                    label: 'Basic',
                                                    child: chicago.ListButton(
                                                      items: [
                                                        'Red',
                                                        'Orange',
                                                        'Yellow',
                                                        'Green',
                                                        'Blue',
                                                        'Purple'
                                                      ],
                                                      selectionController:
                                                          basicButtonSelectionController,
                                                    ),
                                                  ),
                                                  chicago.FormField(
                                                    label: 'Image',
                                                    child: chicago.ListButton(
                                                      items: [
                                                        'anchor',
                                                        'bell',
                                                        'clock',
                                                        'cup',
                                                        'house',
                                                        'star'
                                                      ],
                                                      selectionController:
                                                          imageButtonSelectionController,
                                                      builder: (BuildContext context, String? item,
                                                          bool isForMeasurementOnly) {
                                                        final String asset = item as String;
                                                        final String path = 'assets/$asset.png';
                                                        final String label =
                                                            asset[0].toUpperCase() +
                                                                asset.substring(1);
                                                        return Padding(
                                                          padding: EdgeInsets.all(1),
                                                          child: Row(
                                                            children: [
                                                              Image.asset(path),
                                                              SizedBox(width: 4),
                                                              Text(
                                                                label,
                                                                maxLines: 1,
                                                                softWrap: false,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      itemBuilder: (
                                                        BuildContext context,
                                                        Object? item,
                                                        bool isSelected,
                                                        bool isHighlighted,
                                                        bool isDisabled,
                                                      ) {
                                                        final String asset = item as String;
                                                        final String path = 'assets/$asset.png';
                                                        final String label =
                                                            asset[0].toUpperCase() +
                                                                asset.substring(1);
                                                        return Padding(
                                                          padding: EdgeInsets.all(5),
                                                          child: Row(
                                                            children: [
                                                              Image.asset(path),
                                                              SizedBox(width: 4),
                                                              Text(
                                                                label,
                                                                maxLines: 1,
                                                                softWrap: false,
                                                                style: isDisabled
                                                                    ? greyStyle
                                                                    : isSelected
                                                                        ? whiteStyle
                                                                        : baseStyle,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text('Calendars', style: headerStyle),
                                  chicago.Border(
                                    backgroundColor: Color(0xffffffff),
                                    borderColor: Color(0xff999999),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(6, 4, 6, 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Basic', style: boldStyle),
                                              chicago.Calendar(
                                                initialYear: 2021,
                                                initialMonth: 2,
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Calendar Buttons', style: boldStyle),
                                              chicago.CalendarButton(
                                                initialSelectedDate: chicago.CalendarDate.today(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text('Splitters', style: headerStyle),
                                  chicago.Border(
                                    borderColor: Color(0xff999999),
                                    backgroundColor: Color(0xffffffff),
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: SizedBox(
                                        width: 400,
                                        height: 360,
                                        child: chicago.SplitPane(
                                          orientation: Axis.vertical,
                                          initialSplitRatio: 0.5,
                                          before: chicago.SplitPane(
                                            orientation: Axis.horizontal,
                                            initialSplitRatio: 0.5,
                                            before: chicago.Border(
                                                borderColor: Color(0xff999999),
                                                child: Image.asset('assets/bell.png')),
                                            after: chicago.Border(
                                                borderColor: Color(0xff999999),
                                                child: Image.asset('assets/clock.png')),
                                          ),
                                          after: chicago.Border(
                                              borderColor: Color(0xff999999),
                                              child: Image.asset('assets/star.png')),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text('Spinners', style: headerStyle),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      chicago.Border(
                                        borderColor: Color(0xff999999),
                                        backgroundColor: Color(0xffffffff),
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Text('Spinners', style: boldStyle),
                                              // SizedBox(height: 4),
                                              chicago.Form(
                                                children: [
                                                  chicago.FormField(
                                                    label: 'Basic',
                                                    child: chicago.Spinner(
                                                      length: 5,
                                                      isCircular: true,
                                                      sizeToContent: true,
                                                      controller: basicSpinnerController,
                                                      itemBuilder: (context, index, isEnabled) {
                                                        const List<String> numbers = [
                                                          'One',
                                                          'Two',
                                                          'Three',
                                                          'Four',
                                                          'Five'
                                                        ];
                                                        return Text(numbers[index]);
                                                      },
                                                    ),
                                                  ),
                                                  chicago.FormField(
                                                    label: 'Numeric',
                                                    child: SizedBox(
                                                      width: 60,
                                                      child: chicago.Spinner(
                                                        length: 260 ~/ 4,
                                                        controller: numericSpinnerController,
                                                        itemBuilder: (context, index, isEnabled) {
                                                          return Text('${index * 4}');
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  chicago.FormField(
                                                    label: 'Date',
                                                    child: chicago.Spinner(
                                                      length: 365,
                                                      controller: dateSpinnerController,
                                                      itemBuilder: (context, index, isEnabled) {
                                                        const chicago.CalendarDate baseDate =
                                                            chicago.CalendarDate(2019, 11, 30);
                                                        final chicago.CalendarDate date =
                                                            baseDate + index;
                                                        return Text(date.toString());
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      // chicago.Border(
                                      //   borderColor: Color(0xff999999),
                                      //   backgroundColor: Color(0xffffffff),
                                      //   child: Padding(
                                      //     padding: EdgeInsets.all(2),
                                      //     child: Column(
                                      //       children: [
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Text('Tables', style: headerStyle),
                                  chicago.Border(
                                    borderColor: Color(0xff999999),
                                    backgroundColor: Color(0xffffffff),
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Sortable', style: boldStyle),
                                              SizedBox(
                                                width: 276,
                                                height: 160,
                                                child: chicago.Border(
                                                  borderColor: Color(0xff999999),
                                                  child: chicago.ScrollableTableView(
                                                    selectionController: tableSelectionController,
                                                    sortController: tableSortController,
                                                    metricsController: tableMetricsController,
                                                    scrollController: tableScrollController,
                                                    includeHeader: true,
                                                    rowHeight: 19,
                                                    length: tableLength,
                                                    columns: [
                                                      _createTableColumn('i', '#'),
                                                      _createTableColumn('a', 'A'),
                                                      _createTableColumn('b', 'B'),
                                                      _createTableColumn('c', 'C'),
                                                      _createTableColumn('d', 'D'),
                                                      _createFlexTableColumn(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Custom Content', style: boldStyle),
                                              SizedBox(
                                                width: 276,
                                                height: 160,
                                                child: chicago.Border(
                                                  borderColor: Color(0xff999999),
                                                  child: chicago.ScrollableTableView(
                                                    selectionController:
                                                        customTableSelectionController,
                                                    includeHeader: true,
                                                    rowHeight: 19,
                                                    length: 6,
                                                    columns: [
                                                      chicago.TableColumnController(
                                                        key: 'flag',
                                                        width: chicago.FixedTableColumnWidth(20),
                                                        headerRenderer: ({
                                                          required BuildContext context,
                                                          required int columnIndex,
                                                        }) {
                                                          return Image.asset('assets/flag_red.png');
                                                        },
                                                        cellRenderer: ({
                                                          required BuildContext context,
                                                          required int rowIndex,
                                                          required int columnIndex,
                                                          required bool rowSelected,
                                                          required bool rowHighlighted,
                                                          required bool isEditing,
                                                          required bool isRowDisabled,
                                                        }) {
                                                          final bool checked =
                                                              customTableCheckmarks[rowIndex];
                                                          VoidCallback handleChange = () {
                                                            customTableCheckmarks[rowIndex] =
                                                                !customTableCheckmarks[rowIndex];
                                                            main();
                                                          };
                                                          return Padding(
                                                            padding: EdgeInsets.all(2),
                                                            child: chicago.BasicCheckbox(
                                                              checked: checked,
                                                              onTap: handleChange,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      chicago.TableColumnController(
                                                        key: 'icon',
                                                        width: chicago.ConstrainedTableColumnWidth(
                                                            width: 50),
                                                        headerRenderer: ({
                                                          required BuildContext context,
                                                          required int columnIndex,
                                                        }) {
                                                          return Text('Icon');
                                                        },
                                                        cellRenderer: ({
                                                          required BuildContext context,
                                                          required int rowIndex,
                                                          required int columnIndex,
                                                          required bool rowSelected,
                                                          required bool rowHighlighted,
                                                          required bool isEditing,
                                                          required bool isRowDisabled,
                                                        }) {
                                                          final String value =
                                                              customTableData[rowIndex];
                                                          final String asset = 'assets/$value.png';
                                                          return Image.asset(asset);
                                                        },
                                                      ),
                                                      chicago.TableColumnController(
                                                        key: 'name',
                                                        width: chicago.FlexTableColumnWidth(),
                                                        headerRenderer: ({
                                                          required BuildContext context,
                                                          required int columnIndex,
                                                        }) {
                                                          return Text('Name');
                                                        },
                                                        cellRenderer: ({
                                                          required BuildContext context,
                                                          required int rowIndex,
                                                          required int columnIndex,
                                                          required bool rowSelected,
                                                          required bool rowHighlighted,
                                                          required bool isEditing,
                                                          required bool isRowDisabled,
                                                        }) {
                                                          final String value =
                                                              customTableData[rowIndex];
                                                          final String name =
                                                              value[0].toUpperCase() +
                                                                  value.substring(1);
                                                          return Text(name,
                                                              style: rowSelected
                                                                  ? whiteStyle
                                                                  : baseStyle);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text('Alerts', style: headerStyle),
                                  SizedBox(height: 4),
                                  chicago.Border(
                                    borderColor: Color(0xff999999),
                                    backgroundColor: const Color(0xffffffff),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 6),
                                          chicago.PushButton(
                                            label: 'Show Prompt',
                                            onPressed: () {
                                              chicago.Prompt.open(
                                                context: context,
                                                messageType: chicago.MessageType.error,
                                                message: 'This is an error message.',
                                                body: Container(),
                                                options: ['OK'],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
