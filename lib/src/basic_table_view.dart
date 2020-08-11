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

import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'segment.dart';

const double _kDoublePrecisionTolerance = 0.001;

typedef TableCellRenderer = Widget Function({
  BuildContext context,
  int rowIndex,
  int columnIndex,
});

typedef TableCellVisitor = void Function(int rowIndex, int columnIndex);

typedef TableCellChildVisitor = void Function(RenderBox child, int rowIndex, int columnIndex);

typedef TableCellHost = void Function(TableCellVisitor visitor);

typedef TableViewLayoutCallback = void Function({
  TableCellHost visitChildrenToRemove,
  TableCellHost visitChildrenToBuild,
});

@immutable
class BasicTableColumn with Diagnosticable {
  const BasicTableColumn({
    this.width = const FlexTableColumnWidth(),
    @required this.cellRenderer,
  });

  final TableColumnWidth width;
  final TableCellRenderer cellRenderer;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Diagnosticable>('width', width));
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
}

class FixedTableColumnWidth extends TableColumnWidth {
  const FixedTableColumnWidth(double width)
      : assert(width >= 0),
        assert(width < double.infinity),
        super(width);
}

class FlexTableColumnWidth extends TableColumnWidth {
  const FlexTableColumnWidth({double flex = 1})
      : assert(flex != null),
        assert(flex > 0),
        super(flex);

  @override
  bool get isFlex => true;
}

class BasicTableView extends RenderObjectWidget {
  const BasicTableView({
    Key key,
    @required this.length,
    @required this.columns,
    @required this.rowHeight,
  })  : assert(length != null),
        assert(columns != null),
        assert(rowHeight != null),
        assert(length >= 0),
        super(key: key);

  final int length;
  final List<BasicTableColumn> columns;
  final double rowHeight;

  @override
  BasicTableViewElement createElement() => BasicTableViewElement(this);

  @override
  RenderBasicTableView createRenderObject(BuildContext context) {
    return RenderBasicTableView(rowHeight: rowHeight, length: length, columns: columns);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBasicTableView renderObject) {
    renderObject
      ..rowHeight = rowHeight
      ..length = length
      ..columns = columns;
  }
}

@immutable
class TableViewSlot with Diagnosticable {
  const TableViewSlot(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TableViewSlot && row == other.row && column == other.column;
  }

  @override
  int get hashCode => hashValues(row, column);

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('row', row));
    properties.add(IntProperty('column', column));
  }
}

abstract class TableCellRange with Diagnosticable {
  const TableCellRange();

  void visitCells(TableCellVisitor visitor);
}

class TableCellRect extends TableCellRange {
  const TableCellRect.fromLTRB(this.left, this.top, this.right, this.bottom);

  final int left;
  final int top;
  final int right;
  final int bottom;

  TableCellRange deflate(TableCellRect rect) {
    return TableCellRect.fromLTRB(
      left + rect.left,
      top + rect.top,
      right - rect.right,
      bottom - rect.bottom,
    );
  }

  @override
  void visitCells(TableCellVisitor visitor) {
    for (int rowIndex = top; rowIndex <= bottom; rowIndex++) {
      for (int columnIndex = left; columnIndex <= right; columnIndex++) {
        visitor(rowIndex, columnIndex);
      }
    }
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
  ])  : assert(ranges != null),
        _ranges = List<TableCellRange>.from(ranges);

  final List<TableCellRange> _ranges;

  void add(TableCellRange range) {
    _ranges.add(range);
  }

  @override
  void visitCells(TableCellVisitor visitor) {
    Set<Pair<int>> pairs = <Pair<int>>{};
    for (TableCellRange range in _ranges) {
      range.visitCells((int rowIndex, int columnIndex) {
        if (pairs.add(Pair<int>(rowIndex, columnIndex))) {
          visitor(rowIndex, columnIndex);
        }
      });
    }
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<TableCellRange>>('ranges', _ranges));
  }
}

@immutable
class Pair<T> with Diagnosticable {
  const Pair(this.first, this.last)
      : assert(first != null),
        assert(last != null);

  final T first;
  final T last;

  @override
  int get hashCode => hashValues(first, last);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is Pair<T> && other.first == first && other.last == last;
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('first', first));
    properties.add(DiagnosticsProperty<T>('last', last));
  }
}

class BasicTableViewElement extends RenderObjectElement {
  BasicTableViewElement(BasicTableView tableView) : super(tableView);

  @override
  BasicTableView get widget => super.widget as BasicTableView;

  @override
  RenderBasicTableView get renderObject => super.renderObject as RenderBasicTableView;

  Map<int, Map<int, Element>> _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void update(BasicTableView newTable) {
    assert(widget != newTable);
    super.update(newTable);
    assert(widget == newTable);

    renderObject.updateCallback(_layout);
    // Force the callback to be called, even if the layout constraints are the
    // same, because the logic in the callback might have changed.
    renderObject.markNeedsBuild();
  }

  void _layout({
    TableCellHost visitChildrenToRemove,
    TableCellHost visitChildrenToBuild,
  }) {
    owner.buildScope(this, () {
      visitChildrenToRemove((int rowIndex, int columnIndex) {
        assert(_children != null);
        assert(_children.containsKey(rowIndex));
        final Map<int, Element> row = _children[rowIndex];
        assert(row.containsKey(columnIndex));
        final Element child = row[columnIndex];
        assert(child != null);
        final Element newChild = updateChild(child, null, null /* unused for remove */);
        assert(newChild == null);
        row.remove(columnIndex);
        if (row.isEmpty) {
          _children.remove(rowIndex);
        }
      });
      visitChildrenToBuild((int rowIndex, int columnIndex) {
        assert(_children != null);
        final BasicTableColumn column = widget.columns[columnIndex];
        final TableCellRenderer cellRenderer = column.cellRenderer;
        Widget built;
        try {
          built = cellRenderer(
            context: this,
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
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
        Element child;
        final TableViewSlot slot = TableViewSlot(rowIndex, columnIndex);
        final Map<int, Element> row = _children.putIfAbsent(rowIndex, () => <int, Element>{});
        try {
          child = updateChild(row[columnIndex], built, slot);
          assert(child != null);
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
          child = updateChild(null, built, slot);
        }
        row[columnIndex] = child;
      });
    });
  }

  static FlutterErrorDetails _debugReportException(
    DiagnosticsNode context,
    dynamic exception,
    StackTrace stack, {
    InformationCollector informationCollector,
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
    super.performRebuild(); // Calls widget.updateRenderObject (a no-op in this case).
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _children = <int, Map<int, Element>>{};
    renderObject.updateCallback(_layout);
  }

  @override
  void unmount() {
    renderObject.updateCallback(null);
    super.unmount();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Map<int, Element> row in _children.values) {
      for (final Element child in row.values) {
        assert(child != null);
        if (!_forgottenChildren.contains(child)) {
          visitor(child);
        }
      }
    }
  }

  @override
  void forgetChild(Element child) {
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  @override
  void insertChildRenderObject(RenderObject child, TableViewSlot slot) {
    assert(child.parent == null);
    renderObject.insert(child, rowIndex: slot.row, columnIndex: slot.column);
    assert(child.parent == renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, TableViewSlot slot) {
    assert(child.parent == renderObject);
    renderObject.move(child, rowIndex: slot.row, columnIndex: slot.column);
    assert(child.parent == renderObject);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(child.parent == null);
  }
}

class RenderBasicTableView extends RenderSegment {
  RenderBasicTableView({
    double rowHeight,
    int length,
    List<BasicTableColumn> columns,
  })  : _rowHeight = rowHeight,
        _length = length,
        _columns = columns;

  double _rowHeight;
  double get rowHeight => _rowHeight;
  set rowHeight(double value) {
    assert(rowHeight != null);
    if (_rowHeight == value) return;
    _rowHeight = value;
    markNeedsLayout();
  }

  int _length;
  int get length => _length;
  set length(int value) {
    assert(length != null);
    assert(length >= 0);
    if (_length == value) return;
    _length = value;
    markNeedsBuild();
  }

  List<BasicTableColumn> _columns;
  List<BasicTableColumn> get columns => _columns;
  set columns(List<BasicTableColumn> value) {
    assert(value != null);
    if (_columns == value) return;
    _columns = value;
    _metrics = null;
    markNeedsBuild();
  }

  Map<int, Map<int, RenderBox>> _children = <int, Map<int, RenderBox>>{};

  void insert(
    RenderBox child, {
    @required int rowIndex,
    @required int columnIndex,
  }) {
    assert(child != null);
    final Map<int, RenderBox> row = _children.putIfAbsent(rowIndex, () => <int, RenderBox>{});
    final RenderBox oldChild = row.remove(columnIndex);
    if (oldChild != null) dropChild(oldChild);
    row[columnIndex] = child;
    child.parentData = _TableViewParentData()
      ..rowIndex = rowIndex
      ..columnIndex = columnIndex;
    adoptChild(child);
  }

  void move(
    RenderBox child, {
    @required int rowIndex,
    @required int columnIndex,
  }) {
    remove(child);
    insert(child, rowIndex: rowIndex, columnIndex: columnIndex);
  }

  void remove(RenderBox child) {
    assert(child != null);
    assert(child.parentData is _TableViewParentData);
    final _TableViewParentData parentData = child.parentData;
    final Map<int, RenderBox> row = _children[parentData.rowIndex];
    row.remove(parentData.columnIndex);
    if (row.isEmpty) {
      _children.remove(parentData.rowIndex);
    }
    dropChild(child);
  }

  TableViewLayoutCallback _layoutCallback;

  /// Change the layout callback.
  void updateCallback(TableViewLayoutCallback value) {
    if (value == _layoutCallback) return;
    _layoutCallback = value;
    markNeedsBuild();
  }

  bool _needsBuild = true;

  /// Marks this layout builder as needing to rebuild.
  void markNeedsBuild() {
    _needsBuild = true;
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

  void visitTableCells(TableCellChildVisitor visitor, {bool allowMutations = false}) {
    Iterable<MapEntry<int, Map<int, RenderBox>>> rows = _children.entries;
    if (allowMutations) rows = rows.toList(growable: false);
    for (MapEntry<int, Map<int, RenderBox>> row in rows) {
      final int rowIndex = row.key;
      Iterable<MapEntry<int, RenderBox>> cells = row.value.entries;
      if (allowMutations) cells = cells.toList(growable: false);
      for (MapEntry<int, RenderBox> cell in cells) {
        final int columnIndex = cell.key;
        final RenderBox child = cell.value;
        assert(child != null);
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
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    visitChildren((RenderObject child) {
      RenderBox childBox = child;
      final BoxParentData parentData = child.parentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - parentData.offset);
          return childBox.hitTest(result, position: transformed);
        },
      );

      // We know that RenderBasicTableView doesn't overlap its children, so if
      // one child had a hit, it precludes other children from having had a
      // hit. Thus we can stop looking for hits after one child reports a hit.
      if (isHit) {
        return true;
      }
    });

    return false;
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
        .map<TableColumnWidth>((BasicTableColumn column) => column.width)
        .where((TableColumnWidth width) => !width.isFlex)
        .fold<double>(0, (double previous, TableColumnWidth width) => previous + width.width);
  }

  @override
  double computeMaxIntrinsicWidth(double height) => computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    return length * rowHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  TableViewMetrics _metrics;
  Rect _viewport;

  @override
  void performLayout() {
    final BoxConstraints boxConstraints = constraints.asBoxConstraints();
    if (_metrics == null || _metrics.constraints != boxConstraints || _metrics.rowHeight != rowHeight) {
      _metrics = TableViewMetrics.of(columns, rowHeight, boxConstraints);
    }

    rebuildIfNecessary();
    size = constraints.constrainDimensions(_metrics.totalWidth, length * rowHeight);

    visitTableCells((RenderBox child, int rowIndex, int columnIndex) {
      final double columnWidth = _metrics.columnWidth[columnIndex];
      final double columnX = _metrics.columnLeft[columnIndex];
      final double rowY = rowIndex * rowHeight;
      child.layout(BoxConstraints.tightFor(width: columnWidth, height: rowHeight));
      final BoxParentData parentData = child.parentData as BoxParentData;
      parentData.offset = Offset(columnX, rowY);
    });
  }

  void rebuildIfNecessary() {
    assert(_layoutCallback != null);
    final UnionTableCellRange buildCells = UnionTableCellRange();
    final UnionTableCellRange removeCells = UnionTableCellRange();
    final TableCellRange allCells = ProxyTableCellRange((TableCellVisitor visitor) {
      visitTableCells((RenderBox child, int rowIndex, int columnIndex) {
        visitor(rowIndex, columnIndex);
      }, allowMutations: true);
    });

    TableCellRange skipAlreadyBuilt(TableCellRange range) {
      return ProxyTableCellRange((TableCellVisitor visitor) {
        range.visitCells((int rowIndex, int columnIndex) {
          if (!_children.containsKey(rowIndex) || !_children[rowIndex].containsKey(columnIndex)) {
            visitor(rowIndex, columnIndex);
          }
        });
      });
    }

    if (_needsBuild) {
      _needsBuild = false;
      final Rect viewport = constraints.viewport;
      if (_viewport != null) {
        if (viewport.overlaps(_viewport)) {
          final Rect overlap = viewport.intersect(_viewport);
          removeCells.add(_metrics.intersect(
            Rect.fromLTRB(_viewport.left, _viewport.top, overlap.left, _viewport.bottom),
            deflate: const TableCellRect.fromLTRB(0, 0, 1, 0),
          ));
          removeCells.add(_metrics.intersect(
            Rect.fromLTRB(overlap.left, _viewport.top, overlap.right, overlap.top),
            deflate: const TableCellRect.fromLTRB(0, 0, 0, 1),
          ));
          removeCells.add(_metrics.intersect(
            Rect.fromLTRB(overlap.left, overlap.bottom, overlap.right, _viewport.bottom),
            deflate: const TableCellRect.fromLTRB(0, 1, 0, 0),
          ));
          removeCells.add(_metrics.intersect(
            Rect.fromLTRB(overlap.right, _viewport.top, _viewport.right, _viewport.bottom),
            deflate: const TableCellRect.fromLTRB(1, 0, 0, 0),
          ));
        } else {
          removeCells.add(allCells);
        }
      }
      buildCells.add(_metrics.intersect(viewport));
    } else {
      assert(_viewport != null);
      final Rect viewport = constraints.viewport;
      if (viewport.overlaps(_viewport)) {
        final Rect overlap = viewport.intersect(_viewport);
        removeCells.add(_metrics.intersect(
          Rect.fromLTRB(_viewport.left, _viewport.top, overlap.left, _viewport.bottom),
          deflate: const TableCellRect.fromLTRB(0, 0, 1, 0),
        ));
        removeCells.add(_metrics.intersect(
          Rect.fromLTRB(overlap.left, _viewport.top, overlap.right, overlap.top),
          deflate: const TableCellRect.fromLTRB(0, 0, 0, 1),
        ));
        removeCells.add(_metrics.intersect(
          Rect.fromLTRB(overlap.left, overlap.bottom, overlap.right, _viewport.bottom),
          deflate: const TableCellRect.fromLTRB(0, 1, 0, 0),
        ));
        removeCells.add(_metrics.intersect(
          Rect.fromLTRB(overlap.right, _viewport.top, _viewport.right, _viewport.bottom),
          deflate: const TableCellRect.fromLTRB(1, 0, 0, 0),
        ));
        for (Rect rect in <Rect>[
          Rect.fromLTRB(viewport.left, viewport.top, overlap.left, viewport.bottom),
          Rect.fromLTRB(overlap.left, viewport.top, overlap.right, overlap.top),
          Rect.fromLTRB(overlap.left, overlap.bottom, overlap.right, viewport.bottom),
          Rect.fromLTRB(overlap.right, viewport.top, viewport.right, viewport.bottom),
        ]) {
          buildCells.add(skipAlreadyBuilt(_metrics.intersect(rect)));
        }
      } else {
        removeCells.add(allCells);
        buildCells.add(_metrics.intersect(viewport));
      }
    }

    _viewport = constraints.viewport;
    invokeLayoutCallback<SegmentConstraints>((SegmentConstraints _) {
      _layoutCallback(
        visitChildrenToRemove: removeCells.visitCells,
        visitChildrenToBuild: buildCells.visitCells,
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
      if (child != null) {
        result.add(child.toDiagnosticsNode(name: 'child $rowIndex,$columnIndex'));
      }
    });
    return result;
  }
}

class _TableViewParentData extends BoxParentData {
  int _rowIndex;
  int get rowIndex => _rowIndex;
  set rowIndex(int value) {
    assert(value != null);
    _rowIndex = value;
  }

  int _columnIndex;
  int get columnIndex => _columnIndex;
  set columnIndex(int value) {
    assert(value != null);
    _columnIndex = value;
  }

  @override
  String toString() => '${super.toString()}, rowIndex=$rowIndex, columnIndex=$columnIndex';
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
class TableViewMetrics {
  const TableViewMetrics._(
    this.columns,
    this.constraints,
    this.rowHeight,
    this.columnWidth,
    this.columnLeft,
    this.columnRight,
    this.totalWidth,
  );

  /// The columns of the table view.
  ///
  /// Each column's [BasicTableColumn.width] specification is the source (when
  /// combined with [constraints]) of the resolved column widths in
  /// [columnWidth].
  final List<BasicTableColumn> columns;

  /// The [BoxConstraints] against which the width specifications of the
  /// [columns] was resolved.
  final BoxConstraints constraints;

  /// The fixed row height of each row in the table view.
  final double rowHeight;

  /// The widths of the columns in the table view.
  ///
  /// The width values in this list correspond to the [columns] list.
  final List<double> columnWidth;

  /// The left-side x-values of the columns in the table view.
  ///
  /// The values in this list correspond to the [columns] list.
  final List<double> columnLeft;

  /// The right-side x-values of the columns in the table view.
  ///
  /// The values in this list correspond to the [columns] list.
  final List<double> columnRight;

  /// The total column width of the table view.
  final double totalWidth;

  static TableViewMetrics of(List<BasicTableColumn> columns, double rowHeight, BoxConstraints constraints) {
    assert(constraints.runtimeType == BoxConstraints);
    double totalFlexWidth = 0;
    double totalFixedWidth = 0;
    double totalWidth = 0;
    final List<double> resolvedWidths = List<double>.filled(columns.length, 0);
    final Map<int, BasicTableColumn> flexColumns = <int, BasicTableColumn>{};

    // Reserve space for the fixed-width columns first.
    for (int i = 0; i < columns.length; i++) {
      final BasicTableColumn column = columns[i];
      if (column.width.isFlex) {
        final FlexTableColumnWidth widthSpecification = column.width;
        totalFlexWidth += widthSpecification.width;
        flexColumns[i] = column;
      } else {
        final double columnWidth = column.width.width;
        totalFixedWidth += columnWidth;
        resolvedWidths[i] = columnWidth;
      }
    }

    double maxWidthDelta = constraints.maxWidth - totalFixedWidth;
    if (maxWidthDelta.isNegative) {
      // The fixed-width columns have already exceeded the maxWidth constraint;
      // truncate trailing column widths until we meet the constraint.
      totalWidth = constraints.maxWidth;
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
            exception: 'TableView column width adjustment was unable to satisfy the maxWidth constraint',
            stack: StackTrace.current,
            library: 'payouts',
          ));
        }
        return true;
      }());
    } else {
      // There's still width to spare after fixed-width column allocations.
      double flexAllocation = 0;
      if (maxWidthDelta.isFinite) {
        flexAllocation = maxWidthDelta;
      } else if (totalFixedWidth < constraints.minWidth) {
        flexAllocation = constraints.minWidth - totalFixedWidth;
      }
      totalWidth = totalFixedWidth + flexAllocation;
      if (flexAllocation > 0) {
        for (MapEntry<int, BasicTableColumn> flexColumn in flexColumns.entries) {
          final FlexTableColumnWidth widthSpecification = flexColumn.value.width;
          final double allocationPercentage = widthSpecification.width / totalFlexWidth;
          resolvedWidths[flexColumn.key] = flexAllocation * allocationPercentage;
        }
      }
    }

    final List<double> leftBounds = List<double>.filled(columns.length, 0);
    final List<double> rightBounds = List<double>.filled(columns.length, 0);
    double left = 0;
    for (int i = 0; i < columns.length; i++) {
      final double width = resolvedWidths[i];
      leftBounds[i] = left;
      rightBounds[i] = left + width;
      left += width;
    }

    return TableViewMetrics._(
      columns,
      constraints,
      rowHeight,
      resolvedWidths,
      leftBounds,
      rightBounds,
      totalWidth,
    );
  }

  TableCellRange intersect(
    Rect rect, {
    TableCellRect deflate = const TableCellRect.fromLTRB(0, 0, 0, 0),
  }) {
    if (rect.isEmpty) {
      return EmptyTableCellRange();
    }
    int leftIndex = columnRight.indexWhere((double right) => right > rect.left);
    int rightIndex = columnLeft.lastIndexWhere((double left) => left < rect.right);
    if (leftIndex == -1 || rightIndex == -1) {
      return EmptyTableCellRange();
    } else {
      int bottomIndex = rect.bottom ~/ rowHeight;
      if (rect.bottom.remainder(rowHeight) == 0) {
        bottomIndex -= 1;
      }
      final TableCellRect intersection = TableCellRect.fromLTRB(
        leftIndex,
        rect.top ~/ rowHeight,
        rightIndex,
        bottomIndex,
      );
      return intersection.deflate(deflate);
    }
  }
}
