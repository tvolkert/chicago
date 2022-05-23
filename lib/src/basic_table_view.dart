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

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'debug.dart';
import 'listener_list.dart';
import 'segment.dart';
import 'widget_surveyor.dart';

const double _kDoublePrecisionTolerance = 0.001;

/// Signature for a function that renders cells in a [BasicTableView].
///
/// Cell builders are properties of the [BasicTableColumn], so each column
/// specifies the cell builder for cells in that column.
typedef BasicTableCellBuilder = Widget Function(
  BuildContext context,
  int rowIndex,
  int columnIndex,
);

typedef TableCellVisitor = void Function(int rowIndex, int columnIndex);

typedef TableCellChildVisitor = void Function(
    RenderBox child, int rowIndex, int columnIndex);

typedef TableCellHost = void Function(TableCellVisitor visitor);

typedef TableViewLayoutCallback = void Function({
  required TableCellHost visitChildrenToRemove,
  required TableCellHost visitChildrenToBuild,
});

typedef TableViewPrototypeCellBuilder = Widget? Function(int columnIndex);

abstract class AbstractTableColumn with Diagnosticable {
  const AbstractTableColumn();

  TableColumnWidth get width;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Diagnosticable>('width', width));
  }

  @override
  int get hashCode => width.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is AbstractTableColumn && width == other.width;
  }
}

class BasicTableColumn extends AbstractTableColumn {
  const BasicTableColumn({
    this.width = const FlexTableColumnWidth(),
    required this.cellBuilder,
    this.prototypeCellBuilder,
  });

  /// The width specification for this column.
  @override
  final TableColumnWidth width;

  /// The builder responsible for the look & feel of cells in this column.
  final BasicTableCellBuilder cellBuilder;

  /// The builder responsible for building the "prototype cell" for this
  /// column.
  ///
  /// The prototype cell is a cell with sample data that is appropriate for the
  /// column.  The prototype cells for every column join to form a "prototype
  /// row".  The prototype row is used for things like calculating the fixed
  /// row height of a table view or for calculating a table view's baseline.
  ///
  /// Prototype cells are rendered in a standalone widget tree, so any widgets
  /// that require inherited data (such a [DefaultTextStyle] or
  /// [Directionality]) should be explicitly passed such information, or the
  /// builder should explicitly include such inherited widgets in the built
  /// hierarchy.
  ///
  /// If this is not specified, this column wll not contribute data towards the
  /// prototype row. If the prototype row contains no cells, then the table
  /// view will report no baseline.
  final WidgetBuilder? prototypeCellBuilder;

  @override
  int get hashCode => hashValues(super.hashCode, cellBuilder);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return super == other &&
        other is BasicTableColumn &&
        cellBuilder == other.cellBuilder;
  }
}

@immutable
abstract class TableColumnWidth with Diagnosticable {
  const TableColumnWidth(this.width);

  final double width;

  bool get isFlex => false;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DiagnosticsProperty<bool>('isFlex', isFlex));
  }

  @override
  int get hashCode => hashValues(width, isFlex);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is TableColumnWidth &&
        width == other.width &&
        isFlex == other.isFlex;
  }
}

class FixedTableColumnWidth extends TableColumnWidth {
  const FixedTableColumnWidth(super.width)
      : assert(width >= 0),
        assert(width < double.infinity);
}

class FlexTableColumnWidth extends TableColumnWidth {
  const FlexTableColumnWidth({double flex = 1})
      : assert(flex > 0),
        super(flex);

  @override
  bool get isFlex => true;
}

class BasicTableView extends RenderObjectWidget {
  const BasicTableView({
    super.key,
    required this.length,
    required this.columns,
    required this.rowHeight,
    this.roundColumnWidthsToWholePixel = false,
    this.metricsController,
  }) : assert(length >= 0);

  final int length;
  final List<BasicTableColumn> columns;
  final double rowHeight;
  final bool roundColumnWidthsToWholePixel;
  final TableViewMetricsController? metricsController;

  @override
  BasicTableViewElement createElement() => BasicTableViewElement(this);

  @override
  @protected
  RenderBasicTableView createRenderObject(BuildContext context) {
    return RenderBasicTableView(
      rowHeight: rowHeight,
      length: length,
      columns: columns,
      roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
      metricsController: metricsController,
    );
  }

  @override
  @protected
  void updateRenderObject(
      BuildContext context, covariant RenderBasicTableView renderObject) {
    renderObject
      ..rowHeight = rowHeight
      ..length = length
      ..columns = columns
      ..roundColumnWidthsToWholePixel = roundColumnWidthsToWholePixel
      ..metricsController = metricsController;
  }
}

@immutable
class TableViewSlot with Diagnosticable {
  const TableViewSlot(this.rowIndex, this.columnIndex);

  final int rowIndex;
  final int columnIndex;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is TableViewSlot &&
        rowIndex == other.rowIndex &&
        columnIndex == other.columnIndex;
  }

  @override
  int get hashCode => hashValues(rowIndex, columnIndex);

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('row', rowIndex));
    properties.add(IntProperty('column', columnIndex));
  }
}

abstract class TableCellRange with Diagnosticable {
  const TableCellRange();

  void visitCells(TableCellVisitor visitor);

  bool contains(int rowIndex, int columnIndex) {
    bool result = false;
    visitCells((int i, int j) {
      if (i == rowIndex && j == columnIndex) {
        result = true;
      }
    });
    return result;
  }

  bool containsCell(TableCellOffset cellOffset) {
    return contains(cellOffset.rowIndex, cellOffset.columnIndex);
  }

  /// The collection of rows contained in this cell range.
  ///
  /// If a row appears in this iterable, it does _not_ necessarily follow that
  /// all cells in the row are contained in this cell range. Put another way,
  /// if only one cell in a row is contained in this cell range, the row will
  /// still be returned here.
  ///
  /// Each row will only appear once in the returned iterable, even if multiple
  /// cells within that row are contained in this cell range.
  Iterable<int> get rows {
    final Set<int> visitedRows = <int>{};
    visitCells((int rowIndex, int columnIndex) {
      if (!visitedRows.contains(rowIndex)) {
        visitedRows.add(rowIndex);
      }
    });
    return visitedRows;
  }

  TableCellRange where(bool Function(int rowIndex, int columnIndex) test) {
    return ProxyTableCellRange((TableCellVisitor visitor) {
      visitCells((int rowIndex, int columnIndex) {
        if (test(rowIndex, columnIndex)) {
          visitor(rowIndex, columnIndex);
        }
      });
    });
  }

  TableCellRange subtract(TableCellRange other) {
    return where((int rowIndex, int columnIndex) =>
        !other.contains(rowIndex, columnIndex));
  }

  TableCellRange intersect(TableCellRange other) {
    return where((int rowIndex, int columnIndex) =>
        other.contains(rowIndex, columnIndex));
  }
}

class SingleCellRange extends TableCellRange {
  const SingleCellRange(this.rowIndex, this.columnIndex);

  final int rowIndex;
  final int columnIndex;

  @override
  void visitCells(TableCellVisitor visitor) {
    visitor(rowIndex, columnIndex);
  }

  @override
  bool contains(int rowIndex, int columnIndex) {
    return rowIndex == this.rowIndex && columnIndex == this.columnIndex;
  }

  @override
  Iterable<int> get rows {
    return <int>[rowIndex];
  }
}

class TableCellRect extends TableCellRange {
  const TableCellRect.fromLTRB(this.left, this.top, this.right, this.bottom);

  final int left;
  final int top;
  final int right;
  final int bottom;

  static const TableCellRect empty = TableCellRect.fromLTRB(0, 0, -1, -1);

  bool get isNormalized =>
      left >= 0 && top >= 0 && left <= right && top <= bottom;

  /// True if [visitCells] will not visit anything.
  ///
  /// An empty [TableCellRect] is guaranteed to have an [isNormalized] value of
  /// false.
  bool get isEmpty => left > right || top > bottom;

  @override
  void visitCells(TableCellVisitor visitor) {
    for (int rowIndex = top; rowIndex <= bottom; rowIndex++) {
      for (int columnIndex = left; columnIndex <= right; columnIndex++) {
        visitor(rowIndex, columnIndex);
      }
    }
  }

  @override
  bool contains(int rowIndex, int columnIndex) {
    return rowIndex >= top &&
        rowIndex <= bottom &&
        columnIndex >= left &&
        columnIndex <= right;
  }

  @override
  Iterable<int> get rows {
    return List<int>.generate(bottom - top + 1, (int i) => top + i);
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('left', left));
    properties.add(IntProperty('top', top));
    properties.add(IntProperty('right', right));
    properties.add(IntProperty('bottom', bottom));
  }
}

class EmptyTableCellRange extends TableCellRange {
  const EmptyTableCellRange();

  @override
  void visitCells(TableCellVisitor visitor) {}

  @override
  bool contains(int rowIndex, int columnIndex) => false;

  @override
  Iterable<int> get rows => <int>[];
}

class ProxyTableCellRange extends TableCellRange {
  const ProxyTableCellRange(this.host);

  final TableCellHost host;

  @override
  void visitCells(TableCellVisitor visitor) => host(visitor);

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Function>('host', host));
  }
}

class UnionTableCellRange extends TableCellRange {
  UnionTableCellRange([
    List<TableCellRange> ranges = const <TableCellRange>[],
  ]) : _ranges = List<TableCellRange>.from(ranges);

  final List<TableCellRange> _ranges;

  void add(TableCellRange range) {
    _ranges.add(range);
  }

  @override
  void visitCells(TableCellVisitor visitor) {
    final Set<TableCellOffset> cellOffsets = <TableCellOffset>{};
    for (TableCellRange range in _ranges) {
      range.visitCells((int rowIndex, int columnIndex) {
        if (cellOffsets.add(TableCellOffset(rowIndex, columnIndex))) {
          visitor(rowIndex, columnIndex);
        }
      });
    }
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<List<TableCellRange>>('ranges', _ranges));
  }
}

@immutable
class TableCellOffset with Diagnosticable {
  const TableCellOffset(this.rowIndex, this.columnIndex);

  final int rowIndex;
  final int columnIndex;

  @override
  int get hashCode => hashValues(rowIndex, columnIndex);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is TableCellOffset &&
        other.rowIndex == rowIndex &&
        other.columnIndex == columnIndex;
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('rowIndex', rowIndex));
    properties.add(IntProperty('columnIndex', columnIndex));
  }
}

mixin TableViewElementMixin on RenderObjectElement {
  @override
  RenderTableViewMixin get renderObject =>
      super.renderObject as RenderTableViewMixin;

  @protected
  Widget renderCell(int rowIndex, int columnIndex);

  @protected
  Widget? buildPrototypeCell(int columnIndex);

  late Map<int, Map<int, Element>> _children;

  @override
  void update(RenderObjectWidget newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    renderObject.updateLayoutCallback(_layout);
    renderObject.updatePrototypeCellBuilder(buildPrototypeCell);
  }

  void _layout({
    required TableCellHost visitChildrenToRemove,
    required TableCellHost visitChildrenToBuild,
  }) {
    owner!.buildScope(this, () {
      visitChildrenToRemove((int rowIndex, int columnIndex) {
        assert(_children.containsKey(rowIndex));
        final Map<int, Element> row = _children[rowIndex]!;
        assert(row.containsKey(columnIndex));
        final Element child = row[columnIndex]!;
        final Element? newChild =
            updateChild(child, null, null /* unused for remove */);
        assert(newChild == null);
        row.remove(columnIndex);
        if (row.isEmpty) {
          _children.remove(rowIndex);
        }
      });
      visitChildrenToBuild((int rowIndex, int columnIndex) {
        Widget built;
        try {
          built = renderCell(rowIndex, columnIndex);
          assert(() {
            if (debugPaintTableCellBuilds) {
              debugCurrentTableCellColor = debugCurrentTableCellColor
                  .withHue((debugCurrentTableCellColor.hue + 2) % 360.0);
              built = DecoratedBox(
                decoration:
                    BoxDecoration(color: debugCurrentTableCellColor.toColor()),
                position: DecorationPosition.foreground,
                child: built,
              );
            }
            return true;
          }());
          debugWidgetBuilderValue(widget, built);
        } catch (e, stack) {
          built = ErrorWidget.builder(
            _debugReportException(
              ErrorDescription('building $widget'),
              e,
              stack,
              informationCollector: () sync* {
                yield DiagnosticsDebugCreator(DebugCreator(this));
              },
            ),
          );
        }
        late final Element child;
        final TableViewSlot slot = TableViewSlot(rowIndex, columnIndex);
        final Map<int, Element> row =
            _children.putIfAbsent(rowIndex, () => <int, Element>{});
        try {
          child = updateChild(row[columnIndex], built, slot)!;
        } catch (e, stack) {
          built = ErrorWidget.builder(
            _debugReportException(
              ErrorDescription('building $widget'),
              e,
              stack,
              informationCollector: () sync* {
                yield DiagnosticsDebugCreator(DebugCreator(this));
              },
            ),
          );
          child = updateChild(null, built, slot)!;
        }
        row[columnIndex] = child;
      });
    });
  }

  static FlutterErrorDetails _debugReportException(
    DiagnosticsNode context,
    dynamic exception,
    StackTrace stack, {
    required InformationCollector informationCollector,
  }) {
    final FlutterErrorDetails details = FlutterErrorDetails(
      exception: exception,
      stack: stack,
      library: 'payouts',
      context: context,
      informationCollector: informationCollector,
    );
    FlutterError.reportError(details);
    return details;
  }

  @override
  void performRebuild() {
    // This gets called if markNeedsBuild() is called on us.
    // That might happen if, e.g., our builder uses Inherited widgets.

    // Force the callback to be called, even if the layout constraints are the
    // same. This is because that callback may depend on the updated widget
    // configuration, or an inherited widget.
    renderObject.markNeedsBuild();
    super.performRebuild(); // Calls widget.updateRenderObject
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _children = <int, Map<int, Element>>{};
    renderObject.updateLayoutCallback(_layout);
    renderObject.updatePrototypeCellBuilder(buildPrototypeCell);
  }

  @override
  void unmount() {
    renderObject.updateLayoutCallback(null);
    renderObject.updatePrototypeCellBuilder(null);
    super.unmount();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Map<int, Element> row in _children.values) {
      for (final Element child in row.values) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(child.slot is TableViewSlot);
    final TableViewSlot slot = child.slot as TableViewSlot;
    assert(_children.containsKey(slot.rowIndex));
    final Map<int, Element> row = _children[slot.rowIndex]!;
    assert(row.containsKey(slot.columnIndex));
    assert(row[slot.columnIndex] == child);
    row.remove(slot.columnIndex);
    if (row.isEmpty) {
      _children.remove(slot.rowIndex);
    }
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(RenderBox child, TableViewSlot slot) {
    assert(child.parent == null);
    renderObject.insert(child,
        rowIndex: slot.rowIndex, columnIndex: slot.columnIndex);
    assert(child.parent == renderObject);
  }

  @override
  void moveRenderObjectChild(
      RenderBox child, TableViewSlot? oldSlot, TableViewSlot newSlot) {
    assert(child.parent == renderObject);
    renderObject.move(child,
        rowIndex: newSlot.rowIndex, columnIndex: newSlot.columnIndex);
    assert(child.parent == renderObject);
  }

  @override
  void removeRenderObjectChild(RenderBox child, TableViewSlot? slot) {
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(child.parent == null);
  }
}

class BasicTableViewElement extends RenderObjectElement
    with TableViewElementMixin {
  BasicTableViewElement(BasicTableView super.tableView);

  @override
  BasicTableView get widget => super.widget as BasicTableView;

  @override
  RenderBasicTableView get renderObject =>
      super.renderObject as RenderBasicTableView;

  @override
  @protected
  Widget renderCell(int rowIndex, int columnIndex) {
    final BasicTableColumn column = widget.columns[columnIndex];
    return column.cellBuilder(this, rowIndex, columnIndex);
  }

  @override
  @protected
  Widget? buildPrototypeCell(int columnIndex) {
    final BasicTableColumn column = widget.columns[columnIndex];
    return column.prototypeCellBuilder != null
        ? column.prototypeCellBuilder!(this)
        : null;
  }
}

mixin RenderTableViewMixin on RenderSegment {
  List<AbstractTableColumn> get columns;
  set columns(covariant List<AbstractTableColumn> value);

  @protected
  List<AbstractTableColumn>? get rawColumns;

  double? _rowHeight;
  double get rowHeight => _rowHeight!;
  set rowHeight(double value) {
    if (_rowHeight == value) return;
    _rowHeight = value;
    markNeedsMetrics();
    // The fact that the cell constraints changed could affect the built
    // output (e.g. if the cell builder uses LayoutBuilder).
    markNeedsBuild();
  }

  int? _length;
  int get length => _length!;
  set length(int value) {
    assert(value >= 0);
    if (_length == value) return;
    _length = value;
    markNeedsMetrics();
    // We rebuild because the cell at any given offset may not contain the same
    // contents as it did before the length changed.
    markNeedsBuild();
  }

  @protected
  int? get rawLength => _length;

  bool? _roundColumnWidthsToWholePixel;
  bool get roundColumnWidthsToWholePixel => _roundColumnWidthsToWholePixel!;
  set roundColumnWidthsToWholePixel(bool value) {
    if (_roundColumnWidthsToWholePixel == value) return;
    _roundColumnWidthsToWholePixel = value;
    markNeedsMetrics();
    // The fact that the cell constraints may change could affect the built
    // output (e.g. if the cell builder uses LayoutBuilder).
    markNeedsBuild();
  }

  TableViewMetricsController? _metricsController;
  TableViewMetricsController? get metricsController => _metricsController;
  set metricsController(TableViewMetricsController? value) {
    if (value == _metricsController) return;
    _metricsController = value;
    if (_metricsController != null && !_needsMetrics) {
      _metricsController!._setMetrics(_metrics!);
    }
  }

  final Map<int, Map<int, RenderBox>> _children = <int, Map<int, RenderBox>>{};

  void insert(
    RenderBox child, {
    required int rowIndex,
    required int columnIndex,
  }) {
    final Map<int, RenderBox> row =
        _children.putIfAbsent(rowIndex, () => <int, RenderBox>{});
    final RenderBox? oldChild = row.remove(columnIndex);
    if (oldChild != null) dropChild(oldChild);
    row[columnIndex] = child;
    child.parentData = _TableViewParentData()
      ..rowIndex = rowIndex
      ..columnIndex = columnIndex;
    adoptChild(child);
  }

  void move(
    RenderBox child, {
    required int rowIndex,
    required int columnIndex,
  }) {
    remove(child);
    insert(child, rowIndex: rowIndex, columnIndex: columnIndex);
  }

  void remove(RenderBox child) {
    assert(child.parentData is _TableViewParentData);
    final _TableViewParentData parentData =
        child.parentData as _TableViewParentData;
    final Map<int, RenderBox> row = _children[parentData.rowIndex]!;
    row.remove(parentData.columnIndex);
    if (row.isEmpty) {
      _children.remove(parentData.rowIndex);
    }
    dropChild(child);
  }

  TableViewLayoutCallback? _layoutCallback;

  /// Change the layout callback.
  @protected
  void updateLayoutCallback(TableViewLayoutCallback? value) {
    if (value == _layoutCallback) return;
    _layoutCallback = value;
    markNeedsBuild();
  }

  TableViewPrototypeCellBuilder? _prototypeCellBuilder;

  @protected
  void updatePrototypeCellBuilder(TableViewPrototypeCellBuilder? value) {
    if (value == _prototypeCellBuilder) return;
    _prototypeCellBuilder = value;
    markNeedsLayout();
  }

  /// Whether the whole table view is in need of being built.
  bool _needsBuild = true;

  /// Marks this table view as needing to rebuild.
  ///
  /// See also:
  ///
  ///  * [markCellsDirty], which marks specific cells as needing to rebuild.
  @protected
  void markNeedsBuild() {
    _needsBuild = true;
    markNeedsLayout();
  }

  /// Specific cells in need of building.
  UnionTableCellRange? _dirtyCells;

  /// Marks specific cells as needing to rebuild.
  ///
  /// See also:
  ///
  ///  * [markNeedsBuild], which marks the whole table view as needing to
  ///    rebuild.
  @protected
  void markCellsDirty(TableCellRange cells) {
    _dirtyCells ??= UnionTableCellRange();
    _dirtyCells!.add(cells);
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    visitChildren((RenderObject child) {
      child.attach(owner);
    });
  }

  @override
  void detach() {
    super.detach();
    visitChildren((RenderObject child) {
      child.detach();
    });
  }

  @protected
  void visitTableCells(TableCellChildVisitor visitor,
      {bool allowMutations = false}) {
    Iterable<MapEntry<int, Map<int, RenderBox>>> rows = _children.entries;
    if (allowMutations) rows = rows.toList(growable: false);
    for (MapEntry<int, Map<int, RenderBox>> row in rows) {
      final int rowIndex = row.key;
      Iterable<MapEntry<int, RenderBox>> cells = row.value.entries;
      if (allowMutations) cells = cells.toList(growable: false);
      for (MapEntry<int, RenderBox> cell in cells) {
        final int columnIndex = cell.key;
        final RenderBox child = cell.value;
        visitor(child, rowIndex, columnIndex);
      }
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    visitTableCells((RenderBox child, int rowIndex, int columnIndex) {
      visitor(child);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final TableCellOffset? cellOffset = metrics.getCellAt(position);
    if (cellOffset == null ||
        !_children.containsKey(cellOffset.rowIndex) ||
        !_children[cellOffset.rowIndex]!.containsKey(cellOffset.columnIndex)) {
      // No table cell at the given position.
      return false;
    }
    final RenderBox child =
        _children[cellOffset.rowIndex]![cellOffset.columnIndex]!;
    final BoxParentData parentData = child.parentData as BoxParentData;
    return result.addWithPaintOffset(
      offset: parentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - parentData.offset);
        return child.hitTest(result, position: transformed);
      },
    );
  }

  @override
  void setupParentData(RenderBox child) {
    // We manually attach the parent data in [insert] before adopting the child,
    // so by the time this is called, the parent data is already set-up.
    assert(child.parentData is _TableViewParentData);
    super.setupParentData(child);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return columns
        .map<TableColumnWidth>((AbstractTableColumn column) => column.width)
        .where((TableColumnWidth width) => !width.isFlex)
        .map<double>((TableColumnWidth width) => width.width)
        .map<double>(
            (double w) => roundColumnWidthsToWholePixel ? w.roundToDouble() : w)
        .fold<double>(0, (double previous, double width) => previous + width);
  }

  @override
  double computeMaxIntrinsicWidth(double height) =>
      computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    return length * rowHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    double? result;

    const WidgetSurveyor surveyor = WidgetSurveyor();
    if (_prototypeCellBuilder != null) {
      for (int j = 0; j < columns.length; j++) {
        final Widget? prototype = _prototypeCellBuilder!(j);
        if (prototype != null) {
          final double? value = surveyor.measureDistanceToActualBaseline(
            prototype,
            baseline: baseline,
          );
          if (result != null) {
            result = math.max(result, value ?? 0);
          } else {
            result = value;
          }
        }
      }
    }

    return result;
  }

  bool _needsMetrics = true;
  TableViewMetricsResolver? _metrics;
  Rect? _viewport;

  @protected
  TableViewMetricsResolver get metrics => _metrics!;

  @protected
  void markNeedsMetrics() {
    _needsMetrics = true;
    markNeedsLayout();
  }

  @protected
  void calculateMetricsIfNecessary() {
    assert(debugDoingThisLayout);
    final BoxConstraints boxConstraints = constraints.asBoxConstraints();
    if (_needsMetrics || _metrics!.constraints != boxConstraints) {
      _metrics = TableViewMetricsResolver.of(
        columns,
        rowHeight,
        length,
        boxConstraints,
        roundWidths: roundColumnWidthsToWholePixel,
      );
      _needsMetrics = false;
      if (_metricsController != null) {
        _metricsController!._setMetrics(_metrics!);
      }
    }
  }

  @override
  @protected
  void performLayout() {
    calculateMetricsIfNecessary();
    size = constraints.constrainDimensions(
        metrics.totalWidth, metrics.totalHeight);

    // Relies on size being set.
    rebuildIfNecessary();

    visitTableCells((RenderBox child, int rowIndex, int columnIndex) {
      final Range columnBounds = metrics.columnBounds[columnIndex];
      final double rowY = rowIndex * rowHeight;
      child.layout(BoxConstraints.tightFor(
          width: columnBounds.extent, height: rowHeight));
      final BoxParentData parentData = child.parentData as BoxParentData;
      parentData.offset = Offset(columnBounds.start, rowY);
    });
  }

  bool _isInBounds(int rowIndex, int columnIndex) {
    return rowIndex < length && columnIndex < columns.length;
  }

  bool _isBuilt(int rowIndex, int columnIndex) {
    return _children.containsKey(rowIndex) &&
        _children[rowIndex]!.containsKey(columnIndex);
  }

  bool _isNotBuilt(int rowIndex, int columnIndex) {
    return !_children.containsKey(rowIndex) ||
        !_children[rowIndex]!.containsKey(columnIndex);
  }

  @protected
  TableCellRange builtCells() {
    return ProxyTableCellRange((TableCellVisitor visitor) {
      visitTableCells((RenderBox child, int rowIndex, int columnIndex) {
        visitor(rowIndex, columnIndex);
      }, allowMutations: true);
    });
  }

  @protected
  void rebuildIfNecessary() {
    assert(_layoutCallback != null);
    assert(debugDoingThisLayout);
    final Rect? previousViewport = _viewport;
    _viewport = constraints.viewportResolver.resolve(size);
    if (!_needsBuild && _dirtyCells == null && _viewport == previousViewport) {
      return;
    }

    final TableCellRange builtCells = this.builtCells();
    final TableCellRect viewportCellRect = metrics.intersect(_viewport!);
    TableCellRange removeCells = builtCells.subtract(viewportCellRect);
    TableCellRange buildCells;

    if (_needsBuild) {
      removeCells = UnionTableCellRange(<TableCellRange>[
        removeCells,
        builtCells.where((int rowIndex, int columnIndex) => rowIndex >= length)
      ]);
      buildCells = viewportCellRect;
      _needsBuild = false;
      _dirtyCells = null;
    } else if (_dirtyCells != null) {
      buildCells = UnionTableCellRange(<TableCellRange>[
        _dirtyCells!.intersect(viewportCellRect),
        viewportCellRect.where(_isNotBuilt),
      ]);
      _dirtyCells = null;
    } else {
      assert(previousViewport != null);
      if (_viewport!.overlaps(previousViewport!)) {
        final Rect overlap = _viewport!.intersect(previousViewport);
        final TableCellRect overlapCellRect = metrics.intersect(overlap);
        removeCells =
            metrics.intersect(previousViewport).subtract(overlapCellRect);
        buildCells = viewportCellRect.subtract(overlapCellRect);
      } else {
        buildCells = viewportCellRect;
      }
    }

    // TODO: lowering length causes stranded built cells - figure out why...
    invokeLayoutCallback<SegmentConstraints>((SegmentConstraints _) {
      _layoutCallback!(
        visitChildrenToRemove: removeCells.where(_isBuilt).visitCells,
        visitChildrenToBuild: buildCells.where(_isInBounds).visitCells,
      );
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    visitChildren((RenderObject child) {
      final BoxParentData parentData = child.parentData as BoxParentData;
      context.paintChild(child, offset + parentData.offset);
    });
  }

  @override
  void redepthChildren() {
    visitChildren((RenderObject child) {
      redepthChild(child);
    });
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> result = <DiagnosticsNode>[];
    visitTableCells((RenderBox child, int rowIndex, int columnIndex) {
      result.add(child.toDiagnosticsNode(name: 'child $rowIndex,$columnIndex'));
    });
    return result;
  }
}

class RenderBasicTableView extends RenderSegment with RenderTableViewMixin {
  RenderBasicTableView({
    required double rowHeight,
    required int length,
    required List<BasicTableColumn> columns,
    bool roundColumnWidthsToWholePixel = false,
    TableViewMetricsController? metricsController,
  }) {
    this.rowHeight = rowHeight;
    this.length = length;
    this.columns = columns;
    this.roundColumnWidthsToWholePixel = roundColumnWidthsToWholePixel;
    this.metricsController = metricsController;
  }

  List<BasicTableColumn>? _columns;

  @override
  List<BasicTableColumn>? get rawColumns => _columns;

  @override
  List<BasicTableColumn> get columns => _columns!;

  @override
  set columns(List<BasicTableColumn> value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsMetrics();
    markNeedsBuild();
  }
}

class _TableViewParentData extends BoxParentData {
  late int rowIndex;

  late int columnIndex;

  @override
  String toString() =>
      '${super.toString()}, rowIndex=$rowIndex, columnIndex=$columnIndex';
}

/// Class capable of reporting various layout metrics of a [BasicTableView].
@immutable
abstract class TableViewMetrics {
  /// Gets the row index found at the specified y-offset.
  ///
  /// The [dy] argument is in logical pixels and exists in the local coordinate
  /// space of the table view.
  ///
  /// Returns -1 if the offset doesn't overlap with a row in the table view.
  int getRowAt(double dy);

  /// Gets the column index found at the specified x-offset.
  ///
  /// The [dx] argument is in logical pixels and exists in the local coordinate
  /// space of the table view.
  ///
  /// Returns -1 if the offset doesn't overlap with a column in the table view.
  int getColumnAt(double dx);

  /// Gets the cell coordinates found at the specified offset.
  ///
  /// The [position] argument is in logical pixels and exists in the local
  /// coordinate space of the table view.
  ///
  /// Returns null if the offset doesn't overlap with a cell in the table view.
  TableCellOffset? getCellAt(Offset position);

  /// Gets the bounding [Rect] of the specified row in the table view.
  ///
  /// The returned [Rect] exists in the local coordinate space of the table
  /// view.
  ///
  /// The [rowIndex] argument must be greater than or equal to zero and less
  /// than the number of rows in the table view.
  Rect getRowBounds(int rowIndex);

  /// Gets the bounding [Rect] of the specified column in the table view.
  ///
  /// The returned [Rect] exists in the local coordinate space of the table
  /// view.
  ///
  /// The [columnIndex] argument must be greater than or equal to zero and less
  /// than the number of columns in the table view.
  Rect getColumnBounds(int columnIndex);

  /// Gets the bounding [Rect] of the specified cell in the table view.
  ///
  /// The returned [Rect] exists in the local coordinate space of the table
  /// view.
  ///
  /// Both the [rowIndex] and the [columnIndex] argument must represent valid
  /// (in bounds) values given the number of rows and columns in the table
  /// view.
  Rect getCellBounds(int rowIndex, int columnIndex);
}

typedef TableViewMetricsChangedHandler = void Function(
  TableViewMetricsController controller,
  TableViewMetrics? oldMetrics,
);

class TableViewMetricsListener {
  const TableViewMetricsListener({
    required this.onChanged,
  });

  final TableViewMetricsChangedHandler onChanged;
}

class TableViewMetricsController
    with ListenerNotifier<TableViewMetricsListener> {
  TableViewMetrics? _metrics;
  TableViewMetrics get metrics => _metrics!;
  void _setMetrics(TableViewMetrics value) {
    if (value == _metrics) return;
    final TableViewMetrics? oldValue = _metrics;
    _metrics = value;
    notifyListeners((TableViewMetricsListener listener) {
      listener.onChanged(this, oldValue);
    });
  }
}

/// Resolves column width specifications against [BoxConstraints].
///
/// Produces a list of column widths whose sum satisfies the
/// [BoxConstraints.maxWidth] property of the [constraints] and whose values
/// are as close as possible to satisfying the column width specifications.
///
/// The sum of the column widths isn't required to satisfy the
/// [BoxConstraints.minWidth] property of the [constraints] because the table
/// view can be wider than the sum of its columns (yielding blank space), but
/// it can't be skinnier.
///
/// The returned list is guaranteed to be the same length as [columns] and
/// contain only non-negative finite values.
@visibleForTesting
class TableViewMetricsResolver implements TableViewMetrics {
  const TableViewMetricsResolver._(
    this.columns,
    this.constraints,
    this.rowHeight,
    this.length,
    this.columnBounds,
  );

  /// The columns of the table view.
  ///
  /// Each column's [AbstractTableColumn.width] specification is the source (when
  /// combined with [constraints]) of the resolved column widths in
  /// [columnWidth].
  final List<AbstractTableColumn> columns;

  /// The [BoxConstraints] against which the width specifications of the
  /// [columns] were resolved.
  final BoxConstraints constraints;

  /// The fixed row height of each row in the table view.
  final double rowHeight;

  /// The number of rows in the table view.
  final int length;

  /// The offsets & widths of the columns in the table view.
  ///
  /// The values in this list correspond to the columns in the [columns] list.
  final List<Range> columnBounds;

  static TableViewMetricsResolver of(
    List<AbstractTableColumn> columns,
    double rowHeight,
    int length,
    BoxConstraints constraints, {
    bool roundWidths = false,
  }) {
    assert(constraints.runtimeType == BoxConstraints);
    double totalFlexWidth = 0;
    double totalFixedWidth = 0;
    final List<double> resolvedWidths = List<double>.filled(columns.length, 0);
    final Map<int, AbstractTableColumn> flexColumns =
        <int, AbstractTableColumn>{};

    // Reserve space for the fixed-width columns first.
    for (int i = 0; i < columns.length; i++) {
      final AbstractTableColumn column = columns[i];
      if (column.width.isFlex) {
        final FlexTableColumnWidth widthSpecification =
            column.width as FlexTableColumnWidth;
        totalFlexWidth += widthSpecification.width;
        flexColumns[i] = column;
      } else {
        double columnWidth = column.width.width;
        if (roundWidths) {
          columnWidth = columnWidth.roundToDouble();
        }
        totalFixedWidth += columnWidth;
        resolvedWidths[i] = columnWidth;
      }
    }

    double maxWidthDelta = constraints.maxWidth - totalFixedWidth;
    if (maxWidthDelta.isNegative) {
      // The fixed-width columns have already exceeded the maxWidth constraint;
      // truncate trailing column widths until we meet the constraint.
      for (int i = resolvedWidths.length - 1; i >= 0; i--) {
        final double width = resolvedWidths[i];
        if (width > 0) {
          final double adjustedWidth = math.max(width + maxWidthDelta, 0);
          final double adjustment = width - adjustedWidth;
          maxWidthDelta += adjustment;
          if (maxWidthDelta >= 0) {
            break;
          }
        }
      }
      assert(() {
        if (maxWidthDelta < -_kDoublePrecisionTolerance) {
          FlutterError.reportError(FlutterErrorDetails(
            exception:
                'TableView column width adjustment was unable to satisfy the '
                'maxWidth constraint',
            stack: StackTrace.current,
            library: 'payouts',
          ));
        }
        return true;
      }());
    } else if (flexColumns.isNotEmpty) {
      // There's still width to spare after fixed-width column allocations.
      double flexAllocation = 0;
      if (maxWidthDelta.isFinite) {
        flexAllocation = maxWidthDelta;
      } else if (totalFixedWidth < constraints.minWidth) {
        flexAllocation = constraints.minWidth - totalFixedWidth;
      }
      if (flexAllocation > 0) {
        for (MapEntry<int, AbstractTableColumn> flexColumn
            in flexColumns.entries) {
          final FlexTableColumnWidth widthSpecification =
              flexColumn.value.width as FlexTableColumnWidth;
          final double allocationPercentage =
              widthSpecification.width / totalFlexWidth;
          double columnWidth = flexAllocation * allocationPercentage;
          if (roundWidths) {
            columnWidth = columnWidth.roundToDouble();
          }
          resolvedWidths[flexColumn.key] = columnWidth;
        }
      }
    }

    double left = 0;
    final List<Range> resolvedColumnBounds =
        List<Range>.generate(columns.length, (int index) {
      final double right = left + resolvedWidths[index];
      final Range result = Range(left, right);
      left = right;
      return result;
    });

    return TableViewMetricsResolver._(
      columns,
      constraints,
      rowHeight,
      length,
      resolvedColumnBounds,
    );
  }

  /// The total column width of the table view.
  double get totalWidth => columnBounds.isEmpty ? 0 : columnBounds.last.end;

  double get totalHeight => length * rowHeight;

  TableCellRect intersect(Rect rect) {
    if (rect.isEmpty) {
      return TableCellRect.empty;
    }
    int leftIndex =
        columnBounds.indexWhere((Range bounds) => bounds.end > rect.left);
    int rightIndex = columnBounds
        .lastIndexWhere((Range bounds) => bounds.start < rect.right);
    if (leftIndex == -1 || rightIndex == -1) {
      return TableCellRect.empty;
    } else {
      int bottomIndex = rect.bottom ~/ rowHeight;
      if (rect.bottom.remainder(rowHeight) == 0) {
        // The rect goes *right up* to the cell but doesn't actually overlap it.
        bottomIndex -= 1;
      }
      return TableCellRect.fromLTRB(
        leftIndex,
        rect.top ~/ rowHeight,
        rightIndex,
        bottomIndex,
      );
    }
  }

  @override
  Rect getRowBounds(int rowIndex) {
    assert(rowIndex >= 0 && rowIndex < length);
    return Rect.fromLTWH(0, rowIndex * rowHeight, totalWidth, rowHeight);
  }

  @override
  Rect getColumnBounds(int columnIndex) {
    assert(columnIndex >= 0 && columnIndex < columnBounds.length);
    final Range columnRange = columnBounds[columnIndex];
    return Rect.fromLTRB(
        columnRange.start, 0, columnRange.end, length * rowHeight);
  }

  @override
  Rect getCellBounds(int rowIndex, int columnIndex) {
    final Range columnRange = columnBounds[columnIndex];
    final double rowStart = rowIndex * rowHeight;
    return Rect.fromLTRB(
        columnRange.start, rowStart, columnRange.end, rowStart + rowHeight);
  }

  @override
  int getRowAt(double dy) {
    assert(dy.isFinite);
    if (dy.isNegative) {
      return -1;
    }
    final int rowIndex = dy ~/ rowHeight;
    if (rowIndex >= length) {
      return -1;
    }
    return rowIndex;
  }

  @override
  int getColumnAt(double dx) {
    assert(dx.isFinite);
    int columnIndex =
        columnBounds.indexWhere((Range range) => range.start <= dx);
    if (columnIndex >= 0) {
      columnIndex =
          columnBounds.indexWhere((Range range) => range.end > dx, columnIndex);
    }
    return columnIndex;
  }

  @override
  TableCellOffset? getCellAt(Offset position) {
    final int rowIndex = getRowAt(position.dy);
    final int columnIndex = getColumnAt(position.dx);
    if (rowIndex == -1 || columnIndex == -1) {
      return null;
    }
    return TableCellOffset(rowIndex, columnIndex);
  }
}

class Range with Diagnosticable {
  const Range(this.start, this.end) : assert(start <= end);

  final double start;
  final double end;

  double get extent => end - start;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('start', start));
    properties.add(DoubleProperty('end', end));
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Range && other.start == start && other.end == end;
  }
}
