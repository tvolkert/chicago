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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide ScrollController;

import 'basic_list_view.dart';
import 'deferred_layout.dart';
import 'foundation.dart';
import 'listener_list.dart';
import 'scroll_pane.dart';
import 'span.dart';

void main() {
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: TextStyle(fontFamily: 'Verdana', color: const Color(0xffffffff)),
        child: ScrollableListView(
          selectionController: ListViewSelectionController(),
          length: 1000,
          itemHeight: 20,
          itemBuilder: (
            BuildContext context,
            int index,
            bool isSelected,
            bool isHighlighted,
            bool isDisabled,
          ) {
            return Padding(padding: EdgeInsets.only(left: index.toDouble()), child: Text('$index'));
          },
        ),
      ),
    ),
  );
}

typedef ListItemBuilder = Widget Function(
  BuildContext context,
  int index,
  bool isSelected,
  bool isHighlighted,
  bool isDisabled,
);

class ListViewSelectionController with ChangeNotifier {
  ListViewSelectionController({
    this.selectMode = SelectMode.single,
  });

  final SelectMode selectMode;

  ListSelection _selectedRanges = ListSelection();
  RenderListView? _renderObject;

  /// True if this controller is associated with a list view.
  ///
  /// A selection controller may only be associated with one list view at a
  /// time.
  bool get isAttached => _renderObject != null;

  void _attach(RenderListView renderObject) {
    assert(!isAttached);
    _renderObject = renderObject;
  }

  void _detach() {
    assert(isAttached);
    _renderObject = null;
  }

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

  Span? get selectedRange {
    assert(_selectedRanges.length <= 1);
    return _selectedRanges.isEmpty ? null : _selectedRanges[0];
  }

  set selectedRange(Span? range) {
    if (range == null) {
      clearSelection();
    } else {
      selectedRanges = <Span>[range];
    }
  }

  Iterable<Span> get selectedRanges {
    return _selectedRanges.data;
  }

  set selectedRanges(Iterable<Span> ranges) {
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
      assert(range.start >= 0 && (!isAttached || range.end < _renderObject!.length));
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
    assert(start >= 0 && (!isAttached || end < _renderObject!.length));
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
    assert(start >= 0 && (!isAttached || end < _renderObject!.length));
    final List<Span> removedRanges = _selectedRanges.removeRange(start, end);
    notifyListeners();
    return removedRanges;
  }

  void selectAll() {
    assert(isAttached);
    selectedRange = Span(0, _renderObject!.length - 1);
  }

  void clearSelection() {
    if (_selectedRanges.isNotEmpty) {
      _selectedRanges = ListSelection();
      notifyListeners();
    }
  }

  bool isItemSelected(int index) {
    assert(index >= 0 && isAttached && index < _renderObject!.length);
    return _selectedRanges.containsIndex(index);
  }
}

typedef ListViewItemDisabledFilterChangedHandler = void Function(Predicate<int>? previousFilter);

class ListViewItemDisablerListener {
  const ListViewItemDisablerListener({
    required this.onListViewItemDisabledFilterChanged,
  });

  final ListViewItemDisabledFilterChangedHandler onListViewItemDisabledFilterChanged;
}

class ListViewItemDisablerController with ListenerNotifier<ListViewItemDisablerListener> {
  ListViewItemDisablerController({Predicate<int>? filter}) : _filter = filter;

  Predicate<int>? _filter;
  Predicate<int>? get filter => _filter;
  set filter(Predicate<int>? value) {
    Predicate<int>? previousValue = _filter;
    if (value != previousValue) {
      _filter = value;
      notifyListeners((ListViewItemDisablerListener listener) {
        listener.onListViewItemDisabledFilterChanged(previousValue);
      });
    }
  }

  bool isItemDisabled(int index) => filter != null && filter!(index);
}

class ScrollableListView extends StatelessWidget {
  const ScrollableListView({
    Key? key,
    required this.itemHeight,
    required this.length,
    required this.itemBuilder,
    this.selectionController,
    this.itemDisabledController,
    this.platform,
    this.scrollController,
  }) : super(key: key);

  final double itemHeight;
  final int length;
  final ListItemBuilder itemBuilder;
  final ListViewSelectionController? selectionController;
  final ListViewItemDisablerController? itemDisabledController;
  final TargetPlatform? platform;
  final ScrollPaneController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ScrollPane(
      horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
      verticalScrollBarPolicy: ScrollBarPolicy.auto,
      controller: scrollController,
      view: ListView(
        itemHeight: itemHeight,
        length: length,
        itemBuilder: itemBuilder,
        selectionController: selectionController,
        itemDisabledController: itemDisabledController,
        platform: platform,
      ),
    );
  }
}

class ListView extends RenderObjectWidget {
  const ListView({
    Key? key,
    required this.itemHeight,
    required this.length,
    required this.itemBuilder,
    this.selectionController,
    this.itemDisabledController,
    this.platform,
  }) : super(key: key);

  final int length;
  final double itemHeight;
  final ListItemBuilder itemBuilder;
  final ListViewSelectionController? selectionController;
  final ListViewItemDisablerController? itemDisabledController;
  final TargetPlatform? platform;

  @override
  ListViewElement createElement() => ListViewElement(this);

  @override
  RenderListView createRenderObject(BuildContext context) {
    return RenderListView(
      itemHeight: itemHeight,
      length: length,
      selectionController: selectionController,
      itemDisabledController: itemDisabledController,
      platform: platform ?? defaultTargetPlatform,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderListView renderObject) {
    renderObject
      ..itemHeight = itemHeight
      ..length = length
      ..selectionController = selectionController
      ..itemDisabledController = itemDisabledController
      ..platform = platform ?? defaultTargetPlatform;
  }
}

class ListViewElement extends RenderObjectElement with ListViewElementMixin {
  ListViewElement(ListView listView) : super(listView);

  @override
  ListView get widget => super.widget as ListView;

  @override
  RenderListView get renderObject => super.renderObject as RenderListView;

  @override
  @protected
  Widget renderItem(int index) {
    return widget.itemBuilder(
      this,
      index,
      widget.selectionController?.isItemSelected(index) ?? false,
      renderObject.highlightedItem == index,
      widget.itemDisabledController?.isItemDisabled(index) ?? false,
    );
  }
}

class RenderListView extends RenderBasicListView
    with DeferredLayoutMixin
    implements MouseTrackerAnnotation {
  RenderListView({
    required double itemHeight,
    required int length,
    ListViewSelectionController? selectionController,
    ListViewItemDisablerController? itemDisabledController,
    required TargetPlatform platform,
  }) : super(itemHeight: itemHeight, length: length) {
    _itemDisablerListener = ListViewItemDisablerListener(
      onListViewItemDisabledFilterChanged: _handleItemDisabledFilterChanged,
    );
    this.selectionController = selectionController;
    this.itemDisabledController = itemDisabledController;
    this.platform = platform;
  }

  late final ListViewItemDisablerListener _itemDisablerListener;
  late TapGestureRecognizer _tap;

  ListViewSelectionController? _selectionController;
  ListViewSelectionController? get selectionController => _selectionController;
  set selectionController(ListViewSelectionController? value) {
    if (_selectionController == value) return;
    if (attached && _selectionController != null) {
      _selectionController!._detach();
      _selectionController!.removeListener(_handleSelectionChanged);
    }
    _selectionController = value;
    if (attached && _selectionController != null) {
      _selectionController!._attach(this);
      _selectionController!.addListener(_handleSelectionChanged);
    }
    highlightedItem = null;
    markNeedsBuild();
  }

  ListViewItemDisablerController? _itemDisabledController;
  ListViewItemDisablerController? get itemDisabledController => _itemDisabledController;
  set itemDisabledController(ListViewItemDisablerController? value) {
    if (_itemDisabledController == value) return;
    if (attached && _itemDisabledController != null) {
      _itemDisabledController!.removeListener(_itemDisablerListener);
    }
    _itemDisabledController = value;
    if (attached && _itemDisabledController != null) {
      _itemDisabledController!.addListener(_itemDisablerListener);
    }
    markNeedsBuild();
  }

  bool _isItemDisabled(int index) => _itemDisabledController?.isItemDisabled(index) ?? false;

  TargetPlatform? _platform;
  TargetPlatform get platform => _platform!;
  set platform(TargetPlatform value) {
    if (value == _platform) return;
    _platform = value;
  }

  int? _highlightedItem;
  int? get highlightedItem => _highlightedItem;
  set highlightedItem(int? value) {
    if (_highlightedItem == value) return;
    final int? previousValue = _highlightedItem;
    _highlightedItem = value;
    final UnionListItemRange dirtyItems = UnionListItemRange();
    if (previousValue != null) {
      dirtyItems.add(ListItemSequence(previousValue, previousValue));
    }
    if (value != null) {
      dirtyItems.add(ListItemSequence(value, value));
    }
    markItemsDirty(dirtyItems);
  }

  void _handleItemDisabledFilterChanged(Predicate<int>? previousFilter) {
    markNeedsBuild();
  }

  void _handleSelectionChanged() {
    // TODO: be more precise about what to rebuild (requires finer grained info from the notification).
    markNeedsBuild();
  }

  void _onPointerExit(PointerExitEvent event) {
    if (selectionController != null) {
      deferMarkNeedsLayout(() {
        highlightedItem = null;
      });
    }
  }

  void _onPointerScroll(PointerScrollEvent event) {
    if (event.scrollDelta != Offset.zero) {
      deferMarkNeedsLayout(() {
        highlightedItem = null;
      });
    }
  }

  void _onPointerHover(PointerHoverEvent event) {
    if (selectionController != null && event.kind == PointerDeviceKind.mouse) {
      deferMarkNeedsLayout(() {
        final int index = getItemAt(event.localPosition.dy);
        highlightedItem = index != -1 && !_isItemDisabled(index) ? index : null;
      });
    }
  }

  _ListViewSelectionUpdateTask? _tapDownSelectionUpdateTask;

  void _handleTapDown(TapDownDetails details) {
    ListViewSelectionController? selectionController = this.selectionController;
    final SelectMode selectMode = selectionController?.selectMode ?? SelectMode.none;
    if (selectionController != null && selectMode != SelectMode.none) {
      final int index = getItemAt(details.localPosition.dy);
      if (index >= 0 && index < length && !_isItemDisabled(index)) {
        if (isShiftKeyPressed() && selectMode == SelectMode.multi) {
          final int startIndex = selectionController.firstSelectedIndex;
          if (startIndex == -1) {
            _tapDownSelectionUpdateTask = _ListViewAddToSelection(index);
          } else {
            final int endIndex = selectionController.lastSelectedIndex;
            final Span range = Span(index, index > startIndex ? startIndex : endIndex);
            _tapDownSelectionUpdateTask = _ListViewSetSelectedRange(range);
          }
        } else if (isPlatformCommandKeyPressed(platform) && selectMode == SelectMode.multi) {
          if (selectionController.isItemSelected(index)) {
            _tapDownSelectionUpdateTask = _ListViewRemoveFromSelection(index);
          } else {
            _tapDownSelectionUpdateTask = _ListViewAddToSelection(index);
          }
        } else if (isPlatformCommandKeyPressed(platform) && selectMode == SelectMode.single) {
          if (selectionController.isItemSelected(index)) {
            _tapDownSelectionUpdateTask = _ListViewSetSelectedIndex(-1);
          } else {
            _tapDownSelectionUpdateTask = _ListViewSetSelectedIndex(index);
          }
        } else if (selectMode != SelectMode.none) {
          _tapDownSelectionUpdateTask = _ListViewSetSelectedIndex(index);
        }
      }
    }
  }

  void _handleTapCancel() {
    _tapDownSelectionUpdateTask = null;
  }

  void _handleTap() {
    _tapDownSelectionUpdateTask?.run(selectionController);
    _tapDownSelectionUpdateTask = null;
  }

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => null;

  @override
  PointerExitEventListener? get onExit => _onPointerExit;

  @override
  bool get validForMouseTracker => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerHoverEvent) return _onPointerHover(event);
    if (event is PointerScrollEvent) return _onPointerScroll(event);
    if (event is PointerDownEvent) return _tap.addPointer(event);
    super.handleEvent(event, entry);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _tap = TapGestureRecognizer(debugOwner: this)
      ..onTapDown = _handleTapDown
      ..onTapCancel = _handleTapCancel
      ..onTap = _handleTap;
    if (_selectionController != null) {
      _selectionController!.addListener(_handleSelectionChanged);
      _selectionController!._attach(this);
    }
    if (_itemDisabledController != null) {
      _itemDisabledController!.addListener(_itemDisablerListener);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    if (_selectionController != null) {
      _selectionController!._detach();
      _selectionController!.removeListener(_handleSelectionChanged);
    }
    if (_itemDisabledController != null) {
      _itemDisabledController!.removeListener(_itemDisablerListener);
    }
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_highlightedItem != null) {
      final Rect rowBounds = getItemBounds(_highlightedItem!);
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xffdddcd5);
      context.canvas.drawRect(rowBounds.shift(offset), paint);
    }
    if (selectionController != null && selectionController!.selectedRanges.isNotEmpty) {
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xff14538b);
      for (Span range in selectionController!.selectedRanges) {
        Rect bounds = getItemBounds(range.start);
        bounds = bounds.expandToInclude(getItemBounds(range.end));
        context.canvas.drawRect(bounds.shift(offset), paint);
      }
    }
    super.paint(context, offset);
  }
}

@immutable
abstract class _ListViewSelectionUpdateTask {
  const _ListViewSelectionUpdateTask();

  void run(ListViewSelectionController? controller);
}

class _ListViewAddToSelection extends _ListViewSelectionUpdateTask {
  const _ListViewAddToSelection(this.index);

  final int index;

  @override
  void run(ListViewSelectionController? controller) => controller?.addSelectedIndex(index);
}

class _ListViewRemoveFromSelection extends _ListViewSelectionUpdateTask {
  const _ListViewRemoveFromSelection(this.index);

  final int index;

  @override
  void run(ListViewSelectionController? controller) => controller?.removeSelectedIndex(index);
}

class _ListViewSetSelectedRange extends _ListViewSelectionUpdateTask {
  const _ListViewSetSelectedRange(this.range);

  final Span range;

  @override
  void run(ListViewSelectionController? controller) => controller?.selectedRange = range;
}

class _ListViewSetSelectedIndex extends _ListViewSelectionUpdateTask {
  const _ListViewSetSelectedIndex(this.index);

  final int index;

  @override
  void run(ListViewSelectionController? controller) => controller?.selectedIndex = index;
}
