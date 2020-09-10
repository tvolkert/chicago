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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'foundation.dart';

void main() {
  runApp(
    ColoredBox(
      color: const Color(0xffffffff),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: TextStyle(fontFamily: 'Verdana', color: const Color(0xff000000)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicWidth(
                child: IntrinsicHeight(
                  child: TablePane(
                    verticalSize: MainAxisSize.min,
                    horizontalSpacing: 5,
                    verticalSpacing: 20,
                    columns: <TablePaneColumn>[
                      TablePaneColumn(width: RelativeTablePaneColumnWidth(weight: 2)),
                      TablePaneColumn(width: RelativeTablePaneColumnWidth(weight: 20)),
                      TablePaneColumn(width: RelativeTablePaneColumnWidth(weight: 1)),
                      TablePaneColumn(width: RelativeTablePaneColumnWidth(weight: 3)),
                      TablePaneColumn(width: RelativeTablePaneColumnWidth(weight: 1)),
                      TablePaneColumn(width: RelativeTablePaneColumnWidth(weight: 1)),
                    ],
                    children: <Widget>[
                      TableRow(
                        height: RelativeTablePaneRowHeight(weight: 5),
                        children: [
                          ColoredCell(),
                          ColoredCell(),
                          ColoredCell(),
                          ColoredCell(),
                          ColoredCell(),
                          ColoredCell(),
                        ],
                      ),
                      TableRow(
                        children: [
                          ColoredCell(),
                          TableCell(
                            rowSpan: 2,
                            child: ColoredCell(text: 'rowSpan=2'),
                          ),
                          ColoredCell(),
                          ColoredCell(),
                          ColoredCell(),
                          ColoredCell(),
                        ],
                      ),
                      TableRow(
                        children: [
                          ColoredCell(),
                          EmptyTableCell(),
                          ColoredCell(),
                          TableCell(
                            columnSpan: 2,
                            child: ColoredCell(text: 'columnSpan=2'),
                          ),
                          EmptyTableCell(),
                          ColoredCell(),
                        ],
                      ),
                      TableRow(
                        children: [
                          ColoredCell(),
                          ColoredCell(),
                          TableCell(
                            rowSpan: 3,
                            columnSpan: 3,
                            child: ColoredCell(text: 'rowSpan=3\ncolumnSpan=3'),
                          ),
                          EmptyTableCell(),
                          EmptyTableCell(),
                          ColoredCell(),
                        ],
                      ),
                      TableRow(
                        children: [
                          ColoredCell(),
                          ColoredCell(),
                          EmptyTableCell(),
                          EmptyTableCell(),
                          EmptyTableCell(),
                          ColoredCell(),
                        ],
                      ),
                      TableRow(
                        children: [
                          ColoredCell(),
                          ColoredCell(),
                          EmptyTableCell(),
                          EmptyTableCell(),
                          EmptyTableCell(),
                          ColoredCell(),
                        ],
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
  );
}

class ColoredCell extends StatelessWidget {
  const ColoredCell({this.text = 'cell'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final math.Random random = math.Random();
    return ColoredBox(
      color: Color(0xff000000 | random.nextInt(math.pow(256, 3))),
      child: Align(child: Text(text)),
    );
  }
}

typedef _IntrinsicComputer = double Function(RenderBox child, double crossAxisConstraint);

double _sum(double a, double b) => a + b;

class TablePaneColumn with Diagnosticable {
  const TablePaneColumn({
    this.width = const RelativeTablePaneColumnWidth(),
  });

  final TablePaneColumnWidth width;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TablePaneColumnWidth>('width', width));
  }
}

abstract class TablePaneColumnWidth with Diagnosticable {
  const TablePaneColumnWidth._();

  @protected
  double get width;

  @protected
  bool get isRelative;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DiagnosticsProperty<bool>('isRelative', isRelative));
  }
}

class IntrinsicTablePaneColumnWidth extends TablePaneColumnWidth {
  const IntrinsicTablePaneColumnWidth() : super._();

  @override
  @protected
  double get width => -1;

  @override
  @protected
  bool get isRelative => false;
}

class FixedTablePaneColumnWidth extends TablePaneColumnWidth {
  const FixedTablePaneColumnWidth(this.width)
      : assert(width != null),
        assert(width >= 0),
        super._();

  @override
  @protected
  final double width;

  @override
  @protected
  bool get isRelative => false;
}

class RelativeTablePaneColumnWidth extends TablePaneColumnWidth {
  const RelativeTablePaneColumnWidth({this.weight = 1}) : super._();

  final double weight;

  @override
  @protected
  double get width => weight;

  @override
  @protected
  bool get isRelative => true;
}

abstract class TablePaneRowHeight {
  const TablePaneRowHeight._();

  @protected
  double get height;

  @protected
  bool get isRelative;
}

class IntrinsicTablePaneRowHeight extends TablePaneRowHeight {
  const IntrinsicTablePaneRowHeight() : super._();

  @override
  @protected
  double get height => -1;

  @override
  @protected
  bool get isRelative => false;
}

class FixedTablePaneRowHeight extends TablePaneRowHeight {
  const FixedTablePaneRowHeight(this.height)
      : assert(height != null),
        assert(height >= 0),
        super._();

  @override
  @protected
  final double height;

  @override
  @protected
  bool get isRelative => false;
}

class RelativeTablePaneRowHeight extends TablePaneRowHeight {
  const RelativeTablePaneRowHeight({this.weight = 1}) : super._();

  final double weight;

  @override
  @protected
  double get height => weight;

  @override
  @protected
  bool get isRelative => true;
}

class TableCell extends ParentDataWidget<TableCellParentData> {
  /// Creates a widget that controls the row-span and column-span of a child of
  /// [TablePane].
  const TableCell({
    Key key,
    this.rowSpan = 1,
    this.columnSpan = 1,
    @required Widget child,
  })  : assert(rowSpan != null),
        assert(columnSpan != null),
        assert(rowSpan > 0),
        assert(columnSpan > 0),
        super(key: key, child: child);

  /// The number of rows this cell occupies.
  final int rowSpan;

  /// The number of columns this cell occupies.
  final int columnSpan;

  @override
  void applyParentData(RenderObject renderObject) {
    final TableCellParentData parentData = renderObject.parentData as TableCellParentData;
    if (parentData.rowSpan != rowSpan || parentData.columnSpan != columnSpan) {
      parentData.rowSpan = rowSpan;
      parentData.columnSpan = columnSpan;
      AbstractNode targetParent = renderObject.parent;
      while (targetParent != null && targetParent is! RenderTablePane) {
        targetParent = targetParent.parent;
      }
      if (targetParent is RenderTablePane) {
        targetParent.markNeedsMetrics();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableRow;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('rowSpan', rowSpan));
    properties.add(IntProperty('columnSpan', columnSpan));
  }
}

class EmptyTableCell extends LeafRenderObjectWidget {
  const EmptyTableCell({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderEmptyTableCell();
}

class TablePane extends MultiChildRenderObjectWidget {
  TablePane({
    Key key,
    @required this.columns,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 0,
    this.horizontalSize = MainAxisSize.min,
    this.verticalSize = MainAxisSize.min,
    @required List<Widget> children,
  })  : assert(horizontalSpacing != null),
        assert(verticalSpacing != null),
        assert(horizontalSize != null),
        assert(verticalSize != null),
        super(key: key, children: children);

  final List<TablePaneColumn> columns;
  final double horizontalSpacing;
  final double verticalSpacing;
  final MainAxisSize horizontalSize;
  final MainAxisSize verticalSize;

  @override
  List<Widget> get children => super.children;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTablePane(
      columns: columns,
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      horizontalSize: horizontalSize,
      verticalSize: verticalSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTablePane renderObject) {
    renderObject
      ..columns = columns
      ..horizontalSpacing = horizontalSpacing
      ..verticalSpacing = verticalSpacing
      ..horizontalSize = horizontalSize
      ..verticalSize = verticalSize;
  }
}

class TableRow extends MultiChildRenderObjectWidget {
  TableRow({
    Key key,
    this.height = const IntrinsicTablePaneRowHeight(),
    List<Widget> children,
  }) : super(key: key, children: children);

  final TablePaneRowHeight height;

  @override
  List<Widget> get children => super.children;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTableRow(height: height);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTableRow renderObject) {
    renderObject..height = height;
  }
}

/// [ParentData] used by [RenderTablePane].
class TableRowParentData extends ContainerBoxParentData<RenderTableRow> {}

/// [ParentData] used by [RenderTableRow].
class TableCellParentData extends ContainerBoxParentData<RenderBox> {
  /// The column that the child was in the last time it was laid out.
  int x;

  int _rowSpan = 1;
  int get rowSpan => _rowSpan;
  set rowSpan(int value) {
    assert(value != null);
    assert(value > 0);
    _rowSpan = value;
  }

  int _columnSpan = 1;
  int get columnSpan => _columnSpan;
  set columnSpan(int value) {
    assert(value != null);
    assert(value > 0);
    _columnSpan = value;
  }

  @override
  String toString() => '${super.toString()}; $rowSpan rows x $columnSpan columns';
}

class TableRowConstraints extends BoxConstraints {
  // const TableRowConstraints({
  //   double minWidth = 0,
  //   double maxWidth = double.infinity,
  //   double minHeight = 0,
  //   double maxHeight = double.infinity,
  //   @required this.cellConstraints,
  //   @required this.cellPositions,
  // }) : super(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight);

  TableRowConstraints.tightFor({
    double width,
    double height,
    @required this.cellConstraints,
    @required this.cellPositions,
  }) : super.tightFor(width: width, height: height);

  final List<BoxConstraints> cellConstraints;
  final List<Offset> cellPositions;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TableRowConstraints &&
        super == other &&
        const ListEquality().equals(other.cellConstraints, cellConstraints) &&
        const ListEquality().equals(other.cellPositions, cellPositions);
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(super.hashCode, hashList(cellConstraints), hashList(cellPositions));
  }

  @override
  String toString() {
    return 'TableRowConstraints(base=${super.toString()}, '
        'cellConstraints=$cellConstraints), '
        'cellPositions=$cellPositions';
  }
}

class RenderEmptyTableCell extends RenderBox {
  @override
  bool get sizedByParent => true;
}

mixin ChildListRenderObjectMixin<ChildType extends RenderBox,
        ParentDataType extends ContainerBoxParentData<ChildType>>
    on RenderBoxContainerDefaultsMixin<ChildType, ParentDataType> {
  List<RenderBox> _children;

  @protected
  List<RenderBox> get children {
    return _children ??= getChildrenAsList();
  }

  @protected
  void markNeedsChildren() {
    _children = null;
  }

  /// The number of children belonging to this render object.
  int get length => childCount;

  /// Gets the child at the specified index.
  RenderBox operator [](int index) => children[index];

  @override
  void insert(RenderBox child, {RenderBox after}) {
    super.insert(child, after: after);
    markNeedsChildren();
  }

  @override
  void remove(RenderBox child) {
    super.remove(child);
    markNeedsChildren();
  }

  @override
  void removeAll() {
    super.removeAll();
    markNeedsChildren();
  }

  @override
  void move(RenderBox child, {RenderBox after}) {
    super.move(child, after: after);
    markNeedsChildren();
  }
}

class RenderTableRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableCellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableCellParentData>,
        ChildListRenderObjectMixin<RenderBox, TableCellParentData> {
  RenderTableRow({TablePaneRowHeight height}) {
    this.height = height;
  }

  TablePaneRowHeight _height;
  TablePaneRowHeight get height => _height;
  set height(TablePaneRowHeight value) {
    assert(value != null);
    if (value != _height) {
      _height = value;
      markNeedsLayout();
      if (parent != null) {
        parent.markNeedsMetrics();
      }
    }
  }

  @override
  TableRowConstraints get constraints => super.constraints as TableRowConstraints;

  @override
  RenderTablePane get parent => super.parent as RenderTablePane;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableCellParentData) {
      child.parentData = TableCellParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    // RenderTablePane will always give us tight constraints
    assert(constraints.isTight);
    size = constraints.smallest;

    for (int i = 0; i < length; i++) {
      final RenderBox child = this[i];
      final BoxParentData childParentData = child.parentData as BoxParentData;
      child.layout(constraints.cellConstraints[i]);
      childParentData.offset = constraints.cellPositions[i];
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TablePaneRowHeight>('height', height));
  }
}

class RenderTablePane extends RenderBox
    with
        ContainerRenderObjectMixin<RenderTableRow, TableRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderTableRow, TableRowParentData>,
        ChildListRenderObjectMixin<RenderTableRow, TableRowParentData> {
  RenderTablePane({
    @required List<TablePaneColumn> columns,
    double horizontalSpacing = 0,
    double verticalSpacing = 0,
    MainAxisSize horizontalSize = MainAxisSize.max,
    MainAxisSize verticalSize = MainAxisSize.max,
  }) {
    this.columns = columns;
    this.horizontalSpacing = horizontalSpacing;
    this.verticalSpacing = verticalSpacing;
    this.horizontalSize = horizontalSize;
    this.verticalSize = verticalSize;
  }

  List<TablePaneColumn> _columns;
  List<TablePaneColumn> get columns => _columns;
  set columns(List<TablePaneColumn> value) {
    assert(value != null);
    if (!const ListEquality().equals(value, _columns)) {
      _columns = value;
      markNeedsMetrics();
    }
  }

  double _horizontalSpacing = 0;
  double get horizontalSpacing => _horizontalSpacing;
  set horizontalSpacing(double value) {
    assert(value != null);
    if (value != _horizontalSpacing) {
      _horizontalSpacing = value;
      markNeedsMetrics();
    }
  }

  double _verticalSpacing = 0;
  double get verticalSpacing => _verticalSpacing;
  set verticalSpacing(double value) {
    assert(value != null);
    if (value != _verticalSpacing) {
      _verticalSpacing = value;
      markNeedsMetrics();
    }
  }

  MainAxisSize _horizontalSize;
  MainAxisSize get horizontalSize => _horizontalSize;
  set horizontalSize(MainAxisSize value) {
    assert(value != null);
    if (value != _horizontalSize) {
      _horizontalSize = value;
      markNeedsMetrics();
    }
  }

  MainAxisSize _verticalSize;
  MainAxisSize get verticalSize => _verticalSize;
  set verticalSize(MainAxisSize value) {
    assert(value != null);
    if (value != _verticalSize) {
      _verticalSize = value;
      markNeedsMetrics();
    }
  }

  double _computeIntrinsicRowHeight(
    int rowIndex,
    List<double> columnWidths,
    _IntrinsicComputer computeIntrinsicCellHeight,
  ) {
    assert(rowIndex != null);
    assert(columnWidths != null);
    final RenderTableRow row = rows[rowIndex];
    double result = 0;
    for (int j = 0, n = row.length, m = columns.length; j < n && j < m; j++) {
      final RenderBox child = row[j];
      assert(child != null);
      final TableCellParentData childParentData = child.parentData as TableCellParentData;
      if (childParentData.rowSpan == 1) {
        result = math.max(result, computeIntrinsicCellHeight(child, columnWidths[j]));
      }
    }
    return result;
  }

  double _computeIntrinsicColumnWidth(
    int columnIndex,
    _IntrinsicComputer computeIntrinsicCellWidth,
  ) {
    double result = 0;
    for (int i = 0, n = rows.length; i < n; i++) {
      final RenderTableRow row = rows[i];
      if (columnIndex < row.length) {
        final RenderBox child = row[columnIndex];
        assert(child != null);
        final TableCellParentData childParentData = child.parentData as TableCellParentData;
        if (childParentData.columnSpan == 1) {
          result = math.max(result, computeIntrinsicCellWidth(child, double.infinity));
        }
      }
    }
    return result;
  }

  List<double> _computeIntrinsicRowHeights(
    double width,
    _IntrinsicComputer computeIntrinsicCellHeight,
  ) {
    assert(!width.isNegative);
    final List<double> rowHeights = List<double>.filled(rows.length, 0);
    final List<double> relativeWeights = List<double>.filled(rows.length, 0);
    final List<bool> defaultHeightRows = List<bool>.filled(rows.length, false);
    final List<double> columnWidths = width.isFinite
        ? _computeActualColumnWidths(LinearConstraints.tight(width))
        : _computeIntrinsicColumnWidths(double.infinity, (RenderBox child, double height) {
            return child.getMaxIntrinsicWidth(height);
          });

    // First, we calculate the base heights of the rows, giving relative
    // rows their preferred height
    double totalRelativeWeight = 0;
    for (int i = 0; i < rows.length; i++) {
      final TablePaneRowHeight heightSpec = rows[i].height;
      final double rowHeight = heightSpec.height;
      final bool isRelative = heightSpec.isRelative;

      defaultHeightRows[i] = (rowHeight < 0);

      if (isRelative) {
        relativeWeights[i] = rowHeight;
        totalRelativeWeight += rowHeight;
      }

      if (rowHeight < 0 || isRelative) {
        rowHeights[i] = _computeIntrinsicRowHeight(i, columnWidths, computeIntrinsicCellHeight);
      } else {
        rowHeights[i] = rowHeight;
      }
    }

    // Next, we adjust the heights of the relative rows upwards where
    // necessary to reconcile their heights relative to one another while
    // ensuring that they still get at least their preferred height
    if (totalRelativeWeight > 0) {
      // Calculate total relative height after the required upward adjustments
      double totalRelativeHeight = 0;
      for (int i = 0; i < rows.length; i++) {
        final double relativeWeight = relativeWeights[i];
        if (relativeWeight > 0) {
          final double rowHeight = rowHeights[i];
          final double weightPercentage = relativeWeight / totalRelativeWeight;
          totalRelativeHeight = math.max(totalRelativeHeight, rowHeight / weightPercentage);
        }
      }

      // Perform the upward adjustments using the total relative height
      for (int i = 0; i < rows.length; i++) {
        final double relativeWeight = relativeWeights[i];
        if (relativeWeight > 0) {
          final double weightPercentage = relativeWeight / totalRelativeWeight;
          rowHeights[i] = weightPercentage * totalRelativeHeight;
        }
      }
    }

    // Finally, we account for spanning cells, which have been ignored thus
    // far. If any spanned cell is default-height (including relative height
    // rows), then we ensure that the sum of the heights of the spanned cells
    // is enough to satisfy the preferred height of the spanning content
    for (int i = 0; i < rows.length; i++) {
      final RenderTableRow row = rows[i];
      for (int j = 0, n = row.length; j < n && j < columns.length; j++) {
        final RenderBox child = row[j];
        assert(child != null);

        if (child is! RenderEmptyTableCell) {
          final TableCellParentData childParentData = child.parentData as TableCellParentData;
          final int rowSpan = childParentData.rowSpan;

          if (rowSpan > 1) {
            // We might need to adjust row heights to accommodate this spanning
            // cell. First, we find out if any of the spanned cells are default
            // height and how much space we've allocated thus far for those cells

            int spannedDefaultHeightCellCount = 0;
            double spannedRelativeWeight = 0;
            double spannedHeight = 0;

            for (int k = 0; k < rowSpan && i + k < rows.length; k++) {
              spannedRelativeWeight += relativeWeights[i + k];
              spannedHeight += rowHeights[i + k];
              if (defaultHeightRows[i + k]) {
                spannedDefaultHeightCellCount++;
              }
            }

            if (spannedRelativeWeight > 0 || spannedDefaultHeightCellCount > 0) {
              final int columnSpan = childParentData.columnSpan;
              double childWidth = columnWidths.skip(j).take(columnSpan).fold<double>(0, _sum);
              childWidth += math.max(columnSpan - 1, 0) * horizontalSpacing;
              final double childIntrinsicHeight = computeIntrinsicCellHeight(child, childWidth);

              if (childIntrinsicHeight > spannedHeight) {
                // The component's intrinsic height is larger than the height
                // we've allocated thus far, so an adjustment is necessary
                final double adjustment = childIntrinsicHeight - spannedHeight;

                if (spannedRelativeWeight > 0) {
                  // We'll distribute the adjustment across the spanned
                  // relative rows and adjust other relative row heights to
                  // keep all relative row heights reconciled
                  final double unitAdjustment = adjustment / spannedRelativeWeight;

                  for (int k = 0; k < rows.length; k++) {
                    final double relativeWeight = relativeWeights[k];
                    if (relativeWeight > 0) {
                      final double rowAdjustment = unitAdjustment * relativeWeight;
                      rowHeights[k] += rowAdjustment;
                    }
                  }
                } else {
                  // We'll distribute the adjustment evenly among the
                  // default-height rows
                  for (int k = 0; k < rowSpan && i + k < rows.length; k++) {
                    if (defaultHeightRows[i + k]) {
                      final double rowAdjustment = adjustment / spannedDefaultHeightCellCount;
                      rowHeights[i + k] += rowAdjustment;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return rowHeights;
  }

  List<double> _computeActualRowHeights(
    LinearConstraints heightConstraints,
    List<double> columnWidths,
  ) {
    assert(heightConstraints != null);
    assert(heightConstraints.isNormalized);
    assert(columnWidths != null);
    final List<double> rowHeights = List<double>.filled(rows.length, 0);
    final List<bool> defaultHeightRows = List<bool>.filled(rows.length, false);

    // First, we allocate the heights of non-relative rows. We store the
    // heights of relative rows as negative values for later processing
    double totalRelativeWeight = 0;
    double reservedHeight = math.max(rows.length - 1, 0) * verticalSpacing;
    for (int i = 0; i < rows.length; i++) {
      final TablePaneRowHeight rowHeightSpec = rows[i].height;
      double rowHeight = rowHeightSpec.height;

      if (rowHeightSpec.isRelative) {
        rowHeights[i] = -rowHeight;
        totalRelativeWeight += rowHeight;
      } else {
        if (rowHeight < 0) {
          // Default height row; we must calculate the height
          defaultHeightRows[i] = true;
          switch (verticalSize) {
            case MainAxisSize.min:
              rowHeight = computeMinIntrinsicRowHeight(i, columnWidths);
              break;
            case MainAxisSize.max:
              rowHeight = computeMaxIntrinsicRowHeight(i, columnWidths);
              break;
          }
        }
        rowHeights[i] = rowHeight;
        reservedHeight += rowHeight;
      }
    }

    // Next, we we account for default-width columns containing spanning
    // cells, which have been ignored thus far. We ensure that the sum of
    // the widths of the spanned cells is enough to satisfy the preferred
    // width of the spanning content.
    for (int i = 0; i < rows.length; i++) {
      final RenderTableRow row = rows[i];
      for (int j = 0, n = row.length; j < n && j < columns.length; j++) {
        final RenderBox child = row[j];
        assert(child != null);
        row.setupParentData(child);
        final TableCellParentData childParentData = child.parentData as TableCellParentData;
        final int rowSpan = childParentData.rowSpan;

        if (rowSpan > 1) {
          // We might need to adjust row heights to accommodate this spanning
          // cell. First, we find out if any of the spanned cells are default
          // height and how much space we've allocated thus far for those cells
          bool didSpanRelativeRows = false;
          int spannedDefaultHeightCellCount = 0;
          double spannedHeight = 0;

          for (int k = 0; k < rowSpan && i + k < rows.length; k++) {
            if (rowHeights[i + k] < 0) {
              // See comment below about relative-height rows.
              didSpanRelativeRows = true;
              break;
            }

            if (defaultHeightRows[i + k]) {
              spannedDefaultHeightCellCount++;
            }

            spannedHeight += rowHeights[i + k];
          }

          // If we span any relative-height rows, we assume that we'll achieve
          // the desired spanning height when we divvy up the remaining space,
          // so there's no need to make an adjustment here. This assumption is
          // safe because our preferred height policy is to *either* divide the
          // adjustment among the relative-height rows *or* among the
          // default-height rows if we don't span any relative-height rows.
          if (!didSpanRelativeRows && spannedDefaultHeightCellCount > 0) {
            final int columnSpan = childParentData.columnSpan;
            double childWidth = columnWidths.skip(j).take(columnSpan).fold<double>(0, _sum);
            childWidth += math.max(columnSpan - 1, 0) * horizontalSpacing;
            double childIntrinsicHeight;
            switch (verticalSize) {
              case MainAxisSize.min:
                childIntrinsicHeight = child.getMinIntrinsicHeight(childWidth);
                break;
              case MainAxisSize.max:
                childIntrinsicHeight = child.getMaxIntrinsicHeight(childWidth);
                break;
            }

            if (childIntrinsicHeight > spannedHeight) {
              // The child's intrinsic height is larger than the height we've
              // allocated thus far, so an adjustment is necessary.
              final double adjustment = childIntrinsicHeight - spannedHeight;

              // We'll distribute the adjustment evenly among the
              // default-height rows
              for (int k = 0; k < rowSpan && i + k < rows.length; k++) {
                if (defaultHeightRows[i + k]) {
                  final double rowAdjustment = adjustment / spannedDefaultHeightCellCount;
                  rowHeights[i + k] += rowAdjustment;
                  reservedHeight += rowAdjustment;
                }
              }
            }
          }
        }
      }
    }

    // Finally, we allocate the heights of the relative rows by divvying
    // up the remaining height
    final double height = heightConstraints.constrainMainAxisSize(verticalSize);
    final double remainingHeight = math.max(height - reservedHeight, 0);
    if (totalRelativeWeight > 0) {
      assert(() {
        if (remainingHeight.isInfinite) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('RenderTablePane was given infinite height constraints with '
                'relative-height rows'),
            ErrorDescription(
                'Relative-height TableRow instances will fill the remaining space when a '
                'TablePane is laid out. If there is infinite space remaining, they have no '
                'way of knowing what height to be.'),
            ErrorSpacer(),
            DiagnosticsProperty<Object>(
              'The $runtimeType that contained a default-height row was created by',
              debugCreator,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
            ErrorSpacer(),
            DiagnosticsProperty<Object>(
              'The default-height row was created by',
              rows.firstWhere((RenderTableRow row) => row.height.isRelative).debugCreator,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ]);
        }
        return true;
      }());
      for (int i = 0; i < rows.length; i++) {
        if (rowHeights[i] < 0) {
          if (remainingHeight > 0) {
            final double relativeWeight = -rowHeights[i];
            final double weightPercentage = relativeWeight / totalRelativeWeight;
            rowHeights[i] = remainingHeight * weightPercentage;
          } else {
            rowHeights[i] = 0;
          }
        }
      }
    }

    assert(() {
      if (rowHeights.any((double value) => value.isNegative)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('RenderTablePane computed a negative-height row.'),
          ErrorDescription('This indicates a bug in RenderTablePane.'),
          ErrorSpacer(),
          DiagnosticsProperty<List<double>>('The computed row heights were', rowHeights),
          ErrorSpacer(),
          DiagnosticsProperty<Object>(
              'The RenderTablePane in question was created by', debugCreator,
              style: DiagnosticsTreeStyle.errorProperty),
        ]);
      }
      return true;
    }());

    return rowHeights;
  }

  List<double> _computeIntrinsicColumnWidths(
    double height,
    _IntrinsicComputer computeIntrinsicCellWidth,
  ) {
    final List<double> columnWidths = List<double>.filled(columns.length, 0);
    final List<double> relativeWeights = List<double>.filled(columns.length, 0);
    final List<bool> defaultWidthColumns = List<bool>.filled(columns.length, false);

    // First, we calculate the base widths of the columns, giving relative
    // columns their preferred width
    double totalRelativeWeight = 0;
    for (int i = 0; i < columns.length; i++) {
      final TablePaneColumnWidth columnWidthSpec = columns[i].width;
      final double columnWidth = columnWidthSpec.width;
      final bool isRelative = columnWidthSpec.isRelative;

      defaultWidthColumns[i] = (columnWidth < 0);

      if (isRelative) {
        relativeWeights[i] = columnWidth;
        totalRelativeWeight += columnWidth;
      }

      if (columnWidth < 0 || isRelative) {
        columnWidths[i] = _computeIntrinsicColumnWidth(i, computeIntrinsicCellWidth);
      } else {
        columnWidths[i] = columnWidth;
      }
    }

    // Next, we adjust the widths of the relative columns upwards where
    // necessary to reconcile their widths relative to one another while
    // ensuring that they still get at least their intrinsic width
    if (totalRelativeWeight > 0) {
      // Calculate total relative width after the required upward adjustments
      double totalRelativeWidth = 0;
      for (int i = 0; i < columns.length; i++) {
        final double relativeWeight = relativeWeights[i];
        if (relativeWeight > 0) {
          final double columnWidth = columnWidths[i];
          final double weightPercentage = relativeWeight / totalRelativeWeight;
          totalRelativeWidth = math.max(totalRelativeWidth, columnWidth / weightPercentage);
        }
      }

      // Perform the upward adjustments using the total relative width
      for (int i = 0; i < columns.length; i++) {
        final double relativeWeight = relativeWeights[i];
        if (relativeWeight > 0) {
          final double weightPercentage = relativeWeight / totalRelativeWeight;
          columnWidths[i] = weightPercentage * totalRelativeWidth;
        }
      }
    }

    // Finally, we account for spanning cells, which have been ignored thus
    // far. If any spanned cell is default-width (including relative width
    // columns), then we ensure that the sum of the widths of the spanned
    // cells is enough to satisfy the preferred width of the spanning content
    for (int i = 0; i < rows.length; i++) {
      final RenderTableRow row = rows[i];
      for (int j = 0, n = row.length; j < n && j < columns.length; j++) {
        final RenderBox child = row[j];
        assert(child != null);

        if (child is! RenderEmptyTableCell) {
          final TableCellParentData childParentData = child.parentData as TableCellParentData;
          final int columnSpan = childParentData.columnSpan;

          if (columnSpan > 1) {
            // We might need to adjust column widths to accommodate this
            // spanning cell. First, we find out if any of the spanned cells
            // are default width and how much space we've allocated thus far
            // for those cells.

            int spannedDefaultWidthCellCount = 0;
            double spannedRelativeWeight = 0;
            double spannedWidth = 0;
            for (int k = 0; k < columnSpan && j + k < columns.length; k++) {
              spannedRelativeWeight += relativeWeights[j + k];
              spannedWidth += columnWidths[j + k];
              if (defaultWidthColumns[j + k]) {
                spannedDefaultWidthCellCount++;
              }
            }

            if (spannedRelativeWeight > 0 || spannedDefaultWidthCellCount > 0) {
              bool isRelativeOrIntrinsic(TablePaneRowHeight spec) {
                return spec.isRelative || spec.height.isNegative;
              }

              final TablePaneRowHeight heightSpec = row.height;
              double heightConstraint;
              if (isRelativeOrIntrinsic(heightSpec)) {
                heightConstraint = double.infinity;
              } else {
                final int rowSpan = childParentData.rowSpan;
                final Iterable<TablePaneRowHeight> spannedRowHeights = rows
                    .map<TablePaneRowHeight>((RenderTableRow row) => row.height)
                    .skip(i)
                    .take(rowSpan);
                if (spannedRowHeights.any(isRelativeOrIntrinsic)) {
                  heightConstraint = double.infinity;
                } else {
                  heightConstraint = spannedRowHeights
                      .map<double>((TablePaneRowHeight spec) => spec.height)
                      .fold<double>(0, _sum);
                  heightConstraint += math.max(spannedRowHeights.length - 1, 0) * verticalSpacing;
                }
              }
              final double childIntrinsicWidth = computeIntrinsicCellWidth(child, heightConstraint);

              if (childIntrinsicWidth > spannedWidth) {
                // The child's preferred width is larger than the width we've
                // allocated thus far, so an adjustment is necessary.
                final double adjustment = childIntrinsicWidth - spannedWidth;

                if (spannedRelativeWeight > 0) {
                  // We'll distribute the adjustment across the spanned
                  // relative columns and adjust other relative column widths
                  // to keep all relative column widths reconciled.
                  final double unitAdjustment = adjustment / spannedRelativeWeight;
                  for (int k = 0; k < columns.length; k++) {
                    final double relativeWeight = relativeWeights[k];
                    if (relativeWeight > 0) {
                      final double columnAdjustment = unitAdjustment * relativeWeight;
                      columnWidths[k] += columnAdjustment;
                    }
                  }
                } else {
                  // We'll distribute the adjustment evenly among the
                  // default-width columns
                  for (int k = 0; k < columnSpan && j + k < columns.length; k++) {
                    if (defaultWidthColumns[j + k]) {
                      final double columnAdjustment = adjustment / spannedDefaultWidthCellCount;
                      columnWidths[j + k] += columnAdjustment;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return columnWidths;
  }

  List<double> _computeActualColumnWidths(LinearConstraints widthConstraints) {
    assert(widthConstraints != null);
    assert(widthConstraints.isNormalized);
    final List<double> columnWidths = List<double>.filled(columns.length, 0);
    final List<bool> defaultWidthColumns = List<bool>.filled(columns.length, false);

    // First, we allocate the widths of non-relative columns. We store the
    // widths of relative columns as negative values for later processing
    double totalRelativeWeight = 0;
    double reservedWidth = math.max(columns.length - 1, 0) * horizontalSpacing;
    for (int j = 0; j < columns.length; j++) {
      final TablePaneColumnWidth columnWidthSpec = columns[j].width;
      double columnWidth = columnWidthSpec.width;

      if (columnWidthSpec.isRelative) {
        columnWidths[j] = -columnWidth;
        totalRelativeWeight += columnWidth;
      } else {
        if (columnWidth < 0) {
          // Default width column; we must calculate the width
          defaultWidthColumns[j] = true;
          switch (horizontalSize) {
            case MainAxisSize.min:
              columnWidth = computeMinIntrinsicColumnWidth(j);
              break;
            case MainAxisSize.max:
              columnWidth = computeMaxIntrinsicColumnWidth(j);
              break;
          }
        }
        columnWidths[j] = columnWidth;
        reservedWidth += columnWidth;
      }
    }

    // Next, we we account for default-width columns containing spanning
    // cells, which have been ignored thus far. We ensure that the sum of
    // the widths of the spanned cells is enough to satisfy the preferred
    // width of the spanning content.
    for (int i = 0; i < rows.length; i++) {
      final RenderTableRow row = rows[i];
      for (int j = 0, n = row.length; j < n && j < columns.length; j++) {
        final RenderBox child = row[j];
        assert(child != null);
        row.setupParentData(child);
        final TableCellParentData childParentData = child.parentData as TableCellParentData;
        final int columnSpan = childParentData.columnSpan;

        if (columnSpan > 1) {
          // We might need to adjust column widths to accommodate this spanning
          // cell. First, we find out if any of the spanned cells are default
          // width and how much space we've allocated thus far for those cells.
          bool didSpanRelativeColumns = false;
          int spannedDefaultWidthCellCount = 0;
          double spannedWidth = 0;

          for (int k = 0; k < columnSpan && j + k < columns.length; k++) {
            if (columnWidths[j + k] < 0) {
              // See comment below about relative-width columns.
              didSpanRelativeColumns = true;
              break;
            }

            if (defaultWidthColumns[j + k]) {
              spannedDefaultWidthCellCount++;
            }

            spannedWidth += columnWidths[j + k];
          }

          // If we span any relative-width columns, we assume that we'll achieve
          // the desired spanning width when we divvy up the remaining space, so
          // there's no need to make an adjustment here. This assumption is safe
          // because our preferred width policy is to *either* divide the
          // adjustment among the relative-width columns *or* among the
          // default-width columns if we don't span any relative-width columns
          if (!didSpanRelativeColumns && spannedDefaultWidthCellCount > 0) {
            double childIntrinsicWidth;
            switch (horizontalSize) {
              case MainAxisSize.min:
                childIntrinsicWidth = child.getMinIntrinsicWidth(double.infinity);
                break;
              case MainAxisSize.max:
                childIntrinsicWidth = child.getMaxIntrinsicWidth(double.infinity);
                break;
            }

            if (childIntrinsicWidth > spannedWidth) {
              // The child's intrinsic width is larger than the width we've
              // allocated thus far, so an adjustment is necessary.
              final double adjustment = childIntrinsicWidth - spannedWidth;

              // Distribute adjustment evenly among the default-width columns.
              for (int k = 0; k < columnSpan && j + k < columns.length; k++) {
                if (defaultWidthColumns[j + k]) {
                  final double columnAdjustment = adjustment / spannedDefaultWidthCellCount;
                  columnWidths[j + k] += columnAdjustment;
                  reservedWidth += columnAdjustment;
                }
              }
            }
          }
        }
      }
    }

    // Finally, we allocate the widths of the relative columns by divvying up
    // the remaining width
    final double width = widthConstraints.constrainMainAxisSize(horizontalSize);
    final double remainingWidth = math.max(width - reservedWidth, 0);
    if (totalRelativeWeight > 0) {
      assert(() {
        if (remainingWidth.isInfinite) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('RenderTablePane was given infinite width constraints with '
                'relative-width columns'),
            ErrorDescription(
                'Relative-width TablePaneColumn instances will fill the remaining width when a '
                'TablePane is laid out. If there is infinite width remaining, they have no '
                'way of knowing what width to be.'),
            ErrorSpacer(),
            DiagnosticsProperty<Object>(
              'The $runtimeType that contained a default-width column was created by',
              debugCreator,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ]);
        }
        return true;
      }());
      for (int j = 0; j < columns.length; j++) {
        if (columnWidths[j] < 0) {
          if (remainingWidth > 0) {
            final double relativeWeight = -columnWidths[j];
            final double weightPercentage = relativeWeight / totalRelativeWeight;
            columnWidths[j] = remainingWidth * weightPercentage;
          } else {
            columnWidths[j] = 0;
          }
        }
      }
    }

    assert(() {
      if (columnWidths.any((double value) => value.isNegative)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('RenderTablePane computed a negative-width column.'),
          ErrorDescription('This indicates a bug in RenderTablePane.'),
          ErrorSpacer(),
          DiagnosticsProperty<List<double>>('The computed column widths were', columnWidths),
          ErrorSpacer(),
          DiagnosticsProperty<Object>(
              'The RenderTablePane in question was created by', debugCreator,
              style: DiagnosticsTreeStyle.errorProperty),
        ]);
      }
      return true;
    }());

    return columnWidths;
  }

  double _computeHeight(List<double> rowHeights) {
    return rowHeights.fold<double>(0, _sum) + math.max(rows.length - 1, 0) * verticalSpacing;
  }

  double _computeIntrinsicHeight(double width, _IntrinsicComputer computeIntrinsicCellHeight) {
    return _computeHeight(_computeIntrinsicRowHeights(width, computeIntrinsicCellHeight));
  }

  double _computeWidth(List<double> columnWidths) {
    return columnWidths.fold<double>(0, _sum) + math.max(columns.length - 1, 0) * horizontalSpacing;
  }

  double _computeIntrinsicWidth(double height, _IntrinsicComputer computeIntrinsicCellWidth) {
    return _computeWidth(_computeIntrinsicColumnWidths(height, computeIntrinsicCellWidth));
  }

  @protected
  List<RenderTableRow> get rows => children.cast<RenderTableRow>();

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableRowParentData) {
      child.parentData = TableRowParentData();
    }
  }

  @protected
  double computeMinIntrinsicRowHeight(int rowIndex, List<double> columnWidths) {
    return _computeIntrinsicRowHeight(rowIndex, columnWidths, (RenderBox child, double width) {
      return child.getMinIntrinsicHeight(width);
    });
  }

  @protected
  double computeMaxIntrinsicRowHeight(int rowIndex, List<double> columnWidths) {
    return _computeIntrinsicRowHeight(rowIndex, columnWidths, (RenderBox child, double width) {
      return child.getMaxIntrinsicHeight(width);
    });
  }

  @protected
  double computeMinIntrinsicColumnWidth(int columnIndex) {
    return _computeIntrinsicColumnWidth(columnIndex, (RenderBox child, double height) {
      return child.getMinIntrinsicWidth(height);
    });
  }

  @protected
  double computeMaxIntrinsicColumnWidth(int columnIndex) {
    return _computeIntrinsicColumnWidth(columnIndex, (RenderBox child, double height) {
      return child.getMaxIntrinsicWidth(height);
    });
  }

  @override
  @protected
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width, (RenderBox child, double width) {
      return child.getMinIntrinsicHeight(width);
    });
  }

  @override
  @protected
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width, (RenderBox child, double width) {
      return child.getMaxIntrinsicHeight(width);
    });
  }

  @override
  @protected
  double computeMinIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(height, (RenderBox child, double height) {
      return child.getMinIntrinsicWidth(height);
    });
  }

  @override
  @protected
  double computeMaxIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(height, (RenderBox child, double height) {
      return child.getMaxIntrinsicWidth(height);
    });
  }

  @override
  @protected
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  @protected
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  bool _needsMetrics = true;
  TablePaneMetrics _metrics;

  @protected
  TablePaneMetrics get metrics => _metrics;

  @protected
  void markNeedsMetrics() {
    _needsMetrics = true;
    markNeedsLayout();
  }

  @protected
  void calculateMetricsIfNecessary() {
    assert(debugDoingThisLayout);
    if (_needsMetrics || _metrics.constraints != constraints) {
      _metrics = TablePaneMetrics(this);
      _needsMetrics = false;
    }
  }

  @override
  void performLayout() {
    calculateMetricsIfNecessary();
    size = constraints.constrainDimensions(
      _computeWidth(metrics.columnWidths),
      _computeHeight(metrics.rowHeights),
    );

    assert(() {
      if (rows.isNotEmpty) {
        final int cellsPerRow = rows.first.children.length;
        if (rows.any((RenderTableRow row) => row.children.length != cellsPerRow)) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('RenderTablePane contains irregular row lengths.'),
            ErrorDescription('Every TableRow in a TablePane must have the same number of '
                'children, so that every table cell is filled. Otherwise, the table will '
                'contain holes.'),
            ErrorSpacer(),
            DiagnosticsProperty<Object>(
                'The RenderTablePane in question was created by', debugCreator,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        if (cellsPerRow != columns.length) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('RenderTablePane cells do not match columns.'),
            ErrorDescription('The number of children inside every TableRow must match the '
                'number of columns specified for the TablePane.'),
            ErrorSpacer(),
            IntProperty('The number of cells in each row was', cellsPerRow,
                style: DiagnosticsTreeStyle.errorProperty),
            IntProperty('The number of columns was', columns.length,
                style: DiagnosticsTreeStyle.errorProperty),
            ErrorSpacer(),
            DiagnosticsProperty<Object>(
                'The RenderTablePane in question was created by', debugCreator,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
      }
      return true;
    }());

    double childY = 0;
    for (int i = 0; i < rows.length; i++) {
      final RenderTableRow row = rows[i];

      final List<BoxConstraints> cellConstraints = <BoxConstraints>[];
      final List<Offset> cellPositions = <Offset>[];
      double childX = 0;
      double expandedRowHeight = 0;
      for (int j = 0; j < row.length && j < columns.length; j++) {
        final RenderBox child = row[j];
        assert(child != null);

        if (child is RenderEmptyTableCell) {
          cellConstraints.add(BoxConstraints.tight(Size.zero));
          cellPositions.add(Offset(childX, 0));
        } else {
          final TableCellParentData childParentData = child.parentData as TableCellParentData;

          final int columnSpan = math.min(childParentData.columnSpan, columns.length - j);
          double childWidth = metrics.columnWidths.skip(j).take(columnSpan).fold<double>(0, _sum);
          childWidth += (columnSpan - 1) * horizontalSpacing;

          final int rowSpan = math.min(childParentData.rowSpan, rows.length - i);
          double childHeight = metrics.rowHeights.skip(i).take(rowSpan).fold<double>(0, _sum);
          childHeight += (rowSpan - 1) * verticalSpacing;

          // Set the child's size
          childWidth = math.max(childWidth, 0);
          childHeight = math.max(childHeight, 0);
          cellConstraints.add(BoxConstraints.tightFor(width: childWidth, height: childHeight));
          cellPositions.add(Offset(childX, 0));

          expandedRowHeight = math.max(expandedRowHeight, childHeight);
        }

        childX += (metrics.columnWidths[j] + horizontalSpacing);
      }

      final double rowWidth = childX - horizontalSpacing;
      row.layout(TableRowConstraints.tightFor(
        width: rowWidth,
        height: expandedRowHeight,
        cellConstraints: cellConstraints,
        cellPositions: cellPositions,
      ));

      final TableRowParentData rowParentData = row.parentData as TableRowParentData;
      rowParentData.offset = Offset(0, childY);
      childY += (metrics.rowHeights[i] + verticalSpacing);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('horizontalSpacing', horizontalSpacing));
    properties.add(DoubleProperty('verticalSpacing', verticalSpacing));
    properties.add(EnumProperty<MainAxisSize>('horizontalSize', horizontalSize));
    properties.add(EnumProperty<MainAxisSize>('verticalSize', verticalSize));
    properties.add(DiagnosticsProperty<TablePaneMetrics>('metrics', metrics));
  }
}

@visibleForTesting
class TablePaneMetrics with Diagnosticable {
  const TablePaneMetrics._(this.constraints, this.columnWidths, this.rowHeights);

  factory TablePaneMetrics(RenderTablePane tablePane) {
    final BoxConstraints constraints = tablePane.constraints;
    final LinearConstraints widthConstraints = LinearConstraints.width(constraints);
    final LinearConstraints heightConstraints = LinearConstraints.height(constraints);
    List<double> columnWidths = tablePane._computeActualColumnWidths(widthConstraints);
    List<double> rowHeights = tablePane._computeActualRowHeights(heightConstraints, columnWidths);
    return TablePaneMetrics._(constraints, columnWidths, rowHeights);
  }

  final BoxConstraints constraints;
  final List<double> columnWidths;
  final List<double> rowHeights;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('constraints', constraints));
    properties.add(DiagnosticsProperty<List<double>>('columnWidths', columnWidths));
    properties.add(DiagnosticsProperty<List<double>>('rowHeights', rowHeights));
  }
}
