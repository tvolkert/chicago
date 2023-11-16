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
import 'indexed_offset.dart';

void main() {
  runApp(
    ColoredBox(
      color: const Color(0xffffffff),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style:
              TextStyle(fontFamily: 'Verdana', color: const Color(0xff000000)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicWidth(
                child: IntrinsicHeight(
                  child: TablePane(
                    verticalIntrinsicSize: MainAxisSize.min,
                    horizontalSpacing: 5,
                    verticalSpacing: 20,
                    columns: <TablePaneColumn>[
                      TablePaneColumn(
                          width: RelativeTablePaneColumnWidth(weight: 2)),
                      TablePaneColumn(
                          width: RelativeTablePaneColumnWidth(weight: 20)),
                      TablePaneColumn(
                          width: RelativeTablePaneColumnWidth(weight: 1)),
                      TablePaneColumn(
                          width: RelativeTablePaneColumnWidth(weight: 3)),
                      TablePaneColumn(
                          width: RelativeTablePaneColumnWidth(weight: 1)),
                      TablePaneColumn(
                          width: RelativeTablePaneColumnWidth(weight: 1)),
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
      color: Color(0xff000000 | random.nextInt(math.pow(256, 3) as int)),
      child: Align(child: Text(text)),
    );
  }
}

typedef _IntrinsicComputer = double Function(
    RenderBox child, double crossAxisConstraint);

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
  const IntrinsicTablePaneColumnWidth([this.mainAxisSize = MainAxisSize.max])
      : super._();

  final MainAxisSize mainAxisSize;

  @override
  @protected
  double get width => -1;

  @override
  @protected
  bool get isRelative => false;
}

class FixedTablePaneColumnWidth extends TablePaneColumnWidth {
  const FixedTablePaneColumnWidth(this.width)
      : assert(width >= 0),
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
  const IntrinsicTablePaneRowHeight([this.mainAxisSize = MainAxisSize.max])
      : super._();

  final MainAxisSize mainAxisSize;

  @override
  @protected
  double get height => -1;

  @override
  @protected
  bool get isRelative => false;
}

class FixedTablePaneRowHeight extends TablePaneRowHeight {
  const FixedTablePaneRowHeight(this.height)
      : assert(height >= 0),
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
    Key? key,
    this.rowSpan = 1,
    this.columnSpan = 1,
    required Widget child,
  })  : assert(rowSpan > 0),
        assert(columnSpan > 0),
        super(key: key, child: child);

  /// The number of rows this cell occupies.
  final int rowSpan;

  /// The number of columns this cell occupies.
  final int columnSpan;

  @override
  void applyParentData(RenderObject renderObject) {
    final TableCellParentData parentData =
        renderObject.parentData as TableCellParentData;
    if (parentData.rowSpan != rowSpan || parentData.columnSpan != columnSpan) {
      parentData.rowSpan = rowSpan;
      parentData.columnSpan = columnSpan;
      RenderObject? targetParent = renderObject.parent;
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
  const EmptyTableCell({Key? key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderEmptyTableCell();
}

/// TablePane's layout is "width in, height out", meaning it will compute its
/// column widths first with unconstrained height, then compute the row heights
/// using those column widths as the width constraints.
class TablePane extends MultiChildRenderObjectWidget {
  TablePane({
    Key? key,
    required this.columns,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 0,
    this.horizontalIntrinsicSize = MainAxisSize.max,
    this.horizontalRelativeSize = MainAxisSize.max,
    this.verticalIntrinsicSize = MainAxisSize.max,
    this.verticalRelativeSize = MainAxisSize.max,
    this.metricsController,
    required List<Widget> children,
  }) : super(key: key, children: children);

  final List<TablePaneColumn> columns;
  final double horizontalSpacing;
  final double verticalSpacing;
  final MainAxisSize horizontalIntrinsicSize;
  final MainAxisSize horizontalRelativeSize;
  final MainAxisSize verticalIntrinsicSize;
  final MainAxisSize verticalRelativeSize;
  final TablePaneMetricsController? metricsController;

  @override
  List<Widget> get children => super.children;

  @override
  TablePaneElement createElement() => TablePaneElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTablePane(
      columns: columns,
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      horizontalIntrinsicSize: horizontalIntrinsicSize,
      horizontalRelativeSize: horizontalRelativeSize,
      verticalIntrinsicSize: verticalIntrinsicSize,
      verticalRelativeSize: verticalRelativeSize,
      metricsController: metricsController,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTablePane renderObject) {
    renderObject
      ..columns = columns
      ..horizontalSpacing = horizontalSpacing
      ..verticalSpacing = verticalSpacing
      ..horizontalIntrinsicSize = horizontalIntrinsicSize
      ..horizontalRelativeSize = horizontalRelativeSize
      ..verticalIntrinsicSize = verticalIntrinsicSize
      ..verticalRelativeSize = verticalRelativeSize
      ..metricsController = metricsController;
  }

  static int _indexOf(Element child, Element parent) {
    int i = -1, result = -1;
    parent.visitChildren((Element element) {
      i++;
      if (element == child) {
        assert(result == -1);
        result = i;
      }
    });
    return result;
  }

  static IndexedOffset? offsetOf(BuildContext context) {
    TableRowElement? row;
    Element? rawCell;
    context.visitAncestorElements((Element element) {
      if (element is TableRowElement) {
        row = element;
        rawCell ??= context as Element;
        return false;
      }
      rawCell = element;
      return true;
    });
    if (row != null) {
      assert(rawCell != null);
      final int columnIndex = _indexOf(rawCell!, row!);
      assert(columnIndex >= 0);
      TablePaneElement? tablePane;
      Element? rawRow;
      row!.visitAncestorElements((Element element) {
        if (element is TablePaneElement) {
          tablePane = element;
          rawRow ??= row;
          return false;
        }
        rawRow = element;
        return true;
      });
      assert(tablePane != null);
      assert(rawRow != null);
      final int rowIndex = _indexOf(rawRow!, tablePane!);
      assert(rowIndex >= 0);
      return IndexedOffset(rowIndex, columnIndex);
    }
    return null;
  }

  static TablePaneElement? of(BuildContext context) {
    if (context is TablePaneElement) {
      return context;
    }
    TablePaneElement? tablePane;
    context.visitAncestorElements((Element element) {
      if (element is TablePaneElement) {
        tablePane = element;
        return false;
      }
      return true;
    });
    return tablePane;
  }
}

class TablePaneElement extends MultiChildRenderObjectElement {
  TablePaneElement(TablePane widget) : super(widget);
}

class TableRow extends MultiChildRenderObjectWidget {
  TableRow({
    Key? key,
    this.height = const IntrinsicTablePaneRowHeight(),
    this.backgroundColor,
    required List<Widget> children,
  }) : super(key: key, children: children);

  final TablePaneRowHeight height;
  final Color? backgroundColor;

  @override
  List<Widget> get children => super.children;

  @override
  TableRowElement createElement() => TableRowElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTableRow(
      height: height,
      backgroundColor: backgroundColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTableRow renderObject) {
    renderObject
      ..height = height
      ..backgroundColor = backgroundColor;
  }
}

class TableRowElement extends MultiChildRenderObjectElement {
  TableRowElement(TableRow widget) : super(widget);
}

/// [ParentData] used by [RenderTablePane].
class TableRowParentData extends ContainerBoxParentData<RenderTableRow> {}

/// [ParentData] used by [RenderTableRow].
class TableCellParentData extends ContainerBoxParentData<RenderBox> {
  /// The column that the child was in the last time it was laid out.
  int? x;

  int _rowSpan = 1;
  int get rowSpan => _rowSpan;
  set rowSpan(int value) {
    assert(value > 0);
    _rowSpan = value;
  }

  int _columnSpan = 1;
  int get columnSpan => _columnSpan;
  set columnSpan(int value) {
    assert(value > 0);
    _columnSpan = value;
  }

  @override
  String toString() =>
      '${super.toString()}; $rowSpan rows x $columnSpan columns';
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
    double? width,
    double? height,
    required this.cellConstraints,
    required this.cellPositions,
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
    return Object.hash(super.hashCode, Object.hashAll(cellConstraints),
        Object.hashAll(cellPositions));
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

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }
}

mixin ChildListRenderObjectMixin<ChildType extends RenderBox,
        ParentDataType extends ContainerBoxParentData<ChildType>>
    on RenderBoxContainerDefaultsMixin<ChildType, ParentDataType> {
  List<RenderBox>? _children;

  @protected
  List<RenderBox> get children {
    return _children ??= getChildrenAsList();
  }

  @protected
  @mustCallSuper
  void markNeedsChildren() {
    _children = null;
  }

  /// The number of children belonging to this render object.
  int get length => childCount;

  /// Gets the child at the specified index.
  RenderBox operator [](int index) => children[index];

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child as ChildType, after: after as ChildType?);
    markNeedsChildren();
  }

  @override
  void remove(RenderBox child) {
    super.remove(child as ChildType);
    markNeedsChildren();
  }

  @override
  void removeAll() {
    super.removeAll();
    markNeedsChildren();
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    super.move(child as ChildType, after: after as ChildType?);
    markNeedsChildren();
  }
}

class RenderTableRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableCellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableCellParentData>,
        ChildListRenderObjectMixin<RenderBox, TableCellParentData> {
  RenderTableRow({
    required TablePaneRowHeight height,
    Color? backgroundColor,
  }) {
    this.height = height;
    this.backgroundColor = backgroundColor;
  }

  TablePaneRowHeight _height = const IntrinsicTablePaneRowHeight();
  TablePaneRowHeight get height => _height;
  set height(TablePaneRowHeight value) {
    if (value != _height) {
      _height = value;
      markNeedsLayout();
      if (parent != null) {
        parent!.markNeedsMetrics();
      }
    }
  }

  Color? _backgroundColor;
  Color? get backgroundColor => _backgroundColor;
  set backgroundColor(Color? value) {
    if (value != _backgroundColor) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  @override
  TableRowConstraints get constraints =>
      super.constraints as TableRowConstraints;

  @override
  RenderTablePane? get parent => super.parent as RenderTablePane?;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableCellParentData) {
      child.parentData = TableCellParentData();
    }
  }

  @override
  @protected
  void markNeedsChildren() {
    super.markNeedsChildren();
    parent!.markNeedsMetrics();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void markNeedsLayout() {
    RenderTablePane? parent = this.parent;
    if (parent != null) {
      parent.markNeedsMetrics();
      markParentNeedsLayout();
      return;
    }
    super.markNeedsLayout();
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
    if (backgroundColor != null) {
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor!;
      context.canvas.drawRect(offset & size, paint);
    }
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
    required List<TablePaneColumn> columns,
    double horizontalSpacing = 0,
    double verticalSpacing = 0,
    MainAxisSize horizontalIntrinsicSize = MainAxisSize.max,
    MainAxisSize horizontalRelativeSize = MainAxisSize.max,
    MainAxisSize verticalIntrinsicSize = MainAxisSize.max,
    MainAxisSize verticalRelativeSize = MainAxisSize.max,
    TablePaneMetricsController? metricsController,
  }) {
    this.columns = columns;
    this.horizontalSpacing = horizontalSpacing;
    this.verticalSpacing = verticalSpacing;
    this.horizontalIntrinsicSize = horizontalIntrinsicSize;
    this.horizontalRelativeSize = horizontalRelativeSize;
    this.verticalIntrinsicSize = verticalIntrinsicSize;
    this.verticalRelativeSize = verticalRelativeSize;
    this.metricsController = metricsController;
  }

  List<TablePaneColumn> _columns = const <TablePaneColumn>[];
  List<TablePaneColumn> get columns => _columns;
  set columns(List<TablePaneColumn> value) {
    if (!const ListEquality().equals(value, _columns)) {
      _columns = value;
      markNeedsMetrics();
    }
  }

  double _horizontalSpacing = 0;
  double get horizontalSpacing => _horizontalSpacing;
  set horizontalSpacing(double value) {
    if (value != _horizontalSpacing) {
      _horizontalSpacing = value;
      markNeedsMetrics();
    }
  }

  double _verticalSpacing = 0;
  double get verticalSpacing => _verticalSpacing;
  set verticalSpacing(double value) {
    if (value != _verticalSpacing) {
      _verticalSpacing = value;
      markNeedsMetrics();
    }
  }

  MainAxisSize _horizontalIntrinsicSize = MainAxisSize.max;
  MainAxisSize get horizontalIntrinsicSize => _horizontalIntrinsicSize;
  set horizontalIntrinsicSize(MainAxisSize value) {
    if (value != _horizontalIntrinsicSize) {
      _horizontalIntrinsicSize = value;
      markNeedsMetrics();
    }
  }

  MainAxisSize _horizontalRelativeSize = MainAxisSize.max;
  MainAxisSize get horizontalRelativeSize => _horizontalRelativeSize;
  set horizontalRelativeSize(MainAxisSize value) {
    if (value != _horizontalRelativeSize) {
      _horizontalRelativeSize = value;
      markNeedsMetrics();
    }
  }

  MainAxisSize _verticalIntrinsicSize = MainAxisSize.max;
  MainAxisSize get verticalIntrinsicSize => _verticalIntrinsicSize;
  set verticalIntrinsicSize(MainAxisSize value) {
    if (value != _verticalIntrinsicSize) {
      _verticalIntrinsicSize = value;
      markNeedsMetrics();
    }
  }

  MainAxisSize _verticalRelativeSize = MainAxisSize.max;
  MainAxisSize get verticalRelativeSize => _verticalRelativeSize;
  set verticalRelativeSize(MainAxisSize value) {
    if (value != _verticalRelativeSize) {
      _verticalRelativeSize = value;
      markNeedsMetrics();
    }
  }

  TablePaneMetricsController? _metricsController;
  TablePaneMetricsController? get metricsController => _metricsController;
  set metricsController(TablePaneMetricsController? value) {
    if (value != _metricsController) {
      if (_metricsController != null && attached) {
        _metricsController!._detach();
      }
      _metricsController = value;
      if (value != null && attached) {
        value._attach(this);
      }
    }
  }

  /// Computes the intrinsic height of a table pane row, which is defined as
  /// the maximum intrinsic height of the row's cells.
  ///
  /// Because their intrinsic height relates to the intrinsic heights of other
  /// rows, cells that span multiple rows will not be considered in this
  /// calculation (even if they live in the row directly). It is up to the
  /// caller to factor such cells into the row heights calculation.
  double _computeIntrinsicRowHeight(
    int rowIndex,
    List<double> columnWidths,
    _IntrinsicComputer computeIntrinsicCellHeight,
  ) {
    assert(rowIndex >= 0 && rowIndex < rows.length);
    final RenderTableRow row = rows[rowIndex];
    double result = 0;
    for (int j = 0, n = row.length, m = columns.length; j < n && j < m; j++) {
      final RenderBox child = row[j];
      final TableCellParentData childParentData =
          child.parentData as TableCellParentData;
      if (childParentData.rowSpan == 1) {
        result = math.max(
            result, computeIntrinsicCellHeight(child, columnWidths[j]));
      }
    }
    return result;
  }

  /// Gets the intrinsic width of a table pane column, which is defined as the
  /// maximum intrinsic width of the column's cells.
  ///
  /// Because their intrinsic width relates to the intrinsic widths of other
  /// columns, cells that span multiple columns will not be considered in
  /// this calculation (even if they live in the column directly). It is up to
  /// the caller to factor such cells into the column widths calculation.
  double _computeIntrinsicColumnWidth(
    int columnIndex,
    _IntrinsicComputer computeIntrinsicCellWidth,
  ) {
    double result = 0;
    for (int i = 0, n = rows.length; i < n; i++) {
      final RenderTableRow row = rows[i];
      if (columnIndex < row.length) {
        final RenderBox child = row[columnIndex];
        final TableCellParentData childParentData =
            child.parentData as TableCellParentData;
        if (childParentData.columnSpan == 1) {
          result = math.max(
              result, computeIntrinsicCellWidth(child, double.infinity));
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
    final List<bool> intrinsicHeightRows =
        List<bool>.filled(rows.length, false);
    final List<double> columnWidths = width.isFinite
        ? _computeActualColumnWidths(LinearConstraints.tight(width))
        : _computeIntrinsicColumnWidths(_computeIntrinsicChildWidth);

    // First, we calculate the base heights of the rows, giving relative
    // rows their intrinsic height. Spanning cells will be ignored in this
    // pass.
    double totalRelativeWeight = 0;
    for (int i = 0; i < rows.length; i++) {
      final TablePaneRowHeight heightSpec = rows[i].height;
      final double rowHeight = heightSpec.height;
      final bool isRelative = heightSpec.isRelative;
      final bool isIntrinsic = intrinsicHeightRows[i] = rowHeight < 0;

      if (isRelative) {
        relativeWeights[i] = rowHeight;
        totalRelativeWeight += rowHeight;
      }

      if (isIntrinsic || isRelative) {
        rowHeights[i] = _computeIntrinsicRowHeight(
            i, columnWidths, computeIntrinsicCellHeight);
      } else {
        rowHeights[i] = rowHeight;
      }
    }

    // Next, we account for spanning cells, which have been ignored thus
    // far. If any spanned cell is intrinsic-height (including relative height
    // rows), then we ensure that the sum of the heights of the spanned cells
    // is enough to satisfy the intrinsic height of the spanning content.
    for (int i = 0; i < rows.length; i++) {
      final RenderTableRow row = rows[i];
      for (int j = 0, n = row.length, m = columns.length; j < n && j < m; j++) {
        final RenderBox child = row[j];

        if (child is! RenderEmptyTableCell) {
          final TableCellParentData childParentData =
              child.parentData as TableCellParentData;
          final int rowSpan = childParentData.rowSpan;

          if (rowSpan > 1) {
            // We might need to adjust row heights to accommodate this spanning
            // cell. First, we find out if any of the spanned cells are
            // intrinsic height or relative height and how much space we've
            // allocated thus far for those cells.
            int spannedIntrinsicHeightCellCount = 0;
            double spannedRelativeWeight = 0;
            double spannedHeight = 0;
            for (int k = 0; k < rowSpan && i + k < rows.length; k++) {
              spannedRelativeWeight += relativeWeights[i + k];
              spannedHeight += rowHeights[i + k];
              if (intrinsicHeightRows[i + k]) {
                spannedIntrinsicHeightCellCount++;
              }
            }

            if (spannedRelativeWeight > 0 ||
                spannedIntrinsicHeightCellCount > 0) {
              final int columnSpan = childParentData.columnSpan;
              double childWidth =
                  columnWidths.skip(j).take(columnSpan).fold<double>(0, _sum);
              childWidth += math.max(columnSpan - 1, 0) * horizontalSpacing;
              final double childIntrinsicHeight =
                  computeIntrinsicCellHeight(child, childWidth);

              if (childIntrinsicHeight > spannedHeight) {
                // The child's intrinsic height is larger than the height we've
                // allocated thus far, so an adjustment is necessary.
                final double adjustment = childIntrinsicHeight - spannedHeight;

                if (spannedRelativeWeight > 0) {
                  // We'll distribute the adjustment across the spanned
                  // relative rows and adjust other relative row heights to
                  // keep all relative row heights reconciled.
                  final double unitAdjustment =
                      adjustment / spannedRelativeWeight;
                  for (int k = 0; k < rowSpan && i + k < rows.length; k++) {
                    final double relativeWeight = relativeWeights[i + k];
                    if (relativeWeight > 0) {
                      final double rowAdjustment =
                          unitAdjustment * relativeWeight;
                      rowHeights[i + k] += rowAdjustment;
                    }
                  }
                } else {
                  // We'll distribute the adjustment evenly among the
                  // intrinsic-height rows.
                  for (int k = 0; k < rowSpan && i + k < rows.length; k++) {
                    if (intrinsicHeightRows[i + k]) {
                      final double rowAdjustment =
                          adjustment / spannedIntrinsicHeightCellCount;
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

    // Finally, we adjust the heights of the relative rows upwards where
    // necessary to reconcile their heights relative to one another while
    // ensuring that they still get at least their intrinsic height.
    if (totalRelativeWeight > 0) {
      // Calculate total relative height after the required upward adjustments
      double totalRelativeHeight = 0;
      for (int i = 0; i < rows.length; i++) {
        final double relativeWeight = relativeWeights[i];
        if (relativeWeight > 0) {
          final double rowHeight = rowHeights[i];
          final double weightPercentage = relativeWeight / totalRelativeWeight;
          totalRelativeHeight =
              math.max(totalRelativeHeight, rowHeight / weightPercentage);
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

    return rowHeights;
  }

  List<double> _computeActualRowHeights(
    LinearConstraints heightConstraints,
    List<double> columnWidths,
  ) {
    final double totalRelativeWeight = rows
        .map<TablePaneRowHeight>((RenderTableRow row) => row.height)
        .whereType<RelativeTablePaneRowHeight>()
        .map<double>(
            (RelativeTablePaneRowHeight heightSpec) => heightSpec.height)
        .fold<double>(0, _sum);

    final double totalWidth = _computeWidth(columnWidths);
    final List<double> rowHeights =
        _computeIntrinsicRowHeights(totalWidth, _computeIntrinsicChildHeight);
    double totalHeight = _computeHeight(rowHeights);

    void growRelativeRowsToMeetMinimumTotalHeight(double minimumHeight) {
      final double remainingHeight = minimumHeight - totalHeight;
      assert(remainingHeight >= 0);
      for (int i = 0; i < rows.length; i++) {
        final TablePaneRowHeight rowHeightSpec = rows[i].height;
        if (rowHeightSpec.isRelative) {
          final double relativeWeight = rowHeightSpec.height;
          final double weightPercentage = relativeWeight / totalRelativeWeight;
          assert(weightPercentage > 0 && weightPercentage <= 1);
          final double addHeight = remainingHeight * weightPercentage;
          rowHeights[i] += addHeight;
          totalHeight += addHeight;
        }
      }
    }

    if (heightConstraints.isSatisfiedBy(totalHeight)) {
      if (verticalRelativeSize == MainAxisSize.max &&
          heightConstraints.isBounded &&
          totalRelativeWeight > 0) {
        // Grow the relative-height rows to fill the max height constraint.
        growRelativeRowsToMeetMinimumTotalHeight(heightConstraints.max);
      }
    } else if (heightConstraints < totalHeight) {
      if (totalRelativeWeight > 0) {
        // Shrink the relative-height rows to meet the max height constraints.
        final double overflowHeight = totalHeight - heightConstraints.max;
        assert(overflowHeight >= 0);
        bool? excessiveOverflow;
        for (int i = 0; i < rows.length; i++) {
          final TablePaneRowHeight rowHeightSpec = rows[i].height;
          if (rowHeightSpec.isRelative) {
            final double relativeWeight = rowHeightSpec.height;
            final double weightPercentage =
                relativeWeight / totalRelativeWeight;
            assert(weightPercentage > 0 && weightPercentage <= 1);
            double subtractHeight = overflowHeight * weightPercentage;
            final bool localOverflow = subtractHeight > rowHeights[i];
            assert(excessiveOverflow == null ||
                excessiveOverflow == localOverflow);
            excessiveOverflow = (excessiveOverflow ?? false) || localOverflow;
            if (excessiveOverflow) {
              subtractHeight = rowHeights[i];
            }
            rowHeights[i] -= subtractHeight;
            totalHeight -= subtractHeight;
          }
        }
        assert(excessiveOverflow == (heightConstraints < totalHeight));
        if (excessiveOverflow!) {
          // TODO: handle overflow
        }
      } else {
        // TODO: handle overflow
      }
    } else if (heightConstraints > totalHeight) {
      if (totalRelativeWeight > 0) {
        // Grow the relative-height rows to meet the min height constraints.
        growRelativeRowsToMeetMinimumTotalHeight(heightConstraints.min);
      }
    }

    assert(() {
      if (rowHeights.any((double value) => value.isNegative)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('RenderTablePane computed a negative-height row.'),
          ErrorDescription('This indicates a bug in RenderTablePane.'),
          ErrorSpacer(),
          DiagnosticsProperty<List<double>>(
              'The computed row heights were', rowHeights),
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
      _IntrinsicComputer computeIntrinsicCellWidth) {
    final List<double> columnWidths = List<double>.filled(columns.length, 0);
    final List<double> relativeWeights = List<double>.filled(columns.length, 0);
    final List<bool> intrinsicWidthColumns =
        List<bool>.filled(columns.length, false);

    // First, we calculate the base widths of the columns, giving relative
    // columns their intrinsic width. Spanning cells will be ignored in this
    // pass.
    double totalRelativeWeight = 0;
    for (int i = 0; i < columns.length; i++) {
      final TablePaneColumnWidth columnWidthSpec = columns[i].width;
      final double columnWidth = columnWidthSpec.width;
      final bool isRelative = columnWidthSpec.isRelative;
      final bool isIntrinsic = intrinsicWidthColumns[i] = columnWidth < 0;

      if (isRelative) {
        relativeWeights[i] = columnWidth;
        totalRelativeWeight += columnWidth;
      }

      if (isIntrinsic || isRelative) {
        columnWidths[i] =
            _computeIntrinsicColumnWidth(i, computeIntrinsicCellWidth);
      } else {
        columnWidths[i] = columnWidth;
      }
    }

    // Next, we account for spanning cells, which have been ignored thus
    // far. If any spanned cell is intrinsic-width (including relative width
    // columns), then we ensure that the sum of the widths of the spanned
    // cells is enough to satisfy the intrinsic width of the spanning content
    for (int i = 0; i < rows.length; i++) {
      final RenderTableRow row = rows[i];
      for (int j = 0, n = row.length; j < n && j < columns.length; j++) {
        final RenderBox child = row[j];

        if (child is! RenderEmptyTableCell) {
          final TableCellParentData childParentData =
              child.parentData as TableCellParentData;
          final int columnSpan = childParentData.columnSpan;

          if (columnSpan > 1) {
            // We might need to adjust column widths to accommodate this
            // spanning cell. First, we find out if any of the spanned cells
            // are intrinsic width or relative width and how much space we've
            // allocated thus far for those cells.
            int spannedIntrinsicWidthCellCount = 0;
            double spannedRelativeWeight = 0;
            double spannedWidth = 0;
            for (int k = 0; k < columnSpan && j + k < columns.length; k++) {
              spannedRelativeWeight += relativeWeights[j + k];
              spannedWidth += columnWidths[j + k];
              if (intrinsicWidthColumns[j + k]) {
                spannedIntrinsicWidthCellCount++;
              }
            }

            if (spannedRelativeWeight > 0 ||
                spannedIntrinsicWidthCellCount > 0) {
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
                  heightConstraint +=
                      math.max(spannedRowHeights.length - 1, 0) *
                          verticalSpacing;
                }
              }
              final double childIntrinsicWidth =
                  computeIntrinsicCellWidth(child, heightConstraint);

              if (childIntrinsicWidth > spannedWidth) {
                // The child's intrinsic width is larger than the width we've
                // allocated thus far, so an adjustment is necessary.
                final double adjustment = childIntrinsicWidth - spannedWidth;

                if (spannedRelativeWeight > 0) {
                  // We'll distribute the adjustment across the spanned
                  // relative columns and adjust other relative column widths
                  // to keep all relative column widths reconciled.
                  final double unitAdjustment =
                      adjustment / spannedRelativeWeight;
                  for (int k = 0;
                      k < columnSpan && j + k < columns.length;
                      k++) {
                    final double relativeWeight = relativeWeights[j + k];
                    if (relativeWeight > 0) {
                      final double columnAdjustment =
                          unitAdjustment * relativeWeight;
                      columnWidths[j + k] += columnAdjustment;
                    }
                  }
                } else {
                  // We'll distribute the adjustment evenly among the
                  // intrinsic-width columns.
                  for (int k = 0;
                      k < columnSpan && j + k < columns.length;
                      k++) {
                    if (intrinsicWidthColumns[j + k]) {
                      final double columnAdjustment =
                          adjustment / spannedIntrinsicWidthCellCount;
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

    // Finally, we adjust the widths of the relative columns upwards where
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
          totalRelativeWidth =
              math.max(totalRelativeWidth, columnWidth / weightPercentage);
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

    return columnWidths;
  }

  List<double> _computeActualColumnWidths(LinearConstraints widthConstraints) {
    final double totalRelativeWeight = columns
        .map<TablePaneColumnWidth>((TablePaneColumn column) => column.width)
        .whereType<RelativeTablePaneColumnWidth>()
        .map<double>(
            (RelativeTablePaneColumnWidth widthSpec) => widthSpec.width)
        .fold<double>(0, _sum);

    final List<double> columnWidths =
        _computeIntrinsicColumnWidths(_computeIntrinsicChildWidth);
    double totalWidth = _computeWidth(columnWidths);

    void growRelativeColumnsToMeetMinimumTotalWidth(double minimumWidth) {
      final double remainingWidth = minimumWidth - totalWidth;
      assert(remainingWidth >= 0);
      for (int j = 0; j < columns.length; j++) {
        final TablePaneColumnWidth columnWidthSpec = columns[j].width;
        if (columnWidthSpec.isRelative) {
          final double relativeWeight = columnWidthSpec.width;
          final double weightPercentage = relativeWeight / totalRelativeWeight;
          assert(weightPercentage > 0 && weightPercentage <= 1);
          final double addWidth = remainingWidth * weightPercentage;
          columnWidths[j] += addWidth;
          totalWidth += addWidth;
        }
      }
    }

    if (widthConstraints.isSatisfiedBy(totalWidth)) {
      if (horizontalRelativeSize == MainAxisSize.max &&
          widthConstraints.isBounded &&
          totalRelativeWeight > 0) {
        // Grow the relative-width columns to fill the max width constraint.
        growRelativeColumnsToMeetMinimumTotalWidth(widthConstraints.max);
      }
    } else if (widthConstraints < totalWidth) {
      if (totalRelativeWeight > 0) {
        // Shrink the relative-width columns to meet the max width constraints.
        final double overflowWidth = totalWidth - widthConstraints.max;
        assert(overflowWidth >= 0);
        bool? excessiveOverflow;
        for (int j = 0; j < columns.length; j++) {
          final TablePaneColumnWidth columnWidthSpec = columns[j].width;
          if (columnWidthSpec.isRelative) {
            final double relativeWeight = columnWidthSpec.width;
            final double weightPercentage =
                relativeWeight / totalRelativeWeight;
            assert(weightPercentage > 0 && weightPercentage <= 1);
            double subtractWidth = overflowWidth * weightPercentage;
            final bool localOverflow = subtractWidth > columnWidths[j];
            assert(excessiveOverflow == null ||
                excessiveOverflow == localOverflow);
            excessiveOverflow = (excessiveOverflow ?? false) || localOverflow;
            if (excessiveOverflow) {
              subtractWidth = columnWidths[j];
            }
            columnWidths[j] -= subtractWidth;
            totalWidth -= subtractWidth;
          }
        }
        assert(excessiveOverflow == (widthConstraints < totalWidth));
        if (excessiveOverflow!) {
          // TODO: handle overflow
        }
      } else {
        // TODO: handle overflow
      }
    } else if (widthConstraints > totalWidth) {
      if (totalRelativeWeight > 0) {
        // Grow the relative-width columns to meet the min width constraints.
        growRelativeColumnsToMeetMinimumTotalWidth(widthConstraints.min);
      }
    }

    assert(() {
      if (columnWidths.any((double value) => value.isNegative)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('RenderTablePane computed a negative-width column.'),
          ErrorDescription('This indicates a bug in RenderTablePane.'),
          ErrorSpacer(),
          DiagnosticsProperty<List<double>>(
              'The computed column widths were', columnWidths),
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
    return rowHeights.fold<double>(0, _sum) +
        math.max(rows.length - 1, 0) * verticalSpacing;
  }

  double _computeIntrinsicHeight(
      double width, _IntrinsicComputer computeIntrinsicCellHeight) {
    return _computeHeight(
        _computeIntrinsicRowHeights(width, computeIntrinsicCellHeight));
  }

  double _computeIntrinsicChildHeight(RenderBox child, double width) {
    switch (verticalIntrinsicSize) {
      case MainAxisSize.min:
        return child.getMinIntrinsicHeight(width);
      case MainAxisSize.max:
        return child.getMaxIntrinsicHeight(width);
    }
  }

  double _computeMinIntrinsicChildHeight(RenderBox child, double width) {
    return child.getMinIntrinsicHeight(width);
  }

  double _computeMaxIntrinsicChildHeight(RenderBox child, double width) {
    return child.getMaxIntrinsicHeight(width);
  }

  double _computeWidth(List<double> columnWidths) {
    return columnWidths.fold<double>(0, _sum) +
        math.max(columns.length - 1, 0) * horizontalSpacing;
  }

  double _computeIntrinsicWidth(
      double height, _IntrinsicComputer computeIntrinsicCellWidth) {
    return _computeWidth(
        _computeIntrinsicColumnWidths(computeIntrinsicCellWidth));
  }

  double _computeIntrinsicChildWidth(RenderBox child, double height) {
    switch (horizontalIntrinsicSize) {
      case MainAxisSize.min:
        return child.getMinIntrinsicWidth(height);
      case MainAxisSize.max:
        return child.getMaxIntrinsicWidth(height);
    }
  }

  double _computeMinIntrinsicChildWidth(RenderBox child, double height) {
    return child.getMinIntrinsicWidth(height);
  }

  double _computeMaxIntrinsicChildWidth(RenderBox child, double height) {
    return child.getMaxIntrinsicWidth(height);
  }

  @protected
  List<RenderTableRow> get rows => children.cast<RenderTableRow>();

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableRowParentData) {
      child.parentData = TableRowParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (metricsController != null) {
      metricsController!._attach(this);
    }
  }

  @override
  void detach() {
    super.detach();
    if (metricsController != null) {
      metricsController!._detach();
    }
  }

  @override
  @protected
  void markNeedsChildren() {
    super.markNeedsChildren();
    markNeedsMetrics();
  }

  @override
  @protected
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width, _computeMinIntrinsicChildHeight);
  }

  @override
  @protected
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width, _computeMaxIntrinsicChildHeight);
  }

  @override
  @protected
  double computeMinIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(height, _computeMinIntrinsicChildWidth);
  }

  @override
  @protected
  double computeMaxIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(height, _computeMaxIntrinsicChildWidth);
  }

  @override
  @protected
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  @protected
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  bool _needsMetrics = true;
  _TablePaneMetrics? _metrics;

  @protected
  @visibleForTesting
  _TablePaneMetrics get metrics => _metrics!;

  @protected
  void markNeedsMetrics() {
    _needsMetrics = true;
    markNeedsLayout();
  }

  @protected
  void calculateMetricsIfNecessary() {
    assert(debugDoingThisLayout);
    if (_needsMetrics || metrics.constraints != constraints) {
      _metrics = _TablePaneMetrics(this);
      _needsMetrics = false;
      if (metricsController != null) {
        metricsController!._notify();
      }
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
        if (rows
            .any((RenderTableRow row) => row.children.length != cellsPerRow)) {
          final Iterable<int> rowLengths = rows.map<int>((RenderTableRow row) {
            return row.length;
          });
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('RenderTablePane contains irregular row lengths.'),
            ErrorDescription(
                'Every TableRow in a TablePane must have the same number of '
                'children, so that every table cell is filled. Otherwise, the table will '
                'contain holes.'),
            ErrorDescription(
                'The counts of cells per row in this TablePane were: $rowLengths'),
            ErrorSpacer(),
            DiagnosticsProperty<Object>(
                'The RenderTablePane in question was created by', debugCreator,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        if (cellsPerRow != columns.length) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('RenderTablePane cells do not match columns.'),
            ErrorDescription(
                'The number of children inside every TableRow must match the '
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
      double expandedRowWidth = 0;
      double expandedRowHeight = 0;
      for (int j = 0; j < row.length && j < columns.length; j++) {
        final RenderBox child = row[j];

        if (child is RenderEmptyTableCell) {
          cellConstraints.add(BoxConstraints.tight(Size.zero));
          cellPositions.add(Offset(childX, 0));
        } else {
          final TableCellParentData childParentData =
              child.parentData as TableCellParentData;

          final int columnSpan =
              math.min(childParentData.columnSpan, columns.length - j);
          double childWidth = metrics.columnWidths
              .skip(j)
              .take(columnSpan)
              .fold<double>(0, _sum);
          childWidth += (columnSpan - 1) * horizontalSpacing;

          final int rowSpan =
              math.min(childParentData.rowSpan, rows.length - i);
          double childHeight =
              metrics.rowHeights.skip(i).take(rowSpan).fold<double>(0, _sum);
          childHeight += (rowSpan - 1) * verticalSpacing;

          // Set the child's size
          childWidth = math.max(childWidth, 0);
          childHeight = math.max(childHeight, 0);
          cellConstraints.add(
              BoxConstraints.tightFor(width: childWidth, height: childHeight));
          cellPositions.add(Offset(childX, 0));

          expandedRowWidth = math.max(expandedRowWidth, childX + childWidth);
          expandedRowHeight = math.max(expandedRowHeight, childHeight);
        }

        childX += (metrics.columnWidths[j] + horizontalSpacing);
      }

      row.layout(TableRowConstraints.tightFor(
        width: expandedRowWidth,
        height: expandedRowHeight,
        cellConstraints: cellConstraints,
        cellPositions: cellPositions,
      ));

      final TableRowParentData rowParentData =
          row.parentData as TableRowParentData;
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
    properties.add(EnumProperty<MainAxisSize>(
        'horizontalIntrinsicSize', horizontalIntrinsicSize));
    properties.add(EnumProperty<MainAxisSize>(
        'horizontalRelativeSize', horizontalRelativeSize));
    properties.add(EnumProperty<MainAxisSize>(
        'verticalIntrinsicSize', verticalIntrinsicSize));
    properties.add(EnumProperty<MainAxisSize>(
        'verticalRelativeSize', verticalRelativeSize));
    properties
        .add(DiagnosticsProperty<_TablePaneMetrics?>('metrics', _metrics));
  }
}

class TablePaneMetricsController extends ChangeNotifier {
  RenderTablePane? _renderObject;
  void _attach(RenderTablePane renderObject) {
    assert(_renderObject == null);
    assert(renderObject.attached);
    _renderObject = renderObject;
    notifyListeners();
  }

  void _detach() {
    assert(_renderObject != null);
    _renderObject = null;
    notifyListeners();
  }

  void _notify() {
    assert(hasMetrics);
    notifyListeners();
  }

  bool get hasMetrics =>
      _renderObject != null && _renderObject!._metrics != null;

  int? getRowAt(double y) {
    assert(hasMetrics);
    final double verticalSpacing = _renderObject!.verticalSpacing;
    final List<double> rowHeights = _renderObject!._metrics!.rowHeights;
    double top = 0;
    for (int i = 0; i < rowHeights.length; i++) {
      final double bottom = top + rowHeights[i];
      if (y >= top && y <= bottom) {
        return i;
      }
      top = bottom + verticalSpacing;
    }
    return null;
  }

  Rect? getRowBounds(int row) {
    assert(hasMetrics);
    final double verticalSpacing = _renderObject!.verticalSpacing;
    final List<double> rowHeights = _renderObject!._metrics!.rowHeights;
    if (row < 0 || row >= rowHeights.length) {
      return null;
    }
    final double top =
        rowHeights.take(row).fold<double>(0, _sum) + row * verticalSpacing;
    return Rect.fromLTWH(0, top, _renderObject!.size.width, rowHeights[row]);
  }

  int? getColumnAt(double x) {
    assert(hasMetrics);
    final double horizontalSpacing = _renderObject!.horizontalSpacing;
    final List<double> columnWidths = _renderObject!._metrics!.columnWidths;
    double left = 0;
    for (int j = 0; j < columnWidths.length; j++) {
      final double right = left + columnWidths[j];
      if (x >= left && x <= right) {
        return j;
      }
      left = right + horizontalSpacing;
    }
    return null;
  }

  Rect? getColumnBounds(int column) {
    assert(hasMetrics);
    final double horizontalSpacing = _renderObject!.horizontalSpacing;
    final List<double> columnWidths = _renderObject!._metrics!.columnWidths;
    if (column < 0 || column >= columnWidths.length) {
      return null;
    }
    final double left = columnWidths.take(column).fold<double>(0, _sum) +
        column * horizontalSpacing;
    return Rect.fromLTWH(
        left, 0, columnWidths[column], _renderObject!.size.height);
  }
}

class _TablePaneMetrics with Diagnosticable {
  const _TablePaneMetrics._(
      this.constraints, this.columnWidths, this.rowHeights);

  factory _TablePaneMetrics(RenderTablePane tablePane) {
    final BoxConstraints constraints = tablePane.constraints;
    final LinearConstraints widthConstraints =
        LinearConstraints.width(constraints);
    final LinearConstraints heightConstraints =
        LinearConstraints.height(constraints);
    List<double> columnWidths =
        tablePane._computeActualColumnWidths(widthConstraints);
    List<double> rowHeights =
        tablePane._computeActualRowHeights(heightConstraints, columnWidths);
    return _TablePaneMetrics._(constraints, columnWidths, rowHeights);
  }

  final BoxConstraints constraints;
  final List<double> columnWidths;
  final List<double> rowHeights;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<BoxConstraints>('constraints', constraints));
    properties
        .add(DiagnosticsProperty<List<double>>('columnWidths', columnWidths));
    properties.add(DiagnosticsProperty<List<double>>('rowHeights', rowHeights));
  }
}
