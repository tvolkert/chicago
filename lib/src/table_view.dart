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
import 'sorting.dart';

class TableColumn extends BasicTableColumn {
  const TableColumn({
    TableColumnWidth width = const FlexTableColumnWidth(),
    @required TableCellRenderer cellRenderer,
    @required this.name,
    this.sortDirection,
  }) : super(width: width, cellRenderer: cellRenderer);

  final String name;
  final SortDirection sortDirection;

  TableColumn withRenderer(TableCellRenderer cellRenderer) {
    return TableColumn(
      width: width,
      cellRenderer: cellRenderer,
      name: name,
      sortDirection: sortDirection,
    );
  }
}

typedef TableColumnResizeCallback = void Function(int columnIndex, double delta);

class TableViewHeader extends StatelessWidget {
  const TableViewHeader({
    Key key,
    this.rowHeight,
    this.columns,
    this.handleColumnResize,
  }) : super(key: key);

  final double rowHeight;
  final List<TableColumn> columns;
  final TableColumnResizeCallback handleColumnResize;

  Widget _renderHeader({
    BuildContext context,
    int rowIndex,
    int columnIndex,
  }) {
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
          Expanded(child: Text(columns[columnIndex].name)),
          if (columnIndex < columns.length - 1 && handleColumnResize != null)
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
      columns: columns.map((TableColumn column) {
        return column.withRenderer(_renderHeader);
      }).toList(),
    );
  }
}

class TableView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasicTableView(
      length: null,
      columns: null,
      rowHeight: null,
    );
  }
}
