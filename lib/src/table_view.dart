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
import 'package:payouts/src/pivot/span.dart';

import 'basic_table_view.dart';
import 'foundation.dart';
import 'listener_list.dart';
import 'scroll_pane.dart';
import 'sorting.dart';

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
});

/// Controls the properties of a column in a [ScrollableTableView].
///
/// Mutable properties such as [width] and [sortDirection] will notify
/// listeners when changed.
class TableColumnController extends BasicTableColumn with ChangeNotifier {
  TableColumnController({
    @required this.key,
    @required this.headerRenderer,
    @required TableCellRenderer cellRenderer,
    TableColumnWidth width = const FlexTableColumnWidth(),
    SortDirection sortDirection,
  })  : assert(key != null),
        assert(cellRenderer != null),
        assert(headerRenderer != null),
        assert(width != null),
        _width = width,
        super(cellRenderer: cellRenderer);

  /// A unique identifier for this column.
  ///
  /// This is the key by which we sort columns in [TableViewSortController].
  final String key;

  /// The renderer responsible for the look & feel of the header for this column.
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
    this.selectMode = SelectMode.none,
  }) : assert(selectMode != null);

  /// TODO: document
  final SelectMode selectMode;

  ListSelection _selectedRanges = ListSelection();
  RenderTableView _renderObject;

  /// True if this controller is associated with a [ScrollableTableView].
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
    this.selectionController,
    this.sortController,
    this.scrollController,
    this.roundColumnWidthsToWholePixel = false,
  })  : assert(rowHeight != null),
        assert(length != null),
        assert(columns != null),
        assert(roundColumnWidthsToWholePixel != null),
        super(key: key);

  final double rowHeight;
  final int length;
  final List<TableColumnController> columns;
  final TableViewSelectionController selectionController;
  final TableViewSortController sortController;
  final ScrollController scrollController;
  final bool roundColumnWidthsToWholePixel;

  @override
  Widget build(BuildContext context) {
    return ScrollPane(
      horizontalScrollBarPolicy: ScrollBarPolicy.expand,
      verticalScrollBarPolicy: ScrollBarPolicy.auto,
      scrollController: scrollController,
      columnHeader: TableViewHeader(
        rowHeight: rowHeight,
        columns: columns,
        sortController: sortController,
        roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
      ),
      view: TableView(
        length: length,
        rowHeight: rowHeight,
        columns: columns,
        roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
        selectionController: selectionController,
        sortController: sortController,
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
    this.selectionController,
    this.sortController,
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
  final TableViewSelectionController selectionController;
  final TableViewSortController sortController;
  final bool roundColumnWidthsToWholePixel;
  final TargetPlatform platform;

  @override
  _TableViewState createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  StreamController<PointerEvent> _pointerEvents;

  @override
  void initState() {
    super.initState();
    _pointerEvents = StreamController();
  }

  @override
  void dispose() {
    _pointerEvents.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = RawTableView(
      rowHeight: widget.rowHeight,
      length: widget.length,
      columns: widget.columns,
      selectionController: widget.selectionController,
      sortController: widget.sortController,
      roundColumnWidthsToWholePixel: widget.roundColumnWidthsToWholePixel,
      pointerEvents: _pointerEvents.stream,
      platform: widget.platform ?? defaultTargetPlatform,
    );

    if (widget.selectionController.selectMode != SelectMode.none) {
      result = MouseRegion(
        onEnter: _pointerEvents.add,
        onExit: _pointerEvents.add,
        onHover: _pointerEvents.add,
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
    this.selectionController,
    this.sortController,
    @required this.pointerEvents,
    @required this.platform,
  })  : assert(platform != null),
        super(
          key: key,
          rowHeight: rowHeight,
          length: length,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
        );

  final TableViewSelectionController selectionController;
  final TableViewSortController sortController;
  final Stream<PointerEvent> pointerEvents;
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
      selectionController: selectionController,
      sortController: sortController,
      pointerEvents: pointerEvents,
      platform: platform,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTableView renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..selectionController = selectionController
      ..sortController = sortController
      ..pointerEvents = pointerEvents
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
    return column.cellRenderer(
      context: this,
      rowIndex: rowIndex,
      columnIndex: columnIndex,
      rowHighlighted: renderObject.highlightedRow == rowIndex,
      rowSelected: widget.selectionController.isRowSelected(rowIndex),
    );
  }
}

@visibleForTesting
class RenderTableView extends RenderBasicTableView with TableViewColumnListenerMixin {
  RenderTableView({
    double rowHeight,
    int length,
    List<TableColumnController> columns,
    bool roundColumnWidthsToWholePixel = false,
    TableViewSelectionController selectionController,
    TableViewSortController sortController,
    Stream<PointerEvent> pointerEvents,
    TargetPlatform platform,
  }) : super(
          rowHeight: rowHeight,
          length: length,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
        ) {
    _sortListener = TableViewSortListener(
      onAdded: _handleSortAdded,
      onUpdated: _handleSortUpdated,
      onChanged: _handleSortChanged,
    );
    this.selectionController = selectionController;
    this.sortController = sortController;
    this.pointerEvents = pointerEvents;
    this.platform = platform;
  }

  TableViewSortListener _sortListener;

  TableViewSelectionController _selectionController;
  TableViewSelectionController get selectionController => _selectionController;
  set selectionController(TableViewSelectionController value) {
    assert(value != null);
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

  StreamSubscription<PointerEvent> _pointerEventsSubscription;
  Stream<PointerEvent> _pointerEvents;
  Stream<PointerEvent> get pointerEvents => _pointerEvents;
  set pointerEvents(Stream<PointerEvent> value) {
    assert(value != null);
    if (_pointerEvents == value) return;
    if (_pointerEvents != null) {
      assert(_pointerEventsSubscription != null);
      _pointerEventsSubscription.cancel();
    }
    _pointerEvents = value;
    _pointerEventsSubscription = _pointerEvents.listen(_onPointerEvent);
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

  void _handleSelectionChanged() {
    // TODO: be more precise about what to rebuild (requires finer grained info from the notification).
    markNeedsBuild();
  }

  void _handleSortAdded(TableViewSortController controller, String key) {
    markNeedsBuild();
  }

  void _handleSortUpdated(TableViewSortController controller, String key, SortDirection previousDirection) {
    markNeedsBuild();
  }

  void _handleSortChanged(TableViewSortController controller) {
    markNeedsBuild();
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
    final TableCellOffset cellOffset = metrics.hitTest(event.localPosition);
    if (cellOffset != null) {
      highlightedRow = cellOffset.rowIndex;
    }
  }

  int _selectIndex = -1;

  void _onPointerDown(PointerDownEvent event) {
    final SelectMode selectMode = selectionController.selectMode;
    if (selectMode != SelectMode.none) {
      final TableCellOffset cellOffset = metrics.hitTest(event.localPosition);
      final int rowIndex = cellOffset.rowIndex;
      if (cellOffset.rowIndex >= 0 && cellOffset.rowIndex < length) {
        final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;

        if (isShiftKeyPressed() && selectMode == SelectMode.multi) {
          final int startIndex = selectionController.firstSelectedIndex;
          if (startIndex == -1) {
            selectionController.addSelectedIndex(cellOffset.rowIndex);
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
  }

  @override
  void detach() {
    if (_selectionController != null) {
      _selectionController._detach();
    }
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_highlightedRow != null) {
      final Rect rowBounds = metrics.getRowBounds(_highlightedRow);
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xffdddcd5);
      context.canvas.drawRect(rowBounds.shift(offset), paint);
    }
    if (selectionController.selectedRanges.isNotEmpty) {
      for (Span range in selectionController.selectedRanges) {
        final Rect rangeBounds =
            metrics.getRowBounds(range.start).expandToInclude(metrics.getRowBounds(range.end));
        Paint paint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xff14538b);
        context.canvas.drawRect(rangeBounds.shift(offset), paint);
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
    this.sortController,
  }) : super(
          key: key,
          rowHeight: rowHeight,
          length: 1,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
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
    );
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

class RenderTableViewHeader extends RenderBasicTableView with TableViewColumnListenerMixin {
  RenderTableViewHeader({
    double rowHeight,
    int length,
    List<TableColumnController> columns,
    bool roundColumnWidthsToWholePixel = false,
  }) : super(
          rowHeight: rowHeight,
          length: length,
          columns: columns,
          roundColumnWidthsToWholePixel: roundColumnWidthsToWholePixel,
        );
}

mixin TableViewColumnListenerMixin on RenderBasicTableView {
  @override
  List<TableColumnController> get columns => super.columns as List<TableColumnController>;

  @override
  set columns(List<TableColumnController> value) {
    final List<BasicTableColumn> oldColumns = super.columns;
    super.columns = value;
    if (oldColumns != columns) {
      // Initializer value is List<BasicTableColumn>
      if (oldColumns is List<TableColumnController>) {
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
      markCellsDirty(TableCellRect.fromLTRB(
        columnIndex,
        constraints.viewport.top ~/ rowHeight,
        columnIndex,
        constraints.viewport.bottom ~/ rowHeight,
      ));
      markNeedsMetricsCalculation();
    };
  }
}
