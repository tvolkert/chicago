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

void main() {
  testWidgets('Relative-width column with colspan will be allocated enough to fit intrinsic width', (WidgetTester tester) async {
    await tester.pumpWidget(Row(
      textDirection: TextDirection.ltr,
      children: [
        TablePane(
          columns: const <TablePaneColumn>[
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
          ],
          children: [
            TableRow(
              children: [
                const TableCell(
                  columnSpan: 2,
                  child: SizedBox(width: 100, height: 10),
                ),
                EmptyTableCell(),
              ],
            ),
          ],
        ),
      ],
    ));

    RenderTablePane renderObject = tester.renderObject<RenderTablePane>(find.byType(TablePane));
    expect(renderObject.size.width, 100);
    expect(renderObject.metrics.columnWidths, [50, 50]);
  });

  testWidgets('Relative-width column with colspan that exceeds width constraint will be sized down', (WidgetTester tester) async {
    await tester.pumpWidget(TablePane(
      columns: const <TablePaneColumn>[
        TablePaneColumn(width: RelativeTablePaneColumnWidth()),
        TablePaneColumn(width: RelativeTablePaneColumnWidth()),
      ],
      children: [
        TableRow(
          children: [
            const TableCell(
              columnSpan: 2,
              child: SizedBox(width: 1000, height: 10),
            ),
            EmptyTableCell(),
          ],
        ),
      ],
    ));

    RenderTablePane renderObject = tester.renderObject<RenderTablePane>(find.byType(TablePane));
    expect(renderObject.size.width, 800);
    expect(renderObject.metrics.columnWidths, [400, 400]);
  });

  testWidgets('todo', (WidgetTester tester) async {
    await tester.pumpWidget(Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 400),
        child: TablePane(
          columns: const <TablePaneColumn>[
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
            TablePaneColumn(width: RelativeTablePaneColumnWidth()),
          ],
          children: [
            TableRow(
              children: [
                const TableCell(
                  columnSpan: 2,
                  child: SizedBox(width: 100, height: 10),
                ),
                EmptyTableCell(),
              ],
            ),
          ],
        ),
      ),
    ));

    RenderTablePane renderObject = tester.renderObject<RenderTablePane>(find.byType(TablePane));
    expect(renderObject.size.width, 400);
    expect(renderObject.metrics.columnWidths, [200, 200]);
  });
}
