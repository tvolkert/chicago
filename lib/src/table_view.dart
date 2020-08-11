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

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' hide TableColumnWidth;
import 'package:flutter/widgets.dart' hide TableColumnWidth;

import 'basic_table_view.dart';
import 'scroll_pane.dart';
import 'sorting.dart';

typedef TableHeaderRenderer = Widget Function({BuildContext context, int columnIndex});

class TableColumnController with ChangeNotifier {
  TableColumnController({
    this.cellRenderer,
    this.name,
    this.headerRenderer,
    TableColumnWidth width,
    SortDirection sortDirection,
  })  : assert(width != null),
        _width = width;

  final TableCellRenderer cellRenderer;
  final String name;
  final TableHeaderRenderer headerRenderer;

  TableColumnWidth _width;
  TableColumnWidth get width => _width;
  set width(TableColumnWidth value) {
    assert(value != null);
    if (value == _width) return;
    _width = value;
    notifyListeners();
  }

  SortDirection _sortDirection;
  SortDirection get sortDirection => _sortDirection;
  set sortDirection(SortDirection value) {
    assert(value != null);
    if (value == _sortDirection) return;
    _sortDirection = value;
    notifyListeners();
  }
}

class ConstrainedTableColumnWidth extends TableColumnWidth {
  const ConstrainedTableColumnWidth({
    double width,
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
  })  : assert(width != null),
        assert(width >= 0),
        assert(width < double.infinity),
        assert(minWidth != null),
        assert(minWidth >= 0),
        assert(maxWidth != null),
        assert(maxWidth >= minWidth),
        super(width);

  final double minWidth;
  final double maxWidth;

  ConstrainedTableColumnWidth copyWith({
    double width,
    double minWidth,
    double maxWidth,
  }) {
    minWidth ??= this.minWidth;
    maxWidth ??= this.maxWidth;
    width ??= this.width;
    width = width.clamp(minWidth, maxWidth);
    return ConstrainedTableColumnWidth(
      width: width,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('minWidth', minWidth));
    properties.add(DoubleProperty('maxWidth', maxWidth));
  }
}

typedef TableColumnResizeCallback = void Function(int columnIndex, double delta);

class TableViewHeader extends StatelessWidget {
  const TableViewHeader({
    Key key,
    this.rowHeight,
    this.columns,
    this.headerRenderers,
    this.handleColumnResize,
  }) : super(key: key);

  final double rowHeight;
  final List<BasicTableColumn> columns;
  final List<TableHeaderRenderer> headerRenderers;
  final TableColumnResizeCallback handleColumnResize;

  Widget _renderHeader({
    BuildContext context,
    int rowIndex,
    int columnIndex,
  }) {
    final BasicTableColumn column = columns[columnIndex];
    final bool isColumnResizable = column.width is ConstrainedTableColumnWidth;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            const Color(0xffdfded7),
            const Color(0xfff6f4ed),
          ],
        ),
        border: Border(
          bottom: const BorderSide(color: const Color(0xff999999)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 3),
              child: headerRenderers[columnIndex](context: context, columnIndex: columnIndex),
            ),
          ),
          if (handleColumnResize != null && isColumnResizable)
            SizedBox(
              width: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: const BorderSide(color: const Color(0xff999999)),
                  ),
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    key: Key('$this dividerKey $columnIndex'),
                    behavior: HitTestBehavior.translucent,
                    dragStartBehavior: DragStartBehavior.down,
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      handleColumnResize(columnIndex, details.primaryDelta);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasicTableView(
      rowHeight: rowHeight,
      length: 1,
      columns: List<BasicTableColumn>.generate(columns.length, (int index) {
        return BasicTableColumn(
          width: columns[index].width,
          cellRenderer: _renderHeader,
        );
      }),
    );
  }
}

class ScrollableTableView extends StatefulWidget {
  const ScrollableTableView({
    Key key,
    this.rowHeight,
    this.length,
    this.columns,
  }) : super(key: key);

  final double rowHeight;
  final int length;
  final List<TableColumnController> columns;

  @override
  _ScrollableTableViewState createState() => _ScrollableTableViewState();
}

class _ScrollableTableViewState extends State<ScrollableTableView> {
  List<BasicTableColumn> columns;
  List<TableHeaderRenderer> headerRenderers;

  void _updateColumns() {
    setState(() {
      columns = List<BasicTableColumn>.generate(widget.columns.length, (int index) {
        return BasicTableColumn(
          width: widget.columns[index].width,
          cellRenderer: widget.columns[index].cellRenderer,
        );
      });
      headerRenderers = List<TableHeaderRenderer>.generate(widget.columns.length, (int index) {
        return widget.columns[index].headerRenderer;
      });
    });
  }

  void _addColumnListener(TableColumnController column) {
    column.addListener(_updateColumns);
  }

  void _removeColumnListener(TableColumnController column) {
    column.removeListener(_updateColumns);
  }

  @override
  void initState() {
    super.initState();
    _updateColumns();
    widget.columns.forEach(_addColumnListener);
  }

  @override
  void dispose() {
    widget.columns.forEach(_removeColumnListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(ScrollableTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateColumns();
    oldWidget.columns.forEach(_removeColumnListener);
    widget.columns.forEach(_addColumnListener);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPane(
      horizontalScrollBarPolicy: ScrollBarPolicy.expand,
      verticalScrollBarPolicy: ScrollBarPolicy.auto,
      columnHeader: TableViewHeader(
        rowHeight: widget.rowHeight,
        columns: columns,
        headerRenderers: headerRenderers,
        handleColumnResize: (int columnIndex, double delta) {
          final TableColumnController column = widget.columns[columnIndex];
          assert(column.width is ConstrainedTableColumnWidth);
          final ConstrainedTableColumnWidth width = column.width;
          column.width = width.copyWith(width: width.width + delta);
        },
      ),
      view: BasicTableView(
        length: widget.length,
        rowHeight: widget.rowHeight,
        columns: columns,
      ),
    );
  }
}
