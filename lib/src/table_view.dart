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

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' hide TableColumnWidth;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide ScrollController, TableColumnWidth;

import 'basic_table_view.dart';
import 'foundation.dart';
import 'listener_list.dart';
import 'navigator_listener.dart';
import 'scroll_pane.dart';
import 'sorting.dart';
import 'span.dart';

const double _kResizeHandleTargetPixels = 10; // logical

/// Signature for a function that renders headers in a [ScrollableTableView].
///
/// Header renderers are properties of the [TableColumnController], so each
/// column specifies the renderer for that column's header.
///
/// See also:
///  * [TableCellRenderer], which renders table body cells.
typedef TableHeaderRenderer = Widget Function({
  BuildContext context,
  int columnIndex,
});

/// Signature for a function that renders cells in a [ScrollableTableView].
///
/// Cell renderers are properties of the [TableColumnController], so each
/// column specifies the cell renderer for cells in that column.
///
/// The `rowSelected` argument specifies whether the row is currently selected,
/// as indicated by the [TableViewSelectionController] that's associated with
/// the table view.
///
/// The `rowHighlighted` argument specifies whether the row is highlighted,
/// typically because the table view allows selection of rows, and a mouse
/// cursor is currently hovering over the row.
///
/// The `isEditing` argument specifies whether row editing is currently active
/// on the specified cell.
///
/// See also:
///  * [TableHeaderRenderer], which renders a column's header.
///  * [TableViewSelectionController.selectMode], which dictates whether rows
///    are eligible to become highlighted.
///  * [BasicTableCellRenderer], the equivalent cell renderer for a
///    [BasicTableView].
typedef TableCellRenderer = Widget Function({
  BuildContext context,
  int rowIndex,
  int columnIndex,
  bool rowSelected,
  bool rowHighlighted,
  bool isEditing,
  bool isRowDisabled,
});

typedef PreviewTableViewEditStartedHandler = Vote Function(
  TableViewEditorController controller,
  int rowIndex,
  int columnIndex,
);

typedef TableViewEditStartedHandler = void Function(
  TableViewEditorController controller,
);

typedef PreviewTableViewEditFinishedHandler = Vote Function(
  TableViewEditorController controller,
);

typedef TableViewEditFinishedHandler = void Function(
  TableViewEditorController controller,
  TableViewEditOutcome outcome,
);

@immutable
class TableViewEditorListener {
  const TableViewEditorListener({
    this.onPreviewEditStarted = _defaultOnPreviewEditStarted,
    this.onEditStarted = _defaultOnEditStarted,
    this.onPreviewEditFinished = _defaultOnPreviewEditFinished,
    this.onEditFinished = _defaultOnEditFinished,
  });

  final PreviewTableViewEditStartedHandler onPreviewEditStarted;
  final TableViewEditStartedHandler onEditStarted;
  final PreviewTableViewEditFinishedHandler onPreviewEditFinished;
  final TableViewEditFinishedHandler onEditFinished;

  static Vote _defaultOnPreviewEditStarted(TableViewEditorController _, int __, int ___) {
    return Vote.approve;
  }

  static void _defaultOnEditStarted(TableViewEditorController _) {
    // No-op
  }

  static Vote _defaultOnPreviewEditFinished(TableViewEditorController _) {
    return Vote.approve;
  }

  static void _defaultOnEditFinished(TableViewEditorController _, TableViewEditOutcome __) {
    // No-op
  }
}

enum TableViewEditorBehavior {
  /// When initiating an edit of a table cell via
  /// [TableViewEditorController.beginEditing], re-render all cells in the row,
  /// and set the `isEditing` [TableCellRenderer] flag to true for all cells in
  /// the row.
  wholeRow,

  /// When initiating an edit of a table cell via
  /// [TableViewEditorController.beginEditing], re-render only the requested
  /// cell, and set the `isEditing` [TableCellRenderer] flag to true for only
  /// that cell and not any other cells in the row.
  singleCell,

  /// Disable table cell editing.
  ///
  /// This can also be accomplished by setting no [TableViewEditorController]
  /// on the [TableView].
  none,
}

enum TableViewEditOutcome {
  saved,

  canceled,
}

class TableViewEditorController with ListenerNotifier<TableViewEditorListener> {
  TableViewEditorController({
    this.behavior = TableViewEditorBehavior.wholeRow,
  });

  /// The editing behavior when an edit begins via [beginEditing].
  final TableViewEditorBehavior behavior;

  /// True if this controller is associated with a table view.
  ///
  /// A controller may only be associated with one table view at a time.
  RenderTableView _renderObject;
  bool get isAttached => _renderObject != null;

  void _attach(RenderTableView renderObject) {
    assert(renderObject != null);
    assert(!isAttached);
    _renderObject = renderObject;
  }

  void _detach() {
    assert(isAttached);
    _renderObject = null;
  }

  int _rowIndex;
  int _columnIndex;

  TableCellRange get cellsBeingEdited {
    assert(isEditing);
    assert(isAttached);
    switch (behavior) {
      case TableViewEditorBehavior.singleCell:
        return SingleCellRange(_rowIndex, _columnIndex);
        break;
      case TableViewEditorBehavior.wholeRow:
        return TableCellRect.fromLTRB(0, _rowIndex, _renderObject.columns.length - 1, _rowIndex);
        break;
      case TableViewEditorBehavior.none:
        assert(false);
        break;
    }
    throw StateError('Unreachable');
  }

  /// True if an edit is currently in progress.
  ///
  /// If this is true, [editRowIndex] will be non-null.
  bool get isEditing {
    assert((_rowIndex == null) == (_columnIndex == null));
    return _rowIndex != null;
  }

  bool isEditingCell(int rowIndex, int columnIndex) {
    if (behavior == TableViewEditorBehavior.none) {
      return false;
    }
    bool result = rowIndex == _rowIndex;
    if (result && behavior == TableViewEditorBehavior.singleCell) {
      result &= columnIndex == _columnIndex;
    }
    return result;
  }

  bool start(int rowIndex, int columnIndex) {
    assert(!isEditing);
    assert(isAttached);
    assert(rowIndex != null);
    assert(columnIndex != null);
    assert(rowIndex >= 0 && rowIndex < _renderObject.length);
    assert(columnIndex >= 0 && columnIndex < _renderObject.columns.length);
    assert(behavior != TableViewEditorBehavior.none);

    Vote vote = Vote.approve;
    notifyListeners((TableViewEditorListener listener) {
      vote = vote.tally(listener.onPreviewEditStarted(this, rowIndex, columnIndex));
    });

    if (vote == Vote.approve) {
      _rowIndex = rowIndex;
      _columnIndex = columnIndex;
      notifyListeners((TableViewEditorListener listener) {
        listener.onEditStarted(this);
      });
      return true;
    } else {
      return false;
    }
  }

  bool save() {
    assert(isEditing);
    assert(isAttached);

    Vote vote = Vote.approve;
    notifyListeners((TableViewEditorListener listener) {
      vote = vote.tally(listener.onPreviewEditFinished(this));
    });

    if (vote == Vote.approve) {
      _rowIndex = null;
      _columnIndex = null;
      notifyListeners((TableViewEditorListener listener) {
        listener.onEditFinished(this, TableViewEditOutcome.saved);
      });
      return true;
    } else {
      return false;
    }
  }

  void cancel() {
    assert(isEditing);
    assert(isAttached);
    _rowIndex = null;
    _columnIndex = null;
    notifyListeners((TableViewEditorListener listener) {
      listener.onEditFinished(this, TableViewEditOutcome.canceled);
    });
  }
}

/// Controls the properties of a column in a [ScrollableTableView].
///
/// Mutable properties such as [width] and [sortDirection] will notify
/// listeners when changed.
class TableColumnController extends BasicTableColumn with ChangeNotifier {
  TableColumnController({
    @required this.key,
    @required TableCellRenderer cellRenderer,
    this.headerRenderer,
    TableColumnWidth width = const FlexTableColumnWidth(),
  })  : assert(key != null),
        assert(cellRenderer != null),
        assert(width != null),
        _width = width,
        super(cellRenderer: cellRenderer);

  /// A unique identifier for this column.
  ///
  /// This is the key by which we sort columns in [TableViewSortController].
  final String key;

  /// The renderer responsible for the look & feel of the header for this column.
  ///
  /// See also:
  ///
  ///  * [ScrollableTableView.includeHeader], which if false will allow for
  ///    this field to be null.
  final TableHeaderRenderer headerRenderer;

  @override
  TableCellRenderer get cellRenderer => super.cellRenderer as TableCellRenderer;

  TableColumnWidth _width;

  /// The width specification for the column.
  ///
  /// Instances of [ConstrainedTableColumnWidth] will cause a column to become
  /// resizable.
  ///
  /// Changing this value will notify listeners.
  @override
  TableColumnWidth get width => _width;
  set width(TableColumnWidth value) {
    assert(value != null);
    if (value == _width) return;
    _width = value;
    notifyListeners();
  }

  @override
  int get hashCode => hashValues(super.hashCode, headerRenderer);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return super == other &&
        other is TableColumnController &&
        headerRenderer == other.headerRenderer;
  }
}

enum SelectMode {
  none,
  single,
  multi,
}

class TableViewSelectionController with ChangeNotifier {
  TableViewSelectionController({
    this.selectMode = SelectMode.single,
  }) : assert(selectMode != null);

  /// TODO: document
  final SelectMode selectMode;

  ListSelection _selectedRanges = ListSelection();
  RenderTableView _renderObject;

  /// True if this controller is associated with a table view.
  ///
  /// A selection controller may only be associated with one table view at a
  /// time.
  bool get isAttached => _renderObject != null;

  void _attach(RenderTableView renderObject) {
    assert(!isAttached);
    _renderObject = renderObject;
  }

  void _detach() {
    assert(isAttached);
    _renderObject = null;
  }

  /// TODO: document
  int get selectedIndex {
    assert(selectMode == SelectMode.single);
    return _selectedRanges.isEmpty ? -1 : _selectedRanges[0].start;
  }

  set selectedIndex(int index) {
    if (index == -1) {
      clearSelection();
    } else {
      selectedRange = Span.single(index);
    }
  }

  /// TODO: document
  Span get selectedRange {
    assert(_selectedRanges.length <= 1);
    return _selectedRanges.isEmpty ? null : _selectedRanges[0];
  }

  set selectedRange(Span range) {
    selectedRanges = <Span>[range];
  }

  /// TODO: document
  Iterable<Span> get selectedRanges {
    return _selectedRanges.data;
  }

  set selectedRanges(Iterable<Span> ranges) {
    assert(ranges != null);
    assert(selectMode != SelectMode.none, 'Selection is not enabled');
    assert(() {
      if (selectMode == SelectMode.single) {
        if (ranges.length > 1) {
          return false;
        }
        if (ranges.isNotEmpty) {
          final Span range = ranges.single;
          if (range.length > 1) {
            return false;
          }
        }
      }
      return true;
    }());

    final ListSelection selectedRanges = ListSelection();
    for (Span range in ranges) {
      assert(range != null);
      assert(range.start >= 0 && (!isAttached || range.end < _renderObject.length));
      selectedRanges.addRange(range.start, range.end);
    }
    _selectedRanges = selectedRanges;
    notifyListeners();
  }

  int get firstSelectedIndex => _selectedRanges.isNotEmpty ? _selectedRanges.first.start : -1;

  int get lastSelectedIndex => _selectedRanges.isNotEmpty ? _selectedRanges.last.end : -1;

  bool addSelectedIndex(int index) {
    final List<Span> addedRanges = addSelectedRange(index, index);
    return addedRanges.isNotEmpty;
  }

  List<Span> addSelectedRange(int start, int end) {
    assert(selectMode == SelectMode.multi);
    assert(start >= 0 && (!isAttached || end < _renderObject.length));
    final List<Span> addedRanges = _selectedRanges.addRange(start, end);
    notifyListeners();
    return addedRanges;
  }

  bool removeSelectedIndex(int index) {
    List<Span> removedRanges = removeSelectedRange(index, index);
    return removedRanges.isNotEmpty;
  }

  List<Span> removeSelectedRange(int start, int end) {
    assert(selectMode == SelectMode.multi);
    assert(start >= 0 && (!isAttached || end < _renderObject.length));
    final List<Span> removedRanges = _selectedRanges.removeRange(start, end);
    notifyListeners();
    return removedRanges;
  }

  void selectAll() {
    assert(isAttached);
    selectedRange = Span(0, _renderObject.length - 1);
  }

  void clearSelection() {
    if (_selectedRanges.isNotEmpty) {
      _selectedRanges = ListSelection();
      notifyListeners();
    }
  }

  bool isRowSelected(int rowIndex) {
    assert(rowIndex >= 0 && isAttached && rowIndex < _renderObject.length);
    return _selectedRanges.containsIndex(rowIndex);
  }
}

enum TableViewSortMode {
  none,
  singleColumn,
  multiColumn,
}

typedef TableViewSortAddedHandler = void Function(
  TableViewSortController controller,
  String key,
);

typedef TableViewSortUpdatedHandler = void Function(
  TableViewSortController controller,
  String key,
  SortDirection previousSortDirection,
);

typedef TableViewSortChangedHandler = void Function(
  TableViewSortController controller,
);

class TableViewSortListener {
  const TableViewSortListener({
    this.onAdded = _defaultOnAdded,
    this.onUpdated = _defaultOnUpdated,
    this.onChanged = _defaultOnChanged,
  });

  final TableViewSortAddedHandler onAdded;
  final TableViewSortUpdatedHandler onUpdated;
  final TableViewSortChangedHandler onChanged;

  static void _defaultOnAdded(TableViewSortController _, String __) {}
  static void _defaultOnUpdated(TableViewSortController _, String __, SortDirection ___) {}
  static void _defaultOnChanged(TableViewSortController _) {}
}

class TableViewSortController with ListenerNotifier<TableViewSortListener> {
  TableViewSortController({this.sortMode = TableViewSortMode.none});

  final TableViewSortMode sortMode;
  final LinkedHashMap<String, SortDirection> _sortMap = LinkedHashMap<String, SortDirection>();

  SortDirection operator [](String columnKey) => _sortMap[columnKey];

  operator []=(String columnKey, SortDirection direction) {
    assert(sortMode != TableViewSortMode.none);
    final SortDirection previousDirection = _sortMap[columnKey];
    if (previousDirection == direction) {
      return;
    } else if (sortMode == TableViewSortMode.singleColumn) {
      final Map<String, SortDirection> newMap = <String, SortDirection>{};
      if (direction != null) {
        newMap[columnKey] = direction;
      }
      replaceAll(newMap);
    } else {
      if (direction == null) {
        remove(columnKey);
      } else {
        _sortMap[columnKey] = direction;
        if (previousDirection == null) {
          notifyListeners((TableViewSortListener listener) => listener.onAdded(this, columnKey));
        } else {
          notifyListeners((TableViewSortListener listener) {
            listener.onUpdated(this, columnKey, previousDirection);
          });
        }
      }
    }
  }

  SortDirection remove(String columnKey) {
    final SortDirection previousDirection = _sortMap.remove(columnKey);
    if (previousDirection != null) {
      notifyListeners((TableViewSortListener listener) {
        listener.onUpdated(this, columnKey, null);
      });
    }
    return previousDirection;
  }

  bool containsKey(String columnKey) => _sortMap.containsKey(columnKey);

  bool get isEmpty => _sortMap.isEmpty;

  int get length => _sortMap.length;

  Iterable<String> get keys => _sortMap.keys;

  void replaceAll(Map<String, SortDirection> map) {
    _sortMap.clear();
    for (String columnKey in map.keys) {
      _sortMap[columnKey] = map[columnKey];
    }
    notifyListeners((TableViewSortListener listener) => listener.onChanged(this));
  }
}

typedef TableViewRowDisabledFilterChangedHandler = void Function(Predicate<int> previousFilter);

class TableViewRowDisablerListener {
  const TableViewRowDisablerListener({
    @required this.onTableViewRowDisabledFilterChanged,
  });

  final TableViewRowDisabledFilterChangedHandler onTableViewRowDisabledFilterChanged;
}

class TableViewRowDisablerController with ListenerNotifier<TableViewRowDisablerListener> {
  TableViewRowDisablerController({Predicate<int> filter}) : _filter = filter;

  Predicate<int> _filter;
  Predicate<int> get filter => _filter;
  set filter(Predicate<int> value) {
    Predicate<int> previousValue = _filter;
    if (value != previousValue) {
      _filter = value;
      notifyListeners((TableViewRowDisablerListener listener) {
        if (listener.onTableViewRowDisabledFilterChanged != null) {
          listener.onTableViewRowDisabledFilterChanged(previousValue);
        }
      });
    }
  }

  bool isRowDisabled(int rowIndex) => filter != null && filter(rowIndex);
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

  @override
  int get hashCode => hashValues(super.hashCode, minWidth, maxWidth);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return super == other &&
        other is ConstrainedTableColumnWidth &&
        minWidth == other.minWidth &&
        maxWidth == other.maxWidth;
  }
}

class ScrollableTableView extends StatelessWidget {
  const ScrollableTableView({
    Key key,
    @required this.rowHeight,
    @required this.length,
    @required this.columns,
    this.metricsController,
    this.selectionController,
    this.sortController,
    this.editorController,
    this.rowDisabledController,
    this.scrollController,
    this.roundColumnWidthsToWholePixel = false,
    this.includeHeader = true,
  })  : assert(rowHeight != null),
        assert(length != null),
        assert(columns != null),
        assert(roundColumnWidthsToWholePixel != null),
        assert(includeHeader != null),
        super(key: key);

  final double rowHeight;
  final int length;
  final List<TableColumnController> columns;
  final TableViewMetricsController metricsController;
  final TableViewSelectionController selectionController;
  final TableViewSortController sortController;
  final TableViewEditorController editorController;
  final TableViewRowDisablerController rowDisabledController;
  final ScrollController scrollController;
  final bool roundColumnWidthsToWholePixel;
  final bool includeHeader;

  @override
  Widget build(BuildContext context) {
    Widget columnHeader;
    if (includeHeader) {
      columnHeader = TableViewHeader(
        rowHeight: rowHeight,
        columns: columns,
        sortController: sortController,
        roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
      );
    }

    return ScrollPane(
      horizontalScrollBarPolicy: ScrollBarPolicy.expand,
      verticalScrollBarPolicy: ScrollBarPolicy.auto,
      scrollController: scrollController,
      columnHeader: columnHeader,
      view: TableView(
        length: length,
        rowHeight: rowHeight,
        columns: columns,
        roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
        metricsController: metricsController,
        selectionController: selectionController,
        sortController: sortController,
        editorController: editorController,
        rowDisabledController: rowDisabledController,
      ),
    );
  }
}

class TableView extends StatefulWidget {
  const TableView({
    Key key,
    @required this.rowHeight,
    @required this.length,
    @required this.columns,
    this.metricsController,
    this.selectionController,
    this.editorController,
    this.sortController,
    this.rowDisabledController,
    this.roundColumnWidthsToWholePixel = false,
    this.platform,
  })  : assert(rowHeight != null),
        assert(length != null),
        assert(columns != null),
        assert(roundColumnWidthsToWholePixel != null),
        super(key: key);

  final double rowHeight;
  final int length;
  final List<TableColumnController> columns;
  final TableViewMetricsController metricsController;
  final TableViewSelectionController selectionController;
  final TableViewEditorController editorController;
  final TableViewSortController sortController;
  final TableViewRowDisablerController rowDisabledController;
  final bool roundColumnWidthsToWholePixel;
  final TargetPlatform platform;

  @override
  _TableViewState createState() => _TableViewState();
}

typedef ObserveNavigator = NavigatorListenerRegistration Function({
  NavigatorObserverCallback onPushed,
  NavigatorObserverCallback onPopped,
  NavigatorObserverCallback onRemoved,
  NavigatorObserverCallback onReplaced,
  NavigatorObserverCallback onStartUserGesture,
  VoidCallback onStopUserGesture,
});

class _TableViewState extends State<TableView> {
  StreamController<PointerEvent> _pointerEvents;
  StreamController<Offset> _doubleTapEvents;
  Offset _doubleTapPosition;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    _doubleTapEvents.add(_doubleTapPosition);
  }

  @override
  void initState() {
    super.initState();
    _pointerEvents = StreamController<PointerEvent>();
    _doubleTapEvents = StreamController<Offset>();
  }

  @override
  void dispose() {
    _pointerEvents.close();
    _doubleTapEvents.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = RawTableView(
      rowHeight: widget.rowHeight,
      length: widget.length,
      columns: widget.columns,
      metricsController: widget.metricsController,
      selectionController: widget.selectionController,
      sortController: widget.sortController,
      editorController: widget.editorController,
      rowDisabledController: widget.rowDisabledController,
      roundColumnWidthsToWholePixel: widget.roundColumnWidthsToWholePixel,
      pointerEvents: _pointerEvents.stream,
      doubleTapEvents: _doubleTapEvents.stream,
      platform: widget.platform ?? defaultTargetPlatform,
    );

    if (widget.selectionController != null &&
        widget.selectionController.selectMode != SelectMode.none) {
      result = MouseRegion(
        onEnter: _pointerEvents.add,
        onExit: _pointerEvents.add,
        onHover: _pointerEvents.add,
        child: result,
      );
    }

    if (widget.editorController != null &&
        widget.editorController.behavior != TableViewEditorBehavior.none) {
      result = GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: result,
      );
    }

    return result;
  }
}

@visibleForTesting
class RawTableView extends BasicTableView {
  const RawTableView({
    Key key,
    @required double rowHeight,
    @required int length,
    @required List<TableColumnController> columns,
    bool roundColumnWidthsToWholePixel = false,
    TableViewMetricsController metricsController,
    this.selectionController,
    this.sortController,
    this.editorController,
    this.rowDisabledController,
    @required this.pointerEvents,
    @required this.doubleTapEvents,
    @required this.platform,
  })  : assert(platform != null),
        super(
          key: key,
          rowHeight: rowHeight,
          length: length,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
          metricsController: metricsController,
        );

  final TableViewSelectionController selectionController;
  final TableViewSortController sortController;
  final TableViewEditorController editorController;
  final TableViewRowDisablerController rowDisabledController;
  final Stream<PointerEvent> pointerEvents;
  final Stream<Offset> doubleTapEvents;
  final TargetPlatform platform;

  @override
  List<TableColumnController> get columns => super.columns as List<TableColumnController>;

  @override
  BasicTableViewElement createElement() => TableViewElement(this);

  @override
  RenderTableView createRenderObject(BuildContext context) {
    return RenderTableView(
      rowHeight: rowHeight,
      length: length,
      columns: columns,
      roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
      metricsController: metricsController,
      selectionController: selectionController,
      sortController: sortController,
      editorController: editorController,
      rowDisabledController: rowDisabledController,
      pointerEvents: pointerEvents,
      doubleTapEvents: doubleTapEvents,
      platform: platform,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTableView renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..selectionController = selectionController
      ..sortController = sortController
      ..editorController = editorController
      ..rowDisabledController = rowDisabledController
      ..pointerEvents = pointerEvents
      ..doubleTapEvents = doubleTapEvents
      ..platform = platform;
  }
}

@visibleForTesting
class TableViewElement extends BasicTableViewElement {
  TableViewElement(RawTableView tableView) : super(tableView);

  @override
  RawTableView get widget => super.widget as RawTableView;

  @override
  RenderTableView get renderObject => super.renderObject as RenderTableView;

  @override
  @protected
  Widget renderCell(covariant TableColumnController column, int rowIndex, int columnIndex) {
    assert(column.cellRenderer is TableCellRenderer);
    return column.cellRenderer(
      context: this,
      rowIndex: rowIndex,
      columnIndex: columnIndex,
      rowHighlighted: renderObject.highlightedRow == rowIndex,
      rowSelected: widget.selectionController?.isRowSelected(rowIndex) ?? false,
      isEditing: widget.editorController?.isEditingCell(rowIndex, columnIndex) ?? false,
      isRowDisabled: widget.rowDisabledController?.isRowDisabled(rowIndex) ?? false,
    );
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    renderObject.updateObserveNavigatorCallback(_observeNavigator);
  }

  NavigatorListenerRegistration _observeNavigator({
    NavigatorObserverCallback onPushed,
    NavigatorObserverCallback onPopped,
    NavigatorObserverCallback onRemoved,
    NavigatorObserverCallback onReplaced,
    NavigatorObserverCallback onStartUserGesture,
    VoidCallback onStopUserGesture,
  }) {
    return NavigatorListener.of(this).addObserver(
      onPushed: onPushed,
      onPopped: onPopped,
      onRemoved: onRemoved,
      onReplaced: onReplaced,
      onStartUserGesture: onStartUserGesture,
      onStopUserGesture: onStopUserGesture,
    );
  }
}

@visibleForTesting
class RenderTableView extends RenderBasicTableView
    with TableViewColumnListenerMixin, TableViewSortingMixin {
  RenderTableView({
    double rowHeight,
    int length,
    List<TableColumnController> columns,
    bool roundColumnWidthsToWholePixel = false,
    TableViewMetricsController metricsController,
    TableViewSelectionController selectionController,
    TableViewSortController sortController,
    TableViewEditorController editorController,
    TableViewRowDisablerController rowDisabledController,
    Stream<PointerEvent> pointerEvents,
    Stream<Offset> doubleTapEvents,
    TargetPlatform platform,
  }) : super(
          rowHeight: rowHeight,
          length: length,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
          metricsController: metricsController,
        ) {
    initializeSortListener();
    _editorListener = TableViewEditorListener(
      onEditStarted: _handleEditStarted,
      onEditFinished: _handleEditFinished,
    );
    _rowDisablerListener = TableViewRowDisablerListener(
      onTableViewRowDisabledFilterChanged: _handleRowDisabledFilterChanged,
    );
    this.selectionController = selectionController;
    this.sortController = sortController;
    this.editorController = editorController;
    this.rowDisabledController = rowDisabledController;
    this.pointerEvents = pointerEvents;
    this.doubleTapEvents = doubleTapEvents;
    this.platform = platform;
  }

  TableViewEditorListener _editorListener;
  TableViewRowDisablerListener _rowDisablerListener;

  Set<int> _sortedColumns = <int>{};
  void _resetSortedColumns() {
    _sortedColumns.clear();
    if (sortController != null) {
      for (int i = 0; i < columns.length; i++) {
        if (sortController[columns[i].key] != null) {
          _sortedColumns.add(i);
        }
      }
    }
  }

  void _cancelEditIfNecessary() {
    if (_editorController != null && _editorController.isEditing) {
      _editorController.cancel();
    }
  }

  @override
  set length(int value) {
    int previousValue = length;
    super.length = value;
    if (length != previousValue) {
      _cancelEditIfNecessary();
    }
  }

  @override
  set columns(List<TableColumnController> value) {
    List<TableColumnController> previousValue = columns;
    super.columns = value;
    if (columns != previousValue) {
      _cancelEditIfNecessary();
    }
  }

  @override
  set sortController(TableViewSortController value) {
    TableViewSortController previousValue = sortController;
    super.sortController = value;
    if (sortController != previousValue) {
      _resetSortedColumns();
      _cancelEditIfNecessary();
    }
  }

  TableViewSelectionController _selectionController;
  TableViewSelectionController get selectionController => _selectionController;
  set selectionController(TableViewSelectionController value) {
    if (_selectionController == value) return;
    if (_selectionController != null) {
      if (attached) {
        _selectionController._detach();
      }
      _selectionController.removeListener(_handleSelectionChanged);
    }
    _selectionController = value;
    if (_selectionController != null) {
      if (attached) {
        _selectionController._attach(this);
      }
      _selectionController.addListener(_handleSelectionChanged);
    }
    markNeedsBuild();
  }

  TableViewEditorController _editorController;
  TableViewEditorController get editorController => _editorController;
  set editorController(TableViewEditorController value) {
    if (_editorController == value) return;
    if (_editorController != null) {
      _cancelEditIfNecessary();
      if (attached) {
        _editorController._detach();
      }
      _editorController.removeListener(_editorListener);
    }
    _editorController = value;
    if (_editorController != null) {
      if (attached) {
        _editorController._attach(this);
      }
      _editorController.addListener(_editorListener);
    }
    markNeedsBuild();
  }

  TableViewRowDisablerController _rowDisabledController;
  TableViewRowDisablerController get rowDisabledController => _rowDisabledController;
  set rowDisabledController(TableViewRowDisablerController value) {
    if (value != _rowDisabledController) {
      _cancelEditIfNecessary();
      if (_rowDisabledController != null) {
        _rowDisabledController.removeListener(_rowDisablerListener);
      }
      _rowDisabledController = value;
      if (_rowDisabledController != null) {
        _rowDisabledController.addListener(_rowDisablerListener);
      }
      markNeedsBuild();
    }
  }

  bool _isRowDisabled(int rowIndex) => _rowDisabledController?.isRowDisabled(rowIndex) ?? false;

  ObserveNavigator _observeNavigator;

  @protected
  void updateObserveNavigatorCallback(ObserveNavigator callback) {
    _observeNavigator = callback;
    _cancelEditIfNecessary();
  }

  StreamSubscription<PointerEvent> _pointerEventsSubscription;
  Stream<PointerEvent> _pointerEvents;
  Stream<PointerEvent> get pointerEvents => _pointerEvents;
  set pointerEvents(Stream<PointerEvent> value) {
    assert(value != null);
    if (_pointerEvents == value) return;
    if (_pointerEventsSubscription != null) {
      assert(_pointerEvents != null);
      _pointerEventsSubscription.cancel();
      _pointerEventsSubscription = null;
    }
    _pointerEvents = value;
    _pointerEventsSubscription = _pointerEvents.listen(_onPointerEvent);
  }

  StreamSubscription<Offset> _doubleTapEventsSubscription;
  Stream<Offset> _doubleTapEvents;
  Stream<Offset> get doubleTapEvents => _doubleTapEvents;
  set doubleTapEvents(Stream<Offset> value) {
    assert(value != null);
    if (_doubleTapEvents == value) return;
    if (_doubleTapEventsSubscription != null) {
      assert(_doubleTapEvents != null);
      _doubleTapEventsSubscription.cancel();
      _doubleTapEventsSubscription = null;
    }
    _doubleTapEvents = value;
    _doubleTapEventsSubscription = _doubleTapEvents.listen(_onDoubleTap);
  }

  TargetPlatform _platform;
  TargetPlatform get platform => _platform;
  set platform(TargetPlatform value) {
    assert(value != null);
    if (value == _platform) return;
    _platform = value;
  }

  int _highlightedRow;
  int get highlightedRow => _highlightedRow;
  set highlightedRow(int value) {
    if (_highlightedRow == value) return;
    final int previousValue = _highlightedRow;
    _highlightedRow = value;
    final UnionTableCellRange dirtyCells = UnionTableCellRange();
    if (previousValue != null) {
      dirtyCells.add(TableCellRect.fromLTRB(0, previousValue, columns.length - 1, previousValue));
    }
    if (value != null) {
      dirtyCells.add(TableCellRect.fromLTRB(0, value, columns.length - 1, value));
    }
    markCellsDirty(dirtyCells);
  }

  /// Local cache of the cells being edited, so that we know which cells to
  /// mark dirty when the edit finishes.
  TableCellRange _cellsBeingEdited;

  NavigatorListenerRegistration _navigatorListenerRegistration;
  int _routesPushedDuringEdit = 0;

  void _handleEditStarted(TableViewEditorController controller) {
    assert(controller == _editorController);
    assert(_cellsBeingEdited == null);
    assert(_observeNavigator != null);
    assert(_navigatorListenerRegistration == null);
    _cellsBeingEdited = _editorController.cellsBeingEdited;
    markCellsDirty(_cellsBeingEdited);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointerEvent);
    _navigatorListenerRegistration = _observeNavigator(
      onPushed: _handleRoutePushedDuringEditing,
      onPopped: _handleRoutePoppedDuringEditing,
    );
  }

  void _handleRoutePushedDuringEditing(Route<dynamic> route, Route<dynamic> previousRoute) {
    assert(_routesPushedDuringEdit >= 0);
    if (_routesPushedDuringEdit++ == 0) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_handleGlobalPointerEvent);
    }
  }

  void _handleRoutePoppedDuringEditing(Route<dynamic> route, Route<dynamic> previousRoute) {
    assert(_navigatorListenerRegistration != null);
    assert(_routesPushedDuringEdit > 0);
    if (--_routesPushedDuringEdit == 0) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointerEvent);
    }
  }

  void _handleGlobalPointerEvent(PointerEvent event) {
    assert(_editorController != null);
    assert(_editorController.isEditing);
    assert(_cellsBeingEdited != null);
    if (event is PointerDownEvent) {
      final Offset localPosition = globalToLocal(event.position);
      final TableCellOffset cellOffset = metrics.getCellAt(localPosition);
      if (cellOffset == null || !_editorController.cellsBeingEdited.containsCell(cellOffset)) {
        _editorController.save();
      }
    }
  }

  void _handleEditFinished(TableViewEditorController controller, TableViewEditOutcome outcome) {
    assert(controller == _editorController);
    assert(_cellsBeingEdited != null);
    assert(_navigatorListenerRegistration != null);
    _navigatorListenerRegistration.dispose();
    _navigatorListenerRegistration = null;
    markCellsDirty(_cellsBeingEdited);
    _cellsBeingEdited = null;
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handleGlobalPointerEvent);
  }

  void _handleRowDisabledFilterChanged(Predicate<int> previousFilter) {
    _cancelEditIfNecessary();
    markNeedsBuild();
  }

  void _handleSelectionChanged() {
    // TODO: be more precise about what to rebuild (requires finer grained info from the notification).
    markNeedsBuild();
  }

  @override
  @protected
  void handleSortAdded(TableViewSortController controller, String key) {
    final int columnIndex = columns.indexWhere((TableColumnController column) => column.key == key);
    _sortedColumns.add(columnIndex);
    markNeedsBuild();
  }

  @override
  @protected
  void handleSortUpdated(TableViewSortController controller, String key, SortDirection direction) {
    final int columnIndex = columns.indexWhere((TableColumnController column) => column.key == key);
    if (direction == null) {
      _sortedColumns.remove(columnIndex);
    } else {
      _sortedColumns.add(columnIndex);
    }
    markNeedsBuild();
  }

  @override
  @protected
  void handleSortChanged(TableViewSortController controller) {
    _resetSortedColumns();
    markNeedsBuild();
  }

  void _onDoubleTap(Offset position) {
    if (_editorController != null) {
      assert(metrics != null);
      final TableCellOffset cellOffset = metrics.getCellAt(position);
      if (cellOffset != null && !_isRowDisabled(cellOffset.rowIndex)) {
        _editorController.start(cellOffset.rowIndex, cellOffset.columnIndex);
      }
    }
  }

  void _onPointerExit(PointerExitEvent event) {
    highlightedRow = null;
  }

  void _onPointerScroll(PointerScrollEvent event) {
    if (event.scrollDelta != Offset.zero) {
      highlightedRow = null;
    }
  }

  void _onPointerHover(PointerHoverEvent event) {
    final int rowIndex = metrics.getRowAt(event.localPosition.dy);
    highlightedRow = rowIndex != -1 && !_isRowDisabled(rowIndex) ? rowIndex : null;
  }

  int _selectIndex = -1;

  void _onPointerDown(PointerDownEvent event) {
    final SelectMode selectMode = selectionController?.selectMode ?? SelectMode.none;
    if (selectMode != SelectMode.none) {
      final int rowIndex = metrics.getRowAt(event.localPosition.dy);
      if (rowIndex >= 0 && rowIndex < length && !_isRowDisabled(rowIndex)) {
        final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;

        if (isShiftKeyPressed() && selectMode == SelectMode.multi) {
          final int startIndex = selectionController.firstSelectedIndex;
          if (startIndex == -1) {
            selectionController.addSelectedIndex(rowIndex);
          } else {
            final int endIndex = selectionController.lastSelectedIndex;
            final Span range = Span(rowIndex, rowIndex > startIndex ? startIndex : endIndex);
            selectionController.selectedRange = range;
          }
        } else if (isPlatformCommandKeyPressed(platform) && selectMode == SelectMode.multi) {
          if (selectionController.isRowSelected(rowIndex)) {
            selectionController.removeSelectedIndex(rowIndex);
          } else {
            selectionController.addSelectedIndex(rowIndex);
          }
        } else if (keys.contains(LogicalKeyboardKey.control) && selectMode == SelectMode.single) {
          if (selectionController.isRowSelected(rowIndex)) {
            selectionController.selectedIndex = -1;
          } else {
            selectionController.selectedIndex = rowIndex;
          }
        } else if (selectMode != SelectMode.none) {
          if (!selectionController.isRowSelected(rowIndex)) {
            selectionController.selectedIndex = rowIndex;
          }
          _selectIndex = rowIndex;
        }
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_selectIndex != -1 &&
        selectionController.firstSelectedIndex != selectionController.lastSelectedIndex) {
      selectionController.selectedIndex = _selectIndex;
    }
    _selectIndex = -1;
  }

  void _onPointerEvent(PointerEvent event) {
    if (event is PointerHoverEvent) return _onPointerHover(event);
    if (event is PointerScrollEvent) return _onPointerScroll(event);
    if (event is PointerExitEvent) return _onPointerExit(event);
    if (event is PointerDownEvent) return _onPointerDown(event);
    if (event is PointerUpEvent) return _onPointerUp(event);
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    _onPointerEvent(event);
    super.handleEvent(event, entry);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_selectionController != null) {
      _selectionController._attach(this);
    }
    if (_editorController != null) {
      _editorController._attach(this);
    }
  }

  @override
  void detach() {
    if (_selectionController != null) {
      _selectionController._detach();
    }
    if (_editorController != null) {
      _editorController._detach();
    }
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_sortedColumns.isNotEmpty) {
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xfff7f5ed);
      for (int columnIndex in _sortedColumns) {
        final Rect columnBounds = metrics.getColumnBounds(columnIndex);
        context.canvas.drawRect(columnBounds.shift(offset), paint);
      }
    }
    if (_highlightedRow != null) {
      final Rect rowBounds = metrics.getRowBounds(_highlightedRow);
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xffdddcd5);
      context.canvas.drawRect(rowBounds.shift(offset), paint);
    }
    if (selectionController != null && selectionController.selectedRanges.isNotEmpty) {
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xff14538b);
      for (Span range in selectionController.selectedRanges) {
        Rect bounds = metrics.getRowBounds(range.start);
        bounds = bounds.expandToInclude(metrics.getRowBounds(range.end));
        context.canvas.drawRect(bounds.shift(offset), paint);
      }
    }
    super.paint(context, offset);
  }
}

class TableViewHeader extends BasicTableView {
  const TableViewHeader({
    Key key,
    @required double rowHeight,
    @required List<TableColumnController> columns,
    bool roundColumnWidthsToWholePixel = false,
    TableViewMetricsController metricsController,
    this.sortController,
  }) : super(
          key: key,
          rowHeight: rowHeight,
          length: 1,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
          metricsController: metricsController,
        );

  final TableViewSortController sortController;

  @override
  List<TableColumnController> get columns => super.columns as List<TableColumnController>;

  @override
  TableViewHeaderElement createElement() => TableViewHeaderElement(this);

  @override
  RenderBasicTableView createRenderObject(BuildContext context) {
    return RenderTableViewHeader(
      rowHeight: rowHeight,
      length: length,
      columns: columns,
      roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
      metricsController: metricsController,
      sortController: sortController,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTableViewHeader renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject..sortController = sortController;
  }

  @protected
  Widget renderHeaderEnvelope({BuildContext context, int columnIndex}) {
    return TableViewHeaderEnvelope(
      column: columns[columnIndex],
      columnIndex: columnIndex,
      sortController: sortController,
    );
  }
}

class TableViewHeaderEnvelope extends StatefulWidget {
  const TableViewHeaderEnvelope({
    this.column,
    this.columnIndex,
    this.sortController,
    Key key,
  })  : assert(column != null),
        assert(columnIndex != null),
        super(key: key);

  final TableColumnController column;
  final int columnIndex;
  final TableViewSortController sortController;

  @override
  _TableViewHeaderEnvelopeState createState() => _TableViewHeaderEnvelopeState();
}

class _TableViewHeaderEnvelopeState extends State<TableViewHeaderEnvelope> {
  bool _pressed = false;

  static const List<Color> _defaultGradientColors = <Color>[
    Color(0xffdfded7),
    Color(0xfff6f4ed),
  ];

  static const List<Color> _pressedGradientColors = <Color>[
    Color(0xffdbdad3),
    Color(0xffc4c3bc),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isColumnResizable = widget.column.width is ConstrainedTableColumnWidth;

    Widget renderedHeader = Padding(
      padding: EdgeInsets.only(left: 3),
      child: widget.column.headerRenderer(
        context: context,
        columnIndex: widget.columnIndex,
      ),
    );

    if (widget.sortController != null && widget.sortController.sortMode != TableViewSortMode.none) {
      renderedHeader = GestureDetector(
        onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
        onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          final String key = widget.column.key;
          SortDirection direction = widget.sortController[key];
          switch (direction) {
            case SortDirection.ascending:
              direction = SortDirection.descending;
              break;
            default:
              direction = SortDirection.ascending;
              break;
          }
          if (widget.sortController.sortMode == TableViewSortMode.singleColumn) {
            widget.sortController[key] = direction;
          } else if (isShiftKeyPressed()) {
            widget.sortController[key] = direction;
          } else {
            widget.sortController.replaceAll(<String, SortDirection>{key: direction});
          }
        },
        child: renderedHeader,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: _pressed ? _pressedGradientColors : _defaultGradientColors,
        ),
        border: Border(
          bottom: const BorderSide(color: const Color(0xff999999)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: renderedHeader,
          ),
          // TODO: fixed-width column should still paint dividers, but they aren't
          if (isColumnResizable)
            SizedBox(
              width: _kResizeHandleTargetPixels,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: const BorderSide(color: const Color(0xff999999)),
                  ),
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    key: Key('$this dividerKey ${widget.columnIndex}'),
                    behavior: HitTestBehavior.translucent,
                    dragStartBehavior: DragStartBehavior.down,
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      assert(widget.column.width is ConstrainedTableColumnWidth);
                      final ConstrainedTableColumnWidth width = widget.column.width;
                      widget.column.width = width.copyWith(
                        width: width.width + details.primaryDelta,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

@visibleForTesting
class TableViewHeaderElement extends BasicTableViewElement {
  TableViewHeaderElement(TableViewHeader tableView) : super(tableView);

  @override
  TableViewHeader get widget => super.widget as TableViewHeader;

  @override
  RenderTableViewHeader get renderObject => super.renderObject as RenderTableViewHeader;

  @override
  @protected
  Widget renderCell(covariant TableColumnController column, int rowIndex, int columnIndex) {
    return widget.renderHeaderEnvelope(context: this, columnIndex: columnIndex);
  }
}

class RenderTableViewHeader extends RenderBasicTableView
    with TableViewColumnListenerMixin, TableViewSortingMixin {
  RenderTableViewHeader({
    double rowHeight,
    int length,
    List<TableColumnController> columns,
    bool roundColumnWidthsToWholePixel = false,
    TableViewMetricsController metricsController,
    TableViewSortController sortController,
  }) : super(
          rowHeight: rowHeight,
          length: length,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
          metricsController: metricsController,
        ) {
    initializeSortListener();
    this.sortController = sortController;
  }

  @override
  @protected
  void handleSortAdded(TableViewSortController _, String __) {
    markNeedsPaint();
  }

  @override
  @protected
  void handleSortUpdated(TableViewSortController _, String __, SortDirection ___) {
    markNeedsPaint();
  }

  @override
  @protected
  void handleSortChanged(TableViewSortController _) {
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    if (sortController != null) {
      for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        final SortDirection sortDirection = sortController[columns[columnIndex].key];
        if (sortDirection != null) {
          final Rect cellBounds = metrics.getCellBounds(0, columnIndex);
          final SortIndicatorPainter painter = SortIndicatorPainter(sortDirection: sortDirection);
          context.canvas.save();
          try {
            const Size indicatorSize = Size(7, 4);
            context.canvas.translate(
              cellBounds.right - indicatorSize.width - 5,
              cellBounds.centerRight.dy - indicatorSize.height / 2,
            );
            painter.paint(context.canvas, indicatorSize);
          } finally {
            context.canvas.restore();
          }
        }
      }
    }
  }
}

mixin TableViewColumnListenerMixin on RenderBasicTableView {
  @override
  List<TableColumnController> get columns => super.columns as List<TableColumnController>;

  @override
  set columns(List<TableColumnController> value) {
    final List<TableColumnController> oldColumns = columns;
    super.columns = value;
    if (oldColumns != columns) {
      // Initializer value is null (late bound).
      if (oldColumns != null) {
        for (int i = 0; i < oldColumns.length; i++) {
          oldColumns[i].removeListener(_columnListeners[i]);
        }
      }
      _columnListeners = <VoidCallback>[];
      for (int i = 0; i < columns.length; i++) {
        final VoidCallback listener = _listenerForColumn(i);
        _columnListeners.add(listener);
        columns[i].addListener(listener);
      }
    }
  }

  List<VoidCallback> _columnListeners;

  VoidCallback _listenerForColumn(int columnIndex) {
    return () {
      final Rect viewport = constraints.viewportResolver.resolve(size);
      markCellsDirty(TableCellRect.fromLTRB(
        columnIndex,
        viewport.top ~/ rowHeight,
        columnIndex,
        viewport.bottom ~/ rowHeight,
      ));
      markNeedsMetrics();
    };
  }
}

mixin TableViewSortingMixin on RenderBasicTableView {
  TableViewSortListener _sortListener;

  TableViewSortController _sortController;
  TableViewSortController get sortController => _sortController;
  set sortController(TableViewSortController value) {
    if (_sortController == value) return;
    if (_sortController != null) {
      _sortController.removeListener(_sortListener);
    }
    _sortController = value;
    if (_sortController != null) {
      _sortController.addListener(_sortListener);
    }
    markNeedsBuild();
  }

  @protected
  void initializeSortListener() {
    _sortListener = TableViewSortListener(
      onAdded: handleSortAdded,
      onUpdated: handleSortUpdated,
      onChanged: handleSortChanged,
    );
  }

  @protected
  void handleSortAdded(TableViewSortController controller, String key) {}

  @protected
  void handleSortUpdated(TableViewSortController controller, String key, SortDirection previous) {}

  @protected
  void handleSortChanged(TableViewSortController controller) {}
}
