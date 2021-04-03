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

import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/widgets.dart';

import 'text.dart';

class ListsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderText('Lists'),
        chicago.Border(
          borderColor: Color(0xff999999),
          backgroundColor: const Color(0xffffffff),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BasicListDemo(),
                SizedBox(width: 12),
                LazyListDemo(),
                SizedBox(width: 12),
                MultiSelectListDemo(),
                SizedBox(width: 12),
                ImageListDemo(),
                SizedBox(width: 12),
                ListButtonsDemo(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BasicListDemo extends StatefulWidget {
  @override
  _BasicListDemoState createState() => _BasicListDemoState();
}

class _BasicListDemoState extends State<BasicListDemo> {
  late chicago.ListViewSelectionController _selectionController;

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.ListViewSelectionController();
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('Basic'),
        SizedBox(height: 4),
        SizedBox(
          width: 72,
          height: 90,
          child: chicago.Border(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableListView(
              itemHeight: 19,
              length: 6,
              selectionController: _selectionController,
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
                String text = colors[index];
                return isSelected ? WhiteText(text) : Text(text);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LazyListDemo extends StatefulWidget {
  @override
  _LazyListDemoState createState() => _LazyListDemoState();
}

class _LazyListDemoState extends State<LazyListDemo> {
  late chicago.ListViewSelectionController _selectionController;

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.ListViewSelectionController();
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('Lazy'),
        SizedBox(height: 4),
        SizedBox(
          width: 90,
          height: 90,
          child: chicago.Border(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableListView(
              itemHeight: 19,
              length: 1000000,
              selectionController: _selectionController,
              itemBuilder: ({
                required BuildContext context,
                required int index,
                required bool isSelected,
                required bool isHighlighted,
                required bool isDisabled,
              }) {
                String text = '${index + 1}';
                return isSelected ? WhiteText(text) : Text(text);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MultiSelectListDemo extends StatefulWidget {
  @override
  _MultiSelectListDemoState createState() => _MultiSelectListDemoState();
}

class _MultiSelectListDemoState extends State<MultiSelectListDemo> {
  late chicago.ListViewSelectionController _selectionController;

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.ListViewSelectionController(selectMode: chicago.SelectMode.multi)
      ..selectedRanges = [chicago.Span(0, 0), chicago.Span(2, 3)];
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('Multi-Select'),
        SizedBox(height: 4),
        SizedBox(
          width: 90,
          height: 90,
          child: chicago.Border(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableListView(
              itemHeight: 19,
              length: 6,
              selectionController: _selectionController,
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
                String text = shapes[index];
                return isSelected ? WhiteText(text) : Text(text);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ImageListDemo extends StatefulWidget {
  @override
  _ImageListDemoState createState() => _ImageListDemoState();
}

class _ImageListDemoState extends State<ImageListDemo> {
  late chicago.ListViewSelectionController _selectionController;
  late chicago.ListViewItemDisablerController _disablerController;

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.ListViewSelectionController();
    _disablerController = chicago.ListViewItemDisablerController()
      ..filter = (int index) => index == 2 || index == 3;
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _disablerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('Image'),
        SizedBox(height: 4),
        SizedBox(
          width: 90,
          height: 90,
          child: chicago.Border(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableListView(
              itemHeight: 19,
              length: 6,
              selectionController: _selectionController,
              itemDisabledController: _disablerController,
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
                    isDisabled
                        ? GreyText(items[index])
                        : isSelected
                            ? WhiteText(items[index])
                            : Text(items[index]),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ListButtonsDemo extends StatefulWidget {
  @override
  _ListButtonsDemoState createState() => _ListButtonsDemoState();
}

class _ListButtonsDemoState extends State<ListButtonsDemo> {
  late chicago.ListViewSelectionController _basicSelectionController;
  late chicago.ListViewSelectionController _imageSelectionController;

  @override
  void initState() {
    super.initState();
    _basicSelectionController = chicago.ListViewSelectionController()..selectedIndex = 0;
    _imageSelectionController = chicago.ListViewSelectionController()..selectedIndex = 2;
  }

  @override
  void dispose() {
    _basicSelectionController.dispose();
    _imageSelectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('List Buttons'),
        SizedBox(height: 4),
        chicago.Form(
          children: [
            chicago.FormField(
              label: 'Basic',
              child: chicago.ListButton(
                items: ['Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Purple'],
                selectionController: _basicSelectionController,
              ),
            ),
            chicago.FormField(
              label: 'Image',
              child: chicago.ListButton(
                items: ['anchor', 'bell', 'clock', 'cup', 'house', 'star'],
                selectionController: _imageSelectionController,
                builder: (BuildContext context, String? item, bool isForMeasurementOnly) {
                  final String asset = item as String;
                  final String path = 'assets/$asset.png';
                  final String label = asset[0].toUpperCase() + asset.substring(1);
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
                  final String label = asset[0].toUpperCase() + asset.substring(1);
                  return Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Image.asset(path),
                        SizedBox(width: 4),
                        isDisabled
                            ? GreyText(label)
                            : isSelected
                                ? WhiteText(label)
                                : Text(label),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
