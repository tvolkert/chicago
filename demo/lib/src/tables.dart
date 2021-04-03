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

final List<List<String>> editableTableData = <List<String>>[
  ['Dog', 'Boomer'],
  ['Dog', 'Faith'],
  ['Cat', 'Sasha'],
  ['Snake', 'Goliath'],
];

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

class TablesDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderText('Tables'),
        chicago.Border(
          borderColor: Color(0xff999999),
          backgroundColor: Color(0xffffffff),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SortableTableDemo(),
                SizedBox(width: 8),
                CustomTableDemo(),
                SizedBox(width: 8),
                EditableTableDemo(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SortableTableDemo extends StatefulWidget {
  @override
  _SortableTableDemoState createState() => _SortableTableDemoState();
}

class _SortableTableDemoState extends State<SortableTableDemo> {
  late chicago.TableViewSelectionController _selectionController;
  late chicago.TableViewSortController _sortController;
  late chicago.TableViewMetricsController _metricsController;
  late chicago.ScrollController _scrollController;

  static TableRowComparator _getTableRowComparator(
      String sortKey, chicago.SortDirection direction) {
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
        SizedBox(
          width: 276,
          height: 160,
          child: chicago.Border(
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
  @override
  _CustomTableDemoState createState() => _CustomTableDemoState();
}

class _CustomTableDemoState extends State<CustomTableDemo> {
  late chicago.TableViewSelectionController _selectionController;

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.TableViewSelectionController(
      selectMode: chicago.SelectMode.multi,
    );
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
        BoldText('Custom Content'),
        SizedBox(
          width: 276,
          height: 160,
          child: chicago.Border(
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
                    final bool checked = customTableCheckmarks[rowIndex];
                    return Padding(
                      padding: EdgeInsets.all(2),
                      child: chicago.BasicCheckbox(
                        checked: checked,
                        onTap: () {
                          setState(() {
                            customTableCheckmarks[rowIndex] = !customTableCheckmarks[rowIndex];
                          });
                        },
                      ),
                    );
                  },
                ),
                chicago.TableColumnController(
                  key: 'icon',
                  width: chicago.ConstrainedTableColumnWidth(width: 50),
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
                    final String value = customTableData[rowIndex];
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
                    final String value = customTableData[rowIndex];
                    final String name = value[0].toUpperCase() + value.substring(1);
                    return rowSelected ? WhiteText(name) : Text(name);
                  },
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
  @override
  _EditableTableDemoState createState() => _EditableTableDemoState();
}

class _EditableTableDemoState extends State<EditableTableDemo> {
  late chicago.TableViewSelectionController _selectionController;
  late chicago.TableViewEditorController _editorController;
  late TextEditingController _textController;
  late chicago.ListViewSelectionController _listButtonController;

  static const List<String> editableTableListButtonOptions = [
    'Dog',
    'Cat',
    'Snake',
    'Fish',
    'Bird',
  ];

  @override
  void initState() {
    super.initState();
    _selectionController = chicago.TableViewSelectionController();
    _editorController = chicago.TableViewEditorController();
    _textController = TextEditingController();
    _listButtonController = chicago.ListViewSelectionController();

    int editingRowIndex = -1;
    _editorController.addListener(chicago.TableViewEditorListener(
      onPreviewEditStarted: (
        chicago.TableViewEditorController controller,
        int rowIndex,
        int columnIndex,
      ) {
        _listButtonController.selectedIndex =
            editableTableListButtonOptions.indexOf(editableTableData[rowIndex][0]);
        _textController.text = editableTableData[rowIndex][1];
        editingRowIndex = rowIndex;
        return chicago.Vote.approve;
      },
      onEditFinished: (
        chicago.TableViewEditorController controller,
        chicago.TableViewEditOutcome outcome,
      ) {
        if (outcome == chicago.TableViewEditOutcome.saved) {
          editableTableData[editingRowIndex][0] =
              editableTableListButtonOptions[_listButtonController.selectedIndex];
          editableTableData[editingRowIndex][1] = _textController.text;
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
        SizedBox(
          width: 276,
          height: 160,
          child: chicago.Border(
            borderColor: Color(0xff999999),
            child: chicago.ScrollableTableView(
              selectionController: _selectionController,
              editorController: _editorController,
              includeHeader: true,
              rowHeight: 23,
              length: editableTableData.length,
              columns: [
                chicago.TableColumnController(
                  key: 'type',
                  width: chicago.ConstrainedTableColumnWidth(width: 100),
                  headerRenderer: ({
                    required BuildContext context,
                    required int columnIndex,
                  }) {
                    return Text('Type');
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
                    if (isEditing) {
                      return chicago.ListButton<String>(
                        items: editableTableListButtonOptions,
                        selectionController: _listButtonController,
                      );
                    } else {
                      final String text = editableTableData[rowIndex][columnIndex];
                      return Padding(
                        padding: EdgeInsets.all(2),
                        child: rowSelected ? WhiteText(text) : Text(text),
                      );
                    }
                  },
                ),
                chicago.TableColumnController(
                  key: 'name',
                  width: chicago.ConstrainedTableColumnWidth(width: 100),
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
                    if (isEditing) {
                      return chicago.TextInput(
                        controller: _textController,
                      );
                    } else {
                      final String text = editableTableData[rowIndex][columnIndex];
                      return Padding(
                        padding: EdgeInsets.all(2),
                        child: rowSelected ? WhiteText(text) : Text(text),
                      );
                    }
                  },
                ),
                chicago.TableColumnController(
                  key: 'flex',
                  width: chicago.FlexTableColumnWidth(),
                  headerRenderer: ({
                    required BuildContext context,
                    required int columnIndex,
                  }) {
                    return Container();
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
