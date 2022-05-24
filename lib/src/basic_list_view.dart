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
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'debug.dart';
import 'segment.dart';
import 'scroll_pane.dart';

void main() {
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Verdana', color: Color(0xffffffff)),
        child: ScrollPane(
          horizontalScrollBarPolicy: ScrollBarPolicy.stretch,
          view: BasicListView(
            length: 1000,
            itemHeight: 20,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(left: index.toDouble()),
                child: Text('$index'),
              );
            },
          ),
        ),
      ),
    ),
  );
}

typedef ListItemVisitor = void Function(int index);

typedef ListItemChildVisitor = void Function(RenderBox child, int index);

typedef ListItemHost = void Function(ListItemVisitor visitor);

typedef ListViewLayoutCallback = void Function({
  required ListItemHost visitChildrenToRemove,
  required ListItemHost visitChildrenToBuild,
});

typedef BasicListItemBuilder = Widget Function(
  BuildContext context,
  int index,
);

class BasicListView extends RenderObjectWidget {
  const BasicListView({
    super.key,
    required this.length,
    required this.itemHeight,
    required this.itemBuilder,
  }) : assert(length >= 0);

  final int length;
  final double itemHeight;
  final BasicListItemBuilder itemBuilder;

  @override
  BasicListViewElement createElement() => BasicListViewElement(this);

  @override
  @protected
  RenderBasicListView createRenderObject(BuildContext context) {
    return RenderBasicListView(
      itemHeight: itemHeight,
      length: length,
    );
  }

  @override
  @protected
  void updateRenderObject(BuildContext context, covariant RenderBasicListView renderObject) {
    renderObject
      ..itemHeight = itemHeight
      ..length = length;
  }
}

abstract class ListItemRange with Diagnosticable {
  const ListItemRange();

  void visitItems(ListItemVisitor visitor);

  bool contains(int index) {
    bool result = false;
    visitItems((int i) {
      if (i == index) {
        result = true;
      }
    });
    return result;
  }

  ListItemRange where(bool Function(int index) test) {
    return ProxyListItemRange((ListItemVisitor visitor) {
      visitItems((int index) {
        if (test(index)) {
          visitor(index);
        }
      });
    });
  }

  ListItemRange subtract(ListItemRange other) {
    return where((int index) => !other.contains(index));
  }

  ListItemRange intersect(ListItemRange other) {
    return where((int index) => other.contains(index));
  }
}

class SingleListItemRange extends ListItemRange {
  const SingleListItemRange(this.index);

  final int index;

  @override
  void visitItems(ListItemVisitor visitor) {
    visitor(index);
  }

  @override
  bool contains(int index) {
    return index == this.index;
  }
}

class ListItemSequence extends ListItemRange {
  const ListItemSequence(this.start, this.end);

  final int start;
  final int end;

  static const ListItemSequence empty = ListItemSequence(0, -1);

  bool get isNormalized => start >= 0 && start <= end;

  /// True if [visitCells] will not visit anything.
  ///
  /// An empty [ListItemSequence] is guaranteed to have an [isNormalized] value of
  /// false.
  bool get isEmpty => start > end;

  @override
  void visitItems(ListItemVisitor visitor) {
    for (int index = start; index <= end; index++) {
      visitor(index);
    }
  }

  @override
  bool contains(int index) {
    return index >= start && index <= end;
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('start', start));
    properties.add(IntProperty('end', end));
  }
}

class EmptyListItemRange extends ListItemRange {
  const EmptyListItemRange();

  @override
  void visitItems(ListItemVisitor visitor) {}

  @override
  bool contains(int index) => false;
}

class ProxyListItemRange extends ListItemRange {
  const ProxyListItemRange(this.host);

  final ListItemHost host;

  @override
  void visitItems(ListItemVisitor visitor) => host(visitor);

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Function>('host', host));
  }
}

class UnionListItemRange extends ListItemRange {
  UnionListItemRange([
    List<ListItemRange> ranges = const <ListItemRange>[],
  ]) : _ranges = List<ListItemRange>.from(ranges);

  final List<ListItemRange> _ranges;

  void add(ListItemRange range) {
    _ranges.add(range);
  }

  @override
  void visitItems(ListItemVisitor visitor) {
    final Set<int> indexes = <int>{};
    for (ListItemRange range in _ranges) {
      range.visitItems((int index) {
        if (indexes.add(index)) {
          visitor(index);
        }
      });
    }
  }

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<ListItemRange>>('ranges', _ranges));
  }
}

@immutable
class ListViewSlot with Diagnosticable {
  const ListViewSlot(this.index);

  final int index;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is ListViewSlot && index == other.index;
  }

  @override
  int get hashCode => index.hashCode;

  @override
  @protected
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
  }
}

mixin ListViewElementMixin on RenderObjectElement {
  Map<int, Element>? _children;

  @override
  RenderBasicListView get renderObject => super.renderObject as RenderBasicListView;

  @override
  @protected
  void reassemble() {
    super.reassemble();
    renderObject.markNeedsBuild();
  }

  @override
  void update(covariant RenderObjectWidget newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    renderObject.updateLayoutCallback(_layout);
  }

  @protected
  Widget renderItem(int index);

  void _layout({
    required ListItemHost visitChildrenToRemove,
    required ListItemHost visitChildrenToBuild,
  }) {
    owner!.buildScope(this, () {
      visitChildrenToRemove((int index) {
        assert(_children != null);
        assert(_children!.containsKey(index));
        final Element child = _children![index]!;
        final Element? newChild = updateChild(child, null, null /* unused for remove */);
        assert(newChild == null);
        _children!.remove(index);
      });
      visitChildrenToBuild((int index) {
        assert(_children != null);
        late Widget built;
        try {
          built = renderItem(index);
          assert(() {
            if (debugPaintListItemBuilds) {
              debugCurrentListItemColor =
                  debugCurrentListItemColor.withHue((debugCurrentListItemColor.hue + 2) % 360.0);
              built = DecoratedBox(
                decoration: BoxDecoration(color: debugCurrentListItemColor.toColor()),
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
        final ListViewSlot slot = ListViewSlot(index);
        try {
          child = updateChild(_children![index], built, slot)!;
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
        _children![index] = child;
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
    _children = <int, Element>{};
    renderObject.updateLayoutCallback(_layout);
  }

  @override
  void unmount() {
    renderObject.updateLayoutCallback(null);
    super.unmount();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children!.values) {
      visitor(child);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(child.slot is ListViewSlot);
    final ListViewSlot slot = child.slot as ListViewSlot;
    assert(_children != null);
    assert(_children!.containsKey(slot.index));
    assert(_children![slot.index] == child);
    _children!.remove(slot.index);
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(RenderBox child, ListViewSlot slot) {
    assert(child.parent == null);
    renderObject.insert(child, index: slot.index);
    assert(child.parent == renderObject);
  }

  @override
  void moveRenderObjectChild(RenderBox child, ListViewSlot? oldSlot, ListViewSlot newSlot) {
    assert(child.parent == renderObject);
    renderObject.move(child, index: newSlot.index);
    assert(child.parent == renderObject);
  }

  @override
  void removeRenderObjectChild(RenderBox child, ListViewSlot? slot) {
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(child.parent == null);
  }
}

class BasicListViewElement extends RenderObjectElement with ListViewElementMixin {
  BasicListViewElement(BasicListView super.listView);

  @override
  BasicListView get widget => super.widget as BasicListView;

  @override
  void update(BasicListView newWidget) {
    if (widget.itemBuilder != newWidget.itemBuilder) {
      renderObject.markNeedsBuild();
    }
    super.update(newWidget);
  }

  @override
  @protected
  Widget renderItem(int index) {
    return widget.itemBuilder(this, index);
  }
}

class RenderBasicListView extends RenderSegment {
  RenderBasicListView({
    required double itemHeight,
    required int length,
  }) {
    this.itemHeight = itemHeight;
    this.length = length;
  }

  double? _itemHeight;
  double get itemHeight => _itemHeight!;
  set itemHeight(double value) {
    if (_itemHeight == value) return;
    _itemHeight = value;
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
    // We rebuild because the cell at any given offset may not contain the same
    // contents as it did before the length changed.
    markNeedsBuild();
  }

  final Map<int, RenderBox> _children = <int, RenderBox>{};

  void insert(RenderBox child, {required int index}) {
    final RenderBox? oldChild = _children.remove(index);
    if (oldChild != null) dropChild(oldChild);
    _children[index] = child;
    child.parentData = ListViewParentData(index: index);
    adoptChild(child);
  }

  void move(RenderBox child, {required int index}) {
    remove(child);
    insert(child, index: index);
  }

  void remove(RenderBox child) {
    assert(child.parentData is ListViewParentData);
    final ListViewParentData parentData = child.parentData as ListViewParentData;
    assert(_children[parentData.index] == child);
    _children.remove(parentData.index);
    dropChild(child);
  }

  ListViewLayoutCallback? _layoutCallback;

  /// Change the layout callback.
  @protected
  void updateLayoutCallback(ListViewLayoutCallback? value) {
    if (value == _layoutCallback) return;
    _layoutCallback = value;
    markNeedsBuild();
  }

  /// Whether the whole list view is in need of being built.
  bool _needsBuild = true;

  /// Marks this list view as needing to rebuild.
  ///
  /// See also:
  ///
  ///  * [markItemsDirty], which marks specific items as needing to rebuild.
  @protected
  void markNeedsBuild() {
    _needsBuild = true;
    markNeedsLayout();
  }

  /// Specific items in need of building.
  UnionListItemRange? _dirtyItems;

  /// Marks specific items as needing to rebuild.
  ///
  /// See also:
  ///
  ///  * [markNeedsBuild], which marks the whole list view as needing to
  ///    rebuild.
  @protected
  void markItemsDirty(ListItemRange items) {
    _dirtyItems ??= UnionListItemRange();
    _dirtyItems!.add(items);
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
  void visitListItems(ListItemChildVisitor visitor, {bool allowMutations = false}) {
    Iterable<MapEntry<int, RenderBox>> items = _children.entries;
    if (allowMutations) items = items.toList(growable: false);
    for (MapEntry<int, RenderBox> item in items) {
      final int index = item.key;
      final RenderBox child = item.value;
      visitor(child, index);
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    visitListItems((RenderBox child, int index) {
      visitor(child);
    });
  }

  int getItemAt(double dy) => dy ~/ itemHeight;

  Rect getItemBounds(int index) {
    assert(index >= 0 && index < length);
    return Rect.fromLTWH(0, index * itemHeight, size.width, itemHeight);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final int index = getItemAt(position.dy);
    if (!_children.containsKey(index)) {
      // No list item at the given position.
      return false;
    }
    assert(index >= 0);
    final RenderBox child = _children[index]!;
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
  bool hitTestSelf(Offset position) {
    int index = getItemAt(position.dy);
    return index >= 0 && index < length;
  }

  @override
  void setupParentData(RenderBox child) {
    // We manually attach the parent data in [insert] before adopting the child,
    // so by the time this is called, the parent data is already set-up.
    assert(child.parentData is ListViewParentData);
    super.setupParentData(child);
  }

  // @override
  // double computeMinIntrinsicWidth(double height) {
  //   double intrinsicWidth = 0;
  //   for (int i = 0; i < length; i++) {
  //     owner;
  //     Widget built = itemBuilder(context: debugCreator, index: i);
  //   }
  //   return intrinsicWidth;
  // }

  @override
  double computeMinIntrinsicHeight(double width) {
    return length * itemHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  @protected
  void performLayout() {
    size = constraints.constrainDimensions(double.infinity, itemHeight * length);

    // Relies on size being set.
    rebuildIfNecessary();

    visitListItems((RenderBox child, int index) {
      final double itemY = index * itemHeight;
      child.layout(BoxConstraints.tightFor(width: size.width, height: itemHeight));
      final BoxParentData parentData = child.parentData as BoxParentData;
      parentData.offset = Offset(0, itemY);
    });
  }

  Rect? _viewport;

  bool _isInBounds(int index) {
    return index < length;
  }

  bool _isBuilt(int index) {
    return _children.containsKey(index);
  }

  bool _isNotBuilt(int index) {
    return !_children.containsKey(index);
  }

  @protected
  ListItemRange builtCells() {
    return ProxyListItemRange((ListItemVisitor visitor) {
      visitListItems((RenderBox child, int index) {
        visitor(index);
      }, allowMutations: true);
    });
  }

  ListItemSequence _getIntersectingItems(Rect rect) {
    if (rect.isEmpty) {
      return ListItemSequence.empty;
    }
    int bottomIndex = rect.bottom ~/ itemHeight;
    if (rect.bottom.remainder(itemHeight) == 0) {
      // The rect goes *right up* to the item but doesn't actually overlap it.
      bottomIndex -= 1;
    }
    return ListItemSequence(rect.top ~/ itemHeight, bottomIndex);
  }

  @protected
  void rebuildIfNecessary() {
    assert(_layoutCallback != null);
    assert(debugDoingThisLayout);
    final Rect? previousViewport = _viewport;
    _viewport = constraints.viewportResolver.resolve(size);
    if (!_needsBuild && _dirtyItems == null && _viewport == previousViewport) {
      return;
    }

    final ListItemRange builtCells = this.builtCells();
    final ListItemSequence viewportItemSequence = _getIntersectingItems(_viewport!);
    ListItemRange removeCells = builtCells.subtract(viewportItemSequence);
    ListItemRange buildCells;

    if (_needsBuild) {
      removeCells = UnionListItemRange(<ListItemRange>[removeCells, builtCells.where((int index) => index >= length)]);
      buildCells = viewportItemSequence;
      _needsBuild = false;
      _dirtyItems = null;
    } else if (_dirtyItems != null) {
      buildCells = UnionListItemRange(<ListItemRange>[
        _dirtyItems!.intersect(viewportItemSequence),
        viewportItemSequence.where(_isNotBuilt),
      ]);
      _dirtyItems = null;
    } else {
      assert(previousViewport != null);
      if (_viewport!.overlaps(previousViewport!)) {
        final Rect overlap = _viewport!.intersect(previousViewport);
        final ListItemSequence overlapItemSequence = _getIntersectingItems(overlap);
        removeCells = _getIntersectingItems(previousViewport).subtract(overlapItemSequence);
        buildCells = viewportItemSequence.subtract(overlapItemSequence);
      } else {
        buildCells = viewportItemSequence;
      }
    }

    invokeLayoutCallback<SegmentConstraints>((SegmentConstraints _) {
      _layoutCallback!(
        visitChildrenToRemove: removeCells.where(_isBuilt).visitItems,
        visitChildrenToBuild: buildCells.where(_isInBounds).visitItems,
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
    visitListItems((RenderBox child, int index) {
      result.add(child.toDiagnosticsNode(name: 'child $index'));
    });
    return result;
  }
}

class ListViewParentData extends BoxParentData {
  ListViewParentData({required this.index});

  final int index;

  @override
  String toString() => '${super.toString()}, index=$index';
}
