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

import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/widgets.dart';

import 'text.dart';

typedef TableRowComparator = int Function(Map<String, int> row1, Map<String, int> row2);

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

class TablesDemo extends StatelessWidget {
  const TablesDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chicago.Rollup(
      heading: const HeaderText('Tables'),
      childBuilder: (BuildContext context) {
        return chicago.BorderPane(
          borderColor: const Color(0xff999999),
          backgroundColor: const Color(0xffffffff),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                SortableTableDemo(),
                SizedBox(width: 8),
                CustomTableDemo(),
                SizedBox(width: 8),
                EditableTableDemo(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SortableTableDemo extends StatefulWidget {
  const SortableTableDemo({Key? key}) : super(key: key);

  @override
  _SortableTableDemoState createState() => _SortableTableDemoState();
}

class _SortableTableDemoState extends State<SortableTableDemo> {
  late chicago.TableViewSelectionController _selectionController;
  late chicago.TableViewSortController _sortController;
  late chicago.TableViewMetricsController _metricsController;
  late chicago.ScrollController _scrollController;

  static chicago.TableColumnController _createTableColumn(String key, String name) {
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

  static chicago.TableColumnController _createFlexTableColumn() {
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

  static TableRowComparator _getTableRowComparator(
    String sortKey,
    chicago.SortDirection direction,
  ) {
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

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.TableViewSelectionController();
    _sortController = chicago.TableViewSortController();
    _metricsController = chicago.TableViewMetricsController();
    _scrollController = chicago.ScrollController();

    _sortController['i'] = chicago.SortDirection.ascending;
    _sortController.addListener(chicago.TableViewSortListener(
      onChanged: (chicago.TableViewSortController controller) {
        final String sortKey = controller.keys.first;
        final chicago.SortDirection direction = controller[sortKey]!;

        Map<String, int>? selectedItem;
        if (_selectionController.selectedIndex != -1) {
          selectedItem = tableData[_selectionController.selectedIndex];
        }

        final TableRowComparator comparator = _getTableRowComparator(sortKey, direction);
        tableData.sort(comparator);

        if (selectedItem != null) {
          int selectedIndex = chicago.binarySearch(tableData, selectedItem, compare: comparator);
          assert(selectedIndex >= 0);
          _selectionController.selectedIndex = selectedIndex;
          final Rect rowBounds = _metricsController.metrics.getRowBounds(selectedIndex);
          _scrollController.scrollToVisible(rowBounds);
        }
      },
    ));
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _sortController.dispose();
    _metricsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('Sortable'),
        SizedBox(height: 4),
        SizedBox(
          width: 276,
          height: 160,
          child: chicago.BorderPane(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableTableView(
              selectionController: _selectionController,
              sortController: _sortController,
              metricsController: _metricsController,
              scrollController: _scrollController,
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
    );
  }
}

class CustomTableDemo extends StatefulWidget {
  const CustomTableDemo({Key? key}) : super(key: key);

  @override
  _CustomTableDemoState createState() => _CustomTableDemoState();
}

class _CustomItem {
  const _CustomItem(this.asset, this.name, this.isChecked);

  final String asset;
  final String name;
  final bool isChecked;

  _CustomItem toggleChecked() => _CustomItem(asset, name, !isChecked);
}

class _CustomTableDemoState extends State<CustomTableDemo> {
  late chicago.TableViewSelectionController _selectionController;
  late List<_CustomItem> _items;

  static Widget _buildIsCheckedHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return Image.asset('assets/flag_red.png');
  }

  Widget _buildIsCheckedCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowSelected,
    required bool rowHighlighted,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    final _CustomItem item = _items[rowIndex];
    return Padding(
      padding: EdgeInsets.all(2),
      child: chicago.BasicCheckbox(
        state: item.isChecked ? chicago.CheckboxState.checked : chicago.CheckboxState.unchecked,
        onTap: () {
          setState(() {
            _items[rowIndex] = _items[rowIndex].toggleChecked();
          });
        },
      ),
    );
  }

  static Widget _buildIconHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return Text('Icon');
  }

  Widget _buildIconCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowSelected,
    required bool rowHighlighted,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    final _CustomItem item = _items[rowIndex];
    final String asset = 'assets/${item.asset}.png';
    return Image.asset(asset);
  }

  static Widget _buildNameHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return Text('Name');
  }

  Widget _buildNameCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowSelected,
    required bool rowHighlighted,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    final _CustomItem item = _items[rowIndex];
    return rowSelected ? WhiteText(item.name) : Text(item.name);
  }

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.TableViewSelectionController(
      selectMode: chicago.SelectMode.multi,
    );
    _items = <_CustomItem>[
      _CustomItem('anchor', 'Anchor', true),
      _CustomItem('bell', 'Bell', false),
      _CustomItem('clock', 'Clock', false),
      _CustomItem('cup', 'Cup', true),
      _CustomItem('house', 'House', false),
      _CustomItem('star', 'Star', false),
    ];
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
        const BoldText('Custom Content'),
        SizedBox(height: 4),
        SizedBox(
          width: 276,
          height: 160,
          child: chicago.BorderPane(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableTableView(
              selectionController: _selectionController,
              includeHeader: true,
              rowHeight: 19,
              length: 6,
              columns: [
                chicago.TableColumnController(
                  key: 'flag',
                  width: chicago.FixedTableColumnWidth(20),
                  headerRenderer: _buildIsCheckedHeader,
                  cellRenderer: _buildIsCheckedCell,
                ),
                chicago.TableColumnController(
                  key: 'icon',
                  width: chicago.ConstrainedTableColumnWidth(width: 50),
                  headerRenderer: _buildIconHeader,
                  cellRenderer: _buildIconCell,
                ),
                chicago.TableColumnController(
                  key: 'name',
                  width: chicago.FlexTableColumnWidth(),
                  headerRenderer: _buildNameHeader,
                  cellRenderer: _buildNameCell,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EditableTableDemo extends StatefulWidget {
  const EditableTableDemo({Key? key}) : super(key: key);

  @override
  _EditableTableDemoState createState() => _EditableTableDemoState();
}

class _EditableItem {
  const _EditableItem(this.animal, this.name);

  final String animal;
  final String name;
}

class _EditableTableDemoState extends State<EditableTableDemo> {
  late chicago.TableViewSelectionController _selectionController;
  late chicago.TableViewEditorController _editorController;
  late TextEditingController _textController;
  late chicago.ListViewSelectionController _listButtonController;
  late List<_EditableItem> _items;

  static const List<String> editableTableListButtonOptions = [
    'Dog',
    'Cat',
    'Snake',
    'Fish',
    'Bird',
  ];

  static Widget _buildTypeHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return Text('Type');
  }

  Widget _buildTypeCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowSelected,
    required bool rowHighlighted,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    if (isEditing) {
      return chicago.ListButton<String>(
        items: editableTableListButtonOptions,
        selectionController: _listButtonController,
      );
    } else {
      final String text = _items[rowIndex].animal;
      return Padding(
        padding: EdgeInsets.all(2),
        child: rowSelected ? WhiteText(text) : Text(text),
      );
    }
  }

  static Widget _buildNameHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return Text('Name');
  }

  Widget _buildNameCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowSelected,
    required bool rowHighlighted,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    if (isEditing) {
      return chicago.TextInput(
        controller: _textController,
      );
    } else {
      final String text = _items[rowIndex].name;
      return Padding(
        padding: EdgeInsets.all(2),
        child: rowSelected ? WhiteText(text) : Text(text),
      );
    }
  }

  static Widget _buildFlexHeader({
    required BuildContext context,
    required int columnIndex,
  }) {
    return Container();
  }

  static Widget _buildFlexCell({
    required BuildContext context,
    required int rowIndex,
    required int columnIndex,
    required bool rowSelected,
    required bool rowHighlighted,
    required bool isEditing,
    required bool isRowDisabled,
  }) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.TableViewSelectionController();
    _editorController = chicago.TableViewEditorController();
    _textController = TextEditingController();
    _listButtonController = chicago.ListViewSelectionController();
    _items = <_EditableItem>[
      _EditableItem('Dog', 'Boomer'),
      _EditableItem('Dog', 'Faith'),
      _EditableItem('Cat', 'Sasha'),
      _EditableItem('Snake', 'Goliath'),
    ];

    int editingRowIndex = -1;
    _editorController.addListener(chicago.TableViewEditorListener(
      onPreviewEditStarted: (
        chicago.TableViewEditorController controller,
        int rowIndex,
        int columnIndex,
      ) {
        _listButtonController.selectedIndex =
            editableTableListButtonOptions.indexOf(_items[rowIndex].animal);
        _textController.text = _items[rowIndex].name;
        editingRowIndex = rowIndex;
        return chicago.Vote.approve;
      },
      onEditFinished: (
        chicago.TableViewEditorController controller,
        chicago.TableViewEditOutcome outcome,
      ) {
        if (outcome == chicago.TableViewEditOutcome.saved) {
          final String animal = editableTableListButtonOptions[_listButtonController.selectedIndex];
          final String name = _textController.text;
          setState(() {
            _items[editingRowIndex] = _EditableItem(animal, name);
          });
        }
      },
    ));
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _editorController.dispose();
    _textController.dispose();
    _listButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('Editable'),
        SizedBox(height: 4),
        SizedBox(
          width: 276,
          height: 160,
          child: chicago.BorderPane(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableTableView(
              selectionController: _selectionController,
              editorController: _editorController,
              includeHeader: true,
              rowHeight: 23,
              length: _items.length,
              columns: [
                chicago.TableColumnController(
                  key: 'type',
                  width: chicago.ConstrainedTableColumnWidth(width: 100),
                  headerRenderer: _buildTypeHeader,
                  cellRenderer: _buildTypeCell,
                ),
                chicago.TableColumnController(
                  key: 'name',
                  width: chicago.ConstrainedTableColumnWidth(width: 100),
                  headerRenderer: _buildNameHeader,
                  cellRenderer: _buildNameCell,
                ),
                chicago.TableColumnController(
                  key: 'flex',
                  width: chicago.FlexTableColumnWidth(),
                  headerRenderer: _buildFlexHeader,
                  cellRenderer: _buildFlexCell,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
