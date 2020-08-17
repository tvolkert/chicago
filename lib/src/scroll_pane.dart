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
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'listener_list.dart';
import 'scroll_bar.dart';
import 'segment.dart';

class ScrollPaneTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ScrollPane(
        horizontalScrollBarPolicy: ScrollBarPolicy.auto,
        verticalScrollBarPolicy: ScrollBarPolicy.auto,
        topLeftCorner: Image.asset('assets/IMG_20200701_131732.jpg', fit: BoxFit.cover),
        columnHeader: ColoredBox(
          color: Color(0xffff0000),
          child: Table(
            defaultColumnWidth: FixedColumnWidth(100),
            children: [
              TableRow(
                children: [
                  Text('HAAA'),
                  Text('Hb'),
                  Text('Hc'),
                  Text('Hd'),
                  Text('He'),
                  Text('Hf'),
                  Text('Hg'),
                  Text('Hh'),
                  Text('Hi'),
                  Text('Hj'),
                  Text('Hk'),
                ],
              ),
            ],
          ),
        ),
        rowHeader: ColoredBox(
          color: Color(0xff00ff00),
          child: Table(
            defaultColumnWidth: FixedColumnWidth(100),
            columnWidths: {0: IntrinsicColumnWidth()},
            children: [
              TableRow(children: [SizedBox(height: 100), Text('0H')]),
              TableRow(children: [SizedBox(height: 100), Text('1H')]),
              TableRow(children: [SizedBox(height: 100), Text('2H')]),
              TableRow(children: [SizedBox(height: 100), Text('3H')]),
              TableRow(children: [SizedBox(height: 100), Text('4H')]),
              TableRow(children: [SizedBox(height: 100), Text('5H')]),
            ],
          ),
        ),
//        view: ColoredBox(
//          color: Color(0xff0000ff),
//          child: Table(
//            defaultColumnWidth: FixedColumnWidth(100),
//            columnWidths: {0: IntrinsicColumnWidth(), 12: FixedColumnWidth(2)},
//            children: [
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('0a'),
//                  Text('0b'),
//                  Text('0c'),
//                  Text('0d'),
//                  Text('0e'),
//                  Text('0f'),
//                  Text('0g'),
//                  Text('0h'),
//                  Text('0i'),
//                  Text('0j'),
//                  Text('0k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('1a'),
//                  Text('1b'),
//                  Text('1c'),
//                  Text('1d'),
//                  Text('1e'),
//                  Text('1f'),
//                  Text('1g'),
//                  Text('1h'),
//                  Text('1i'),
//                  Text('1j'),
//                  Text('1k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('2a'),
//                  Text('2b'),
//                  Text('2c'),
//                  Text('2d'),
//                  Text('2e'),
//                  Text('2f'),
//                  Text('2g'),
//                  Text('2h'),
//                  Text('2i'),
//                  Text('2j'),
//                  Text('2k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('3a'),
//                  Text('3b'),
//                  Text('3c'),
//                  Text('3d'),
//                  Text('3e'),
//                  Text('3f'),
//                  Text('3g'),
//                  Text('3h'),
//                  Text('3i'),
//                  Text('3j'),
//                  Text('3k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('4a'),
//                  Text('4b'),
//                  Text('4c'),
//                  Text('4d'),
//                  Text('4e'),
//                  Text('4f'),
//                  Text('4g'),
//                  Text('4h'),
//                  Text('4i'),
//                  Text('4j'),
//                  Text('4k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//              TableRow(
//                children: [
//                  SizedBox(height: 100),
//                  Text('5a'),
//                  Text('5b'),
//                  Text('5c'),
//                  Text('5d'),
//                  Text('5e'),
//                  Text('5f'),
//                  Text('5g'),
//                  Text('5h'),
//                  Text('5i'),
//                  Text('5j'),
//                  Text('5k'),
//                  ColoredBox(color: Color(0xffabcdef), child: SizedBox(height: 20)),
//                ],
//              ),
//            ],
//          ),
//        ),
        view: Image.asset('assets/IMG_20200701_131732.jpg'),
      ),
    );
  }
}

/// The policy that dictates how a [ScrollPane] will lay its [ScrollPane.view]
/// out within a given [Axis], which directly affects how and when the
/// scrollbar is shown in that axis.
///
/// See also:
///
///  * [ScrollPane.horizontalScrollBarPolicy], which specifies the policy for a
///    [ScrollPane]'s horizontal axis.
///  * [ScrollPane.verticalScrollBarPolicy], which specifies the policy for a
///    [ScrollPane]'s vertical axis.
enum ScrollBarPolicy {
  /// Lays the view out with unconstrained size in the axis, and shows a
  /// scrollbar only when the viewport's size is less than needed to display
  /// the entirety of the view.
  ///
  /// This policy is somewhat expensive in terms of layout performance.
  auto,

  /// Lays the view out with unconstrained size in the axis, and never shows
  /// a scrollbar, even if the viewport's size is less than needed to display
  /// the entirety of the view.
  ///
  /// The scroll pane will still respond to trackpad / mouse wheel events by
  /// scrolling.
  ///
  /// Along with the [always] and [stretch] policies, this policy is the
  /// cheapest in terms of  layout performance.
  never,

  /// Lays the view out with unconstrained size in the axis, and always shows a
  /// scrollbar, even if the viewport's size is large enough to display the
  /// entirety of the view.
  ///
  /// If the viewport's size is large enough to display the entirety of the
  /// view, the scrollback will be disabled.
  ///
  /// Along with the [never] and [stretch] policies, this policy is the
  /// cheapest in terms of  layout performance.
  always,

  /// Lays the view out with tight constraints such that the view will be
  /// exactly the same size in the axis as the viewport.
  ///
  /// With this policy, a scrollbar will never be shown because the view is
  /// always exactly as big as the viewport, even if that size is less than
  /// the view's intrinsic size.
  ///
  /// Along with the [always] and [never] policies, this policy is the
  /// cheapest in terms of  layout performance.
  stretch,

  /// Gives the view at least its min intrinsic size, and stretches the view
  /// to match the viewport's size in the axis if there's any excess space.
  ///
  /// The existence of the scrollbar is the same with this policy as with the
  /// [auto] policy. The difference between the two policies is that with this
  /// policy, when the scrollbar is not needed, the view will be stretched to
  /// exactly fit the size of the viewport in the axis.
  ///
  /// This policy is somewhat expensive in terms of layout performance.
  expand,
}

typedef ScrollOffsetChangedHandler = void Function(
  ScrollController controller,
  Offset previousOffset,
);

class ScrollPaneListener {
  const ScrollPaneListener({
    @required this.onScrollOffsetChanged,
  }) : assert(onScrollOffsetChanged != null);

  final ScrollOffsetChangedHandler onScrollOffsetChanged;
}

class ScrollController with ListenerNotifier<ScrollPaneListener> {
  ScrollController({
    Offset scrollOffset = Offset.zero,
  })  : assert(scrollOffset != null),
        _scrollOffset = scrollOffset;

  Offset _scrollOffset;
  Offset get scrollOffset => _scrollOffset;
  set scrollOffset(Offset value) {
    assert(value != null);
    if (value == _scrollOffset) return;
    final Offset previousOffset = _scrollOffset;
    value = _boundsCheckIfAttached(value);
    if (value == _scrollOffset) return;
    _scrollOffset = value;
    notifyListeners((ScrollPaneListener listener) {
      listener.onScrollOffsetChanged(this, previousOffset);
    });
  }

  void _skipBoundscheck(VoidCallback callback) {
    assert(_boundsCheck);
    _boundsCheck = false;
    try {
      callback();
    } finally {
      _boundsCheck = true;
    }
  }

  RenderScrollPane _renderObject;
  bool _boundsCheck = true;

  Offset _boundsCheckIfAttached(Offset scrollOffset) {
    if (_renderObject != null && _boundsCheck) {
      return _renderObject._boundsCheckScrollOffset(scrollOffset);
    }
    return scrollOffset;
  }

  void _detach() {
    assert(_renderObject != null);
    _renderObject = null;
  }

  void _attach(RenderScrollPane renderObject) {
    assert(renderObject != null);
    assert(_renderObject == null);
    _renderObject = renderObject;
    scrollOffset = _renderObject._boundsCheckScrollOffset(scrollOffset);
  }
}

class ScrollPane extends StatefulWidget {
  const ScrollPane({
    Key key,
    this.horizontalScrollBarPolicy = ScrollBarPolicy.auto,
    this.verticalScrollBarPolicy = ScrollBarPolicy.auto,
    this.clipBehavior = Clip.hardEdge,
    this.scrollController,
    this.rowHeader,
    this.columnHeader,
    this.topLeftCorner = const _EmptyCorner(),
    this.bottomLeftCorner = const _EmptyCorner(),
    this.bottomRightCorner = const _EmptyCorner(),
    this.topRightCorner = const _EmptyCorner(),
    @required this.view,
  })  : assert(horizontalScrollBarPolicy != null),
        assert(verticalScrollBarPolicy != null),
        assert(view != null),
        super(key: key);

  /// The policy for how to lay the view out and show a scroll bar in the
  /// horizontal axis.
  ///
  /// Must be non-null. Defaults to [ScrollBarPolicy.auto].
  final ScrollBarPolicy horizontalScrollBarPolicy;

  /// The policy for how to lay the view out and show a scroll bar in the
  /// vertical axis.
  ///
  /// Must be non-null. Defaults to [ScrollBarPolicy.auto].
  final ScrollBarPolicy verticalScrollBarPolicy;

  /// The way in which [view], [rowHeader], and [columnHeader] will be clipped.
  ///
  /// A scroll pane's contents will always be clipped to the bounds of the
  /// scroll pane itself. The clip behavior determines how the contents will
  /// be clipped when they would otherwise overlap each other, the scroll bars,
  /// or the corners.
  ///
  /// Must be non-null; defaults to [Clip.hardEdge], which means that the
  /// contents of the scroll pane will never be painted over each other.
  final Clip clipBehavior;

  /// The controller responsible for managing the scroll offset of this widget.
  ///
  /// If this is not provided, one will be created and maintained automatically
  /// by this widget's [State] object.
  final ScrollController scrollController;

  /// Optional widget that will be laid out to the left of the view, vertically
  /// aligned with the top of the view.
  ///
  /// The row header will scroll vertically with the scroll pane, but it will
  /// remain fixed in place in the horizontal axis, even when the view is
  /// scrolled horizontally.
  final Widget rowHeader;

  /// Optional widget that will be laid out to the top of the view,
  /// horizontally aligned with the left of the view.
  ///
  /// The column header will scroll horizontally with the scroll pane, but it
  /// will remain fixed in place in the vertical axis, even when the view is
  /// scrolled vertically.
  final Widget columnHeader;

  /// Optional widget that will be laid out in the top left corner (above the
  /// row header and to the left of the column header).
  ///
  /// If [rowHeader] and [columnHeader] are not both specified, then there is
  /// no top left corner, and this widget will not be rendered.
  ///
  /// If this widget is not specified, and the row header and column header
  /// are non-null, then a default "empty" corner will be automatically
  /// created and laid out in this spot.
  final Widget topLeftCorner;

  /// Optional widget that will be laid out in the bottom left corner (below
  /// the row header and to the left of the horizontal scroll bar).
  ///
  /// If [rowHeader] is not specified or the horizontal scroll bar is not
  /// shown, then there is no bottom left corner, and this widget will not be
  /// rendered.
  ///
  /// If this widget is not specified, and a bottom left corner exists, then a
  /// default "empty" corner will be automatically created and laid out in this
  /// spot.
  final Widget bottomLeftCorner;

  /// Optional widget that will be laid out in the bottom right corner (below
  /// the vertical scroll bar and to the right of the horizontal scroll bar).
  ///
  /// If the scroll bars are not both shown, then there is no bottom right
  /// corner, and this widget will not be rendered.
  ///
  /// If this widget is not specified, and a bottom right corner exists, then a
  /// default "empty" corner will be automatically created and laid out in this
  /// spot.
  final Widget bottomRightCorner;

  /// Optional widget that will be laid out in the top right corner (above the
  /// vertical scroll bar and to the right of the column header).
  ///
  /// If [columnHeader] is not specified or the vertical scroll bar is not
  /// shown, then there is no top right corner, and this widget will not be
  /// rendered.
  ///
  /// If this widget is not specified, and a top right corner exists, then a
  /// default "empty" corner will be automatically created and laid out in this
  /// spot.
  final Widget topRightCorner;

  /// The main scrollable widget to be shown in the viewport of this scroll
  /// pane.
  final Widget view;

  @override
  _ScrollPaneState createState() => _ScrollPaneState();
}

class _ScrollPaneState extends State<ScrollPane> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _scrollController = ScrollController();
    }
  }

  @override
  void didUpdateWidget(ScrollPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) {
        assert(_scrollController != null);
        _scrollController.dispose();
        _scrollController = null;
      } else {
        assert(_scrollController == null);
        _scrollController = ScrollController();
      }
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollPane(
      view: widget.view,
      rowHeader: widget.rowHeader,
      columnHeader: widget.columnHeader,
      topLeftCorner: widget.topLeftCorner,
      bottomLeftCorner: widget.bottomLeftCorner,
      bottomRightCorner: widget.bottomRightCorner,
      topRightCorner: widget.topRightCorner,
      horizontalScrollBar: const ScrollBar(
        orientation: Axis.horizontal,
        unitIncrement: 10,
      ),
      verticalScrollBar: const ScrollBar(
        orientation: Axis.vertical,
        unitIncrement: 10,
      ),
      horizontalScrollBarPolicy: widget.horizontalScrollBarPolicy,
      verticalScrollBarPolicy: widget.verticalScrollBarPolicy,
      clipBehavior: widget.clipBehavior,
      scrollController: widget.scrollController ?? _scrollController,
    );
  }
}

class _EmptyCorner extends LeafRenderObjectWidget {
  const _EmptyCorner({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEmptyCorner();
}

class _RenderEmptyCorner extends RenderBox {
  static const Color backgroundColor = Color(0xfff0ece7);

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    context.canvas.drawRect(offset & size, paint);
  }
}

class _ScrollPane extends RenderObjectWidget {
  const _ScrollPane({
    Key key,
    @required this.view,
    @required this.rowHeader,
    @required this.columnHeader,
    @required this.topLeftCorner,
    @required this.bottomLeftCorner,
    @required this.bottomRightCorner,
    @required this.topRightCorner,
    @required this.horizontalScrollBar,
    @required this.verticalScrollBar,
    @required this.horizontalScrollBarPolicy,
    @required this.verticalScrollBarPolicy,
    @required this.clipBehavior,
    @required this.scrollController,
  })  : assert(view != null),
        assert(topLeftCorner != null),
        assert(bottomLeftCorner != null),
        assert(bottomRightCorner != null),
        assert(topRightCorner != null),
        assert(horizontalScrollBar != null),
        assert(verticalScrollBar != null),
        assert(horizontalScrollBarPolicy != null),
        assert(verticalScrollBarPolicy != null),
        assert(clipBehavior != null),
        assert(scrollController != null),
        super(key: key);

  final Widget view;
  final Widget rowHeader;
  final Widget columnHeader;
  final Widget topLeftCorner;
  final Widget bottomLeftCorner;
  final Widget bottomRightCorner;
  final Widget topRightCorner;
  final Widget horizontalScrollBar;
  final Widget verticalScrollBar;
  final ScrollBarPolicy horizontalScrollBarPolicy;
  final ScrollBarPolicy verticalScrollBarPolicy;
  final Clip clipBehavior;
  final ScrollController scrollController;

  @override
  RenderObjectElement createElement() => _ScrollPaneElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScrollPane(
      horizontalScrollBarPolicy: horizontalScrollBarPolicy,
      verticalScrollBarPolicy: verticalScrollBarPolicy,
      clipBehavior: clipBehavior,
      scrollController: scrollController,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderScrollPane renderScrollPane) {
    renderScrollPane
      ..horizontalScrollBarPolicy = horizontalScrollBarPolicy
      ..verticalScrollBarPolicy = verticalScrollBarPolicy
      ..clipBehavior = clipBehavior
      ..scrollController = scrollController;
  }
}

enum _ScrollPaneSlot {
  view,
  rowHeader,
  columnHeader,
  topLeftCorner,
  bottomLeftCorner,
  bottomRightCorner,
  topRightCorner,
  horizontalScrollBar,
  verticalScrollBar,
}

class _ScrollPaneElement extends RenderObjectElement {
  _ScrollPaneElement(_ScrollPane widget) : super(widget);

  Element _view;
  Element _rowHeader;
  Element _columnHeader;
  Element _topLeftCorner;
  Element _bottomLeftCorner;
  Element _bottomRightCorner;
  Element _topRightCorner;
  Element _horizontalScrollBar;
  Element _verticalScrollBar;

  @override
  _ScrollPane get widget => super.widget as _ScrollPane;

  @override
  RenderScrollPane get renderObject => super.renderObject as RenderScrollPane;

  @override
  void update(_ScrollPane newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _view = updateChild(_view, widget.view, _ScrollPaneSlot.view);
    _rowHeader = updateChild(_rowHeader, widget.rowHeader, _ScrollPaneSlot.rowHeader);
    _columnHeader = updateChild(_columnHeader, widget.columnHeader, _ScrollPaneSlot.columnHeader);
    _topLeftCorner = updateChild(_topLeftCorner, widget.topLeftCorner, _ScrollPaneSlot.topLeftCorner);
    _bottomLeftCorner = updateChild(_bottomLeftCorner, widget.bottomLeftCorner, _ScrollPaneSlot.bottomLeftCorner);
    _bottomRightCorner = updateChild(_bottomRightCorner, widget.bottomRightCorner, _ScrollPaneSlot.bottomRightCorner);
    _topRightCorner = updateChild(_topRightCorner, widget.topRightCorner, _ScrollPaneSlot.topRightCorner);
    _horizontalScrollBar =
        updateChild(_horizontalScrollBar, widget.horizontalScrollBar, _ScrollPaneSlot.horizontalScrollBar);
    _verticalScrollBar = updateChild(_verticalScrollBar, widget.verticalScrollBar, _ScrollPaneSlot.verticalScrollBar);
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    if (widget.view != null) _view = inflateWidget(widget.view, _ScrollPaneSlot.view);
    if (widget.rowHeader != null) _rowHeader = inflateWidget(widget.rowHeader, _ScrollPaneSlot.rowHeader);
    if (widget.columnHeader != null) _columnHeader = inflateWidget(widget.columnHeader, _ScrollPaneSlot.columnHeader);
    if (widget.topLeftCorner != null)
      _topLeftCorner = inflateWidget(widget.topLeftCorner, _ScrollPaneSlot.topLeftCorner);
    if (widget.bottomLeftCorner != null)
      _bottomLeftCorner = inflateWidget(widget.bottomLeftCorner, _ScrollPaneSlot.bottomLeftCorner);
    if (widget.bottomRightCorner != null)
      _bottomRightCorner = inflateWidget(widget.bottomRightCorner, _ScrollPaneSlot.bottomRightCorner);
    if (widget.topRightCorner != null)
      _topRightCorner = inflateWidget(widget.topRightCorner, _ScrollPaneSlot.topRightCorner);
    if (widget.horizontalScrollBar != null)
      _horizontalScrollBar = inflateWidget(widget.horizontalScrollBar, _ScrollPaneSlot.horizontalScrollBar);
    if (widget.verticalScrollBar != null)
      _verticalScrollBar = inflateWidget(widget.verticalScrollBar, _ScrollPaneSlot.verticalScrollBar);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    visitor(_view);
    if (_rowHeader != null) visitor(_rowHeader);
    if (_columnHeader != null) visitor(_columnHeader);
    if (_topLeftCorner != null) visitor(_topLeftCorner);
    if (_bottomLeftCorner != null) visitor(_bottomLeftCorner);
    if (_bottomRightCorner != null) visitor(_bottomRightCorner);
    if (_topRightCorner != null) visitor(_topRightCorner);
    if (_horizontalScrollBar != null) visitor(_horizontalScrollBar);
    if (_verticalScrollBar != null) visitor(_verticalScrollBar);
  }

  @override
  void insertChildRenderObject(RenderBox child, _ScrollPaneSlot slot) {
    switch (slot) {
      case _ScrollPaneSlot.view:
        renderObject.view = child;
        break;
      case _ScrollPaneSlot.rowHeader:
        renderObject.rowHeader = child;
        break;
      case _ScrollPaneSlot.columnHeader:
        renderObject.columnHeader = child;
        break;
      case _ScrollPaneSlot.topLeftCorner:
        renderObject.topLeftCorner = child;
        break;
      case _ScrollPaneSlot.bottomLeftCorner:
        renderObject.bottomLeftCorner = child;
        break;
      case _ScrollPaneSlot.bottomRightCorner:
        renderObject.bottomRightCorner = child;
        break;
      case _ScrollPaneSlot.topRightCorner:
        renderObject.topRightCorner = child;
        break;
      case _ScrollPaneSlot.horizontalScrollBar:
        renderObject.horizontalScrollBar = child;
        break;
      case _ScrollPaneSlot.verticalScrollBar:
        renderObject.verticalScrollBar = child;
        break;
    }
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slot) {
    throw UnsupportedError('moveChildRenderObject()');
  }

  @override
  void removeChildRenderObject(RenderBox child) {
    assert(child.parent == renderObject);
    throw UnimplementedError();
  }
}

// TODO do we get any benefit to this implementing RenderAbstractViewport?
// TODO It looks like RenderAbstractViewport would provide some benefit
class RenderScrollPane extends RenderBox {
  RenderScrollPane({
    ScrollBarPolicy horizontalScrollBarPolicy = ScrollBarPolicy.auto,
    ScrollBarPolicy verticalScrollBarPolicy = ScrollBarPolicy.auto,
    Clip clipBehavior = Clip.hardEdge,
    ScrollController scrollController,
  })  : assert(horizontalScrollBarPolicy != null),
        assert(verticalScrollBarPolicy != null),
        assert(clipBehavior != null),
        _horizontalScrollBarPolicy = horizontalScrollBarPolicy,
        _verticalScrollBarPolicy = verticalScrollBarPolicy,
        _clipBehavior = clipBehavior {
    _scrollBarValueListener = ScrollBarValueListener(valueChanged: _onScrollBarValueChanged);
    _scrollPaneListener = ScrollPaneListener(onScrollOffsetChanged: _onScrollOffsetChanged);
    this.scrollController = scrollController;
  }

  ScrollBarValueListener _scrollBarValueListener;
  ScrollPaneListener _scrollPaneListener;

  static const double _horizontalReveal = 30;
  static const double _verticalReveal = 30;
  static const int _maxLayoutPasses = 4;

  /// Returns an offset that is as close to to the proposed scroll offset
  /// while being within the legal bounds defined by this scroll pane.
  ///
  /// If the `horizontalScrollBarHeight` argument is not specified, the value
  /// will be taken from [horizontalScrollBar].
  ///
  /// If the `verticalScrollBarWidth` argument is not specified, the value
  /// will be taken from [verticalScrollBar].
  Offset _boundsCheckScrollOffset(
    Offset proposedScrollOffset, {
    double horizontalScrollBarHeight,
    double verticalScrollBarWidth,
  }) {
    return Offset(
      math.min(math.max(proposedScrollOffset.dx, 0), getMaxScrollLeft(verticalScrollBarWidth: verticalScrollBarWidth)),
      math.min(
          math.max(proposedScrollOffset.dy, 0), getMaxScrollTop(horizontalScrollBarHeight: horizontalScrollBarHeight)),
    );
  }

  /// Returns the maximum legal vertical scroll offset defined by this scroll
  /// pane.
  ///
  /// If the `horizontalScrollBarHeight` argument is not specified, the value
  /// will be taken from [horizontalScrollBar].
  double getMaxScrollTop({double horizontalScrollBarHeight}) {
    if (view == null) return 0;

    double viewHeight = view.size.height;
    double columnHeaderHeight = 0;
    double height = size.height;

    if (parentDataFor(horizontalScrollBar).visible) {
      horizontalScrollBarHeight ??= horizontalScrollBar.size.height;
    }
    horizontalScrollBarHeight ??= 0;

    if (columnHeader != null) columnHeaderHeight = columnHeader.size.height;
    final double viewportHeight = height - columnHeaderHeight - horizontalScrollBarHeight;
    return math.max(viewHeight - viewportHeight, 0);
  }

  /// Returns the maximum legal horizontal scroll offset defined by this scroll
  /// pane.
  ///
  /// If the `verticalScrollBarWidth` argument is not specified, the value
  /// will be taken from [verticalScrollBar].
  double getMaxScrollLeft({double verticalScrollBarWidth}) {
    if (view == null) return 0;

    double viewWidth = view.size.width;
    double rowHeaderWidth = 0;
    double width = size.width;

    if (parentDataFor(verticalScrollBar).visible) {
      verticalScrollBarWidth ??= verticalScrollBar.size.width;
    }
    verticalScrollBarWidth ??= 0;

    if (rowHeader != null) rowHeaderWidth = rowHeader.size.width;
    final double viewportWidth = width - rowHeaderWidth - verticalScrollBarWidth;
    return math.max(viewWidth - viewportWidth, 0);
  }

  ScrollBarPolicy _horizontalScrollBarPolicy;
  ScrollBarPolicy get horizontalScrollBarPolicy => _horizontalScrollBarPolicy;
  set horizontalScrollBarPolicy(ScrollBarPolicy value) {
    assert(value != null);
    if (_horizontalScrollBarPolicy == value) return;
    _horizontalScrollBarPolicy = value;
    markNeedsLayout();
  }

  ScrollBarPolicy _verticalScrollBarPolicy;
  ScrollBarPolicy get verticalScrollBarPolicy => _verticalScrollBarPolicy;
  set verticalScrollBarPolicy(ScrollBarPolicy value) {
    assert(value != null);
    if (_verticalScrollBarPolicy == value) return;
    _verticalScrollBarPolicy = value;
    markNeedsLayout();
  }

  Clip _clipBehavior = Clip.hardEdge;
  Clip get clipBehavior => _clipBehavior;
  set clipBehavior(Clip value) {
    assert(value != null);
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  ScrollController _scrollController;
  ScrollController get scrollController => _scrollController;
  set scrollController(ScrollController value) {
    assert(value != null);
    if (value == _scrollController) return;
    Offset previousScrollOffset;
    if (_scrollController != null) {
      previousScrollOffset = _scrollController.scrollOffset;
      _scrollController.removeListener(_scrollPaneListener);
      _scrollController._detach();
    }
    _scrollController = value;
    _scrollController._attach(this);
    _scrollController.addListener(_scrollPaneListener);
    if (_scrollController.scrollOffset != previousScrollOffset) {
      markNeedsLayout();
    }
  }

  Offset get scrollOffset {
    assert(scrollController != null);
    return scrollController.scrollOffset;
  }

  set scrollOffset(Offset value) {
    assert(scrollController != null);
    scrollController.scrollOffset = value;
  }

  RenderBox _view;
  RenderBox get view => _view;
  set view(RenderBox value) {
    if (_view != null) dropChild(_view);
    _view = value;
    if (_view != null) adoptChild(_view);
  }

  RenderBox _rowHeader;
  RenderBox get rowHeader => _rowHeader;
  set rowHeader(RenderBox value) {
    if (_rowHeader != null) dropChild(_rowHeader);
    _rowHeader = value;
    if (_rowHeader != null) adoptChild(_rowHeader);
  }

  RenderBox _columnHeader;
  RenderBox get columnHeader => _columnHeader;
  set columnHeader(RenderBox value) {
    if (_columnHeader != null) dropChild(_columnHeader);
    _columnHeader = value;
    if (_columnHeader != null) adoptChild(_columnHeader);
  }

  RenderBox _topLeftCorner;
  RenderBox get topLeftCorner => _topLeftCorner;
  set topLeftCorner(RenderBox value) {
    if (_topLeftCorner != null) dropChild(_topLeftCorner);
    _topLeftCorner = value;
    if (_topLeftCorner != null) adoptChild(_topLeftCorner);
  }

  RenderBox _bottomLeftCorner;
  RenderBox get bottomLeftCorner => _bottomLeftCorner;
  set bottomLeftCorner(RenderBox value) {
    if (_bottomLeftCorner != null) dropChild(_bottomLeftCorner);
    _bottomLeftCorner = value;
    if (_bottomLeftCorner != null) adoptChild(_bottomLeftCorner);
  }

  RenderBox _bottomRightCorner;
  RenderBox get bottomRightCorner => _bottomRightCorner;
  set bottomRightCorner(RenderBox value) {
    if (_bottomRightCorner != null) dropChild(_bottomRightCorner);
    _bottomRightCorner = value;
    if (_bottomRightCorner != null) adoptChild(_bottomRightCorner);
  }

  RenderBox _topRightCorner;
  RenderBox get topRightCorner => _topRightCorner;
  set topRightCorner(RenderBox value) {
    if (_topRightCorner != null) dropChild(_topRightCorner);
    _topRightCorner = value;
    if (_topRightCorner != null) adoptChild(_topRightCorner);
  }

  RenderScrollBar _horizontalScrollBar;
  RenderScrollBar get horizontalScrollBar => _horizontalScrollBar;
  set horizontalScrollBar(RenderScrollBar value) {
    if (_horizontalScrollBar != null) {
      value.removeListener(_scrollBarValueListener);
      dropChild(_horizontalScrollBar);
    }
    _horizontalScrollBar = value;
    if (_horizontalScrollBar != null) {
      adoptChild(_horizontalScrollBar);
      value.addListener(_scrollBarValueListener);
    }
  }

  RenderScrollBar _verticalScrollBar;
  RenderScrollBar get verticalScrollBar => _verticalScrollBar;
  set verticalScrollBar(RenderScrollBar value) {
    if (_verticalScrollBar != null) {
      value.removeListener(_scrollBarValueListener);
      dropChild(_verticalScrollBar);
    }
    _verticalScrollBar = value;
    if (_verticalScrollBar != null) {
      adoptChild(_verticalScrollBar);
      value.addListener(_scrollBarValueListener);
    }
  }

  void _onScrollBarValueChanged(RenderScrollBar scrollBar, double previousValue) {
    double value = scrollBar.value;
    if (scrollBar == horizontalScrollBar) {
      scrollOffset = Offset(value, scrollOffset.dy);
    } else {
      scrollOffset = Offset(scrollOffset.dx, value);
    }
  }

  bool _updatingScrollOffsetDuringLayout = false;

  void _onScrollOffsetChanged(ScrollController controller, Offset previousScrollOffset) {
    assert(controller == _scrollController);
    assert(controller.scrollOffset != null);
    assert(controller.scrollOffset != previousScrollOffset);
    if (!_updatingScrollOffsetDuringLayout) {
      final Offset value = controller.scrollOffset;
      assert(!attached || value == _boundsCheckScrollOffset(value));
      horizontalScrollBar.value = value.dx;
      verticalScrollBar.value = value.dy;
      markNeedsLayout();
    }
  }

  void _onPointerScroll(PointerScrollEvent event) {
    scrollOffset = Offset(
      scrollOffset.dx + event.scrollDelta.dx,
      scrollOffset.dy + event.scrollDelta.dy,
    );
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerScrollEvent) return _onPointerScroll(event);
    super.handleEvent(event, entry);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (view != null) view.attach(owner);
    if (rowHeader != null) rowHeader.attach(owner);
    if (columnHeader != null) columnHeader.attach(owner);
    if (topLeftCorner != null) topLeftCorner.attach(owner);
    if (bottomLeftCorner != null) bottomLeftCorner.attach(owner);
    if (bottomRightCorner != null) bottomRightCorner.attach(owner);
    if (topRightCorner != null) topRightCorner.attach(owner);
    if (horizontalScrollBar != null) horizontalScrollBar.attach(owner);
    if (verticalScrollBar != null) verticalScrollBar.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (view != null) view.detach();
    if (rowHeader != null) rowHeader.detach();
    if (columnHeader != null) columnHeader.detach();
    if (topLeftCorner != null) topLeftCorner.detach();
    if (bottomLeftCorner != null) bottomLeftCorner.detach();
    if (bottomRightCorner != null) bottomRightCorner.detach();
    if (topRightCorner != null) topRightCorner.detach();
    if (horizontalScrollBar != null) horizontalScrollBar.detach();
    if (verticalScrollBar != null) verticalScrollBar.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (view != null) visitor(view);
    if (rowHeader != null) visitor(rowHeader);
    if (columnHeader != null) visitor(columnHeader);
    if (topLeftCorner != null) visitor(topLeftCorner);
    if (bottomLeftCorner != null) visitor(bottomLeftCorner);
    if (bottomRightCorner != null) visitor(bottomRightCorner);
    if (topRightCorner != null) visitor(topRightCorner);
    if (horizontalScrollBar != null) visitor(horizontalScrollBar);
    if (verticalScrollBar != null) visitor(verticalScrollBar);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    final List<RenderBox> children = <RenderBox>[
      verticalScrollBar,
      horizontalScrollBar,
      topRightCorner,
      bottomRightCorner,
      bottomLeftCorner,
      topLeftCorner,
      columnHeader,
      rowHeader,
      view,
    ];

    for (RenderBox child in children) {
      if (child != null) {
        final _ScrollPaneParentData parentData = child.parentData;
        if (parentData.visible) {
          final bool isHit = result.addWithPaintOffset(
            offset: parentData.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset transformed) {
              assert(transformed == position - parentData.offset);
              return child.hitTest(result, position: transformed);
            },
          );

          // We know that RenderScrollPane doesn't overlap its children, so if
          // one child had a hit, it precludes other children from having had a
          // hit. Thus we can stop looking for hits after one child reports a hit.
          if (isHit) {
            return true;
          }
        }
      }
    }

    return false;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  _ScrollPaneParentData parentDataFor(RenderBox child) => child.parentData;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ScrollPaneParentData) child.parentData = _ScrollPaneParentData();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double preferredWidth = 0;

    if (view != null) {
      double preferredRowHeaderWidth = 0;
      if (rowHeader != null) {
        preferredRowHeaderWidth = rowHeader.getMinIntrinsicWidth(double.infinity);
      }

      double preferredColumnHeaderHeight = 0;
      if (columnHeader != null) {
        preferredColumnHeaderHeight = columnHeader.getMinIntrinsicHeight(double.infinity);
      }

      ScrollBarPolicy verticalPolicy = verticalScrollBarPolicy;

      if (verticalPolicy != ScrollBarPolicy.stretch) {
        // Get the unconstrained preferred size of the view
        double preferredViewWidth = view.getMinIntrinsicWidth(double.infinity);
        double preferredViewHeight = view.getMinIntrinsicHeight(double.infinity);

        // If the policy is `expand`, and the sum of the
        // unconstrained preferred heights of the view and the column
        // header is less than the height constraint, apply the `stretch`
        // policy; otherwise, apply the `auto` policy

        if (verticalPolicy == ScrollBarPolicy.expand) {
          if (height < 0) {
            verticalPolicy = ScrollBarPolicy.auto;
          } else {
            double preferredHeight = preferredViewHeight + preferredColumnHeaderHeight;

            if (preferredHeight < height) {
              verticalPolicy = ScrollBarPolicy.stretch;
            } else {
              verticalPolicy = ScrollBarPolicy.auto;
            }
          }
        }

        // If the policy is `always`, `never`, or `auto`, the preferred
        // width is the sum of the unconstrained preferred widths of
        // the view and row header, plus the width of the scroll
        // bar if policy is `always` or if the view's preferred height is
        // greater than the height constraint and the policy is `auto`

        if (verticalPolicy == ScrollBarPolicy.always ||
            verticalPolicy == ScrollBarPolicy.never ||
            verticalPolicy == ScrollBarPolicy.auto) {
          preferredWidth = preferredViewWidth + preferredRowHeaderWidth;

          // If the sum of the preferred heights of the view and the
          // column header is greater than the height constraint,
          // include the preferred width of the scroll bar in the
          // preferred width calculation
          if (verticalPolicy == ScrollBarPolicy.always ||
              (verticalPolicy == ScrollBarPolicy.auto &&
                  height > 0 &&
                  preferredViewHeight + preferredColumnHeaderHeight > height)) {
            preferredWidth += verticalScrollBar.getMinIntrinsicWidth(double.infinity);
          }
        }
      }

      if (verticalPolicy == ScrollBarPolicy.stretch) {
        // Preferred width is the sum of the constrained preferred
        // width of the view and the unconstrained preferred width of
        // the row header

        if (height >= 0) {
          // Subtract the unconstrained preferred height of the
          // column header from the height constraint
          height = math.max(height - preferredColumnHeaderHeight, 0);
        }

        preferredWidth = view.getMinIntrinsicWidth(height) + preferredRowHeaderWidth;
      }
    }

    return preferredWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) => computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    double preferredHeight = 0;

    if (view != null) {
      double preferredRowHeaderWidth = 0;
      if (rowHeader != null) {
        preferredRowHeaderWidth = rowHeader.getMinIntrinsicWidth(double.infinity);
      }

      double preferredColumnHeaderHeight = 0;
      if (columnHeader != null) {
        preferredColumnHeaderHeight = columnHeader.getMinIntrinsicHeight(double.infinity);
      }

      ScrollBarPolicy horizontalPolicy = horizontalScrollBarPolicy;

      if (horizontalPolicy != ScrollBarPolicy.stretch) {
        // Get the unconstrained preferred size of the view
        double preferredViewWidth = view.getMinIntrinsicWidth(double.infinity);
        double preferredViewHeight = view.getMinIntrinsicHeight(double.infinity);

        // If the policy is `expand`, and the sum of the
        // unconstrained preferred widths of the view and the row
        // header is less than the width constraint, apply the `stretch`
        // policy; otherwise, apply the `auto` policy

        if (horizontalPolicy == ScrollBarPolicy.expand) {
          if (width < 0) {
            horizontalPolicy = ScrollBarPolicy.auto;
          } else {
            double preferredWidth = preferredViewWidth + preferredRowHeaderWidth;

            if (preferredWidth < width) {
              horizontalPolicy = ScrollBarPolicy.stretch;
            } else {
              horizontalPolicy = ScrollBarPolicy.auto;
            }
          }
        }

        // If the policy is `always`, `never`, or `auto`, the preferred
        // height is the sum of the unconstrained preferred heights of
        // the view and column header, plus the height of the scroll
        // bar if policy is `always` or if the view's preferred width is
        // greater than the width constraint and the policy is `auto`

        if (horizontalPolicy == ScrollBarPolicy.always ||
            horizontalPolicy == ScrollBarPolicy.never ||
            horizontalPolicy == ScrollBarPolicy.auto) {
          preferredHeight = preferredViewHeight + preferredColumnHeaderHeight;

          // If the sum of the preferred widths of the view and the
          // row header is greater than the width constraint, include
          // the preferred height of the scroll bar in the preferred
          // height calculation
          if (horizontalPolicy == ScrollBarPolicy.always ||
              (horizontalPolicy == ScrollBarPolicy.auto &&
                  width > 0 &&
                  preferredViewWidth + preferredRowHeaderWidth > width)) {
            preferredHeight += horizontalScrollBar.getMinIntrinsicHeight(double.infinity);
          }
        }
      }

      if (horizontalPolicy == ScrollBarPolicy.stretch) {
        // Preferred height is the sum of the constrained preferred height
        // of the view and the unconstrained preferred height of the column
        // header

        if (width >= 0) {
          // Subtract the unconstrained preferred width of the row header
          // from the width constraint
          width = math.max(width - preferredRowHeaderWidth, 0);
        }

        preferredHeight = view.getMinIntrinsicHeight(width) + preferredColumnHeaderHeight;
      }
    }

    return preferredHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  void performLayout() {
    if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      size = constraints.biggest;
    } else if (constraints.hasBoundedWidth) {
      final double width = constraints.constrainWidth();
      final double height = constraints.constrainHeight(getMinIntrinsicHeight(width));
      size = Size(width, height);
    } else if (constraints.hasBoundedHeight) {
      final double height = constraints.constrainHeight();
      final double width = constraints.constrainWidth(getMinIntrinsicWidth(height));
      size = Size(width, height);
    } else {
      final double width = constraints.constrainWidth(getMinIntrinsicWidth(double.infinity));
      final double height = constraints.constrainHeight(getMinIntrinsicHeight(double.infinity));
      size = Size(width, height);
    }

    final double width = size.width;
    final double height = size.height;

    double rowHeaderWidth = 0;
    if (rowHeader != null) {
      rowHeaderWidth = rowHeader.getMaxIntrinsicWidth(double.infinity);
    }

    double columnHeaderHeight = 0;
    if (columnHeader != null) {
      columnHeaderHeight = columnHeader.getMaxIntrinsicHeight(double.infinity);
    }

    double viewWidth = 0;
    double viewHeight = 0;
    double previousHorizontalScrollBarHeight;
    double horizontalScrollBarHeight = _cachedHorizontalScrollBarHeight;
    double previousVerticalScrollBarWidth;
    double verticalScrollBarWidth = _cachedVerticalScrollBarWidth;
    int i = 0;

    bool scrollBarSizesChanged() {
      return horizontalScrollBarHeight != previousHorizontalScrollBarHeight ||
          verticalScrollBarWidth != previousVerticalScrollBarWidth;
    }

    do {
      previousHorizontalScrollBarHeight = horizontalScrollBarHeight;
      previousVerticalScrollBarWidth = verticalScrollBarWidth;
      final double viewportWidth = math.max(width - rowHeaderWidth - verticalScrollBarWidth, 0);
      final double viewportHeight = math.max(height - columnHeaderHeight - horizontalScrollBarHeight, 0);

      if (view != null) {
        double minWidth = 0;
        double maxWidth = double.infinity;
        double minHeight = 0;
        double maxHeight = double.infinity;

        switch (horizontalScrollBarPolicy) {
          case ScrollBarPolicy.stretch:
            minWidth = maxWidth = viewportWidth;
            break;
          case ScrollBarPolicy.expand:
            minWidth = viewportWidth;
            break;
          case ScrollBarPolicy.always:
          case ScrollBarPolicy.auto:
          case ScrollBarPolicy.never:
          // Unbounded width constraints
        }

        switch (verticalScrollBarPolicy) {
          case ScrollBarPolicy.stretch:
            minHeight = maxHeight = viewportHeight;
            break;
          case ScrollBarPolicy.expand:
            minHeight = viewportHeight;
            break;
          case ScrollBarPolicy.always:
          case ScrollBarPolicy.auto:
          case ScrollBarPolicy.never:
          // Unbounded height constraints
        }

        final Rect viewport = scrollOffset & Size(viewportWidth, viewportHeight);
        final SegmentConstraints viewConstraints = SegmentConstraints.fromBoxConstraints(
          viewport: viewport,
          boxConstraints: BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
        );
        view.layout(viewConstraints, parentUsesSize: true);
        viewWidth = view.size.width;
        viewHeight = view.size.height;
      }

      if (horizontalScrollBarPolicy == ScrollBarPolicy.always ||
          (horizontalScrollBarPolicy == ScrollBarPolicy.auto && viewWidth > viewportWidth) ||
          (horizontalScrollBarPolicy == ScrollBarPolicy.expand && viewWidth > viewportWidth)) {
        horizontalScrollBarHeight = horizontalScrollBar.getMinIntrinsicHeight(double.infinity);
      } else {
        horizontalScrollBarHeight = 0;
      }

      if (verticalScrollBarPolicy == ScrollBarPolicy.always ||
          (verticalScrollBarPolicy == ScrollBarPolicy.auto && viewHeight > viewportHeight) ||
          (verticalScrollBarPolicy == ScrollBarPolicy.expand && viewHeight > viewportHeight)) {
        verticalScrollBarWidth = verticalScrollBar.getMinIntrinsicWidth(double.infinity);
      } else {
        verticalScrollBarWidth = 0;
      }
    } while (++i <= RenderScrollPane._maxLayoutPasses && scrollBarSizesChanged());

    if (i > RenderScrollPane._maxLayoutPasses) {
      assert(() {
        throw FlutterError('A RenderScrollPane exceeded its maximum number of layout cycles.\n'
            'RenderScrollPane render objects, during layout, can retry if the introduction '
            'of scrollbars changes the constraints for one of its children.\n'
            'In the case of this RenderScrollPane object, however, this happened $RenderScrollPane._maxLayoutPasses '
            'times and still there was no consensus on the constraints. This usually '
            'indicates a bug.');
      }());
    }

    if (columnHeader != null) {
      final BoxConstraints boxConstraints = BoxConstraints.tightFor(width: viewWidth, height: columnHeaderHeight);
      final Offset segmentOffset = Offset(scrollOffset.dx, 0);
      final Size segmentSize = Size(viewWidth, columnHeaderHeight);
      final Rect viewport = segmentOffset & segmentSize;
      final SegmentConstraints constraints2 = SegmentConstraints.fromBoxConstraints(
        boxConstraints: boxConstraints,
        viewport: viewport,
      );
      columnHeader.layout(constraints2, parentUsesSize: true);
    }

    if (rowHeader != null) {
      final BoxConstraints boxConstraints = BoxConstraints.tightFor(width: rowHeaderWidth, height: viewHeight);
      final Offset segmentOffset = Offset(0, scrollOffset.dy);
      final Size segmentSize = Size(rowHeaderWidth, viewHeight);
      final Rect viewport = segmentOffset & segmentSize;
      final SegmentConstraints constraints2 = SegmentConstraints.fromBoxConstraints(
        boxConstraints: boxConstraints,
        viewport: viewport,
      );
      rowHeader.layout(constraints2, parentUsesSize: true);
    }

    _ScrollPaneParentData horizontalScrollBarParentData = parentDataFor(horizontalScrollBar);
    if (horizontalScrollBarHeight > 0) {
      horizontalScrollBarParentData.visible = true;
      horizontalScrollBarParentData.offset = Offset(rowHeaderWidth, height - horizontalScrollBarHeight);
    } else {
      horizontalScrollBarParentData.visible = false;
    }

    _ScrollPaneParentData verticalScrollBarParentData = parentDataFor(verticalScrollBar);
    if (verticalScrollBarWidth > 0) {
      verticalScrollBarParentData.visible = true;
      verticalScrollBarParentData.offset = Offset(width - verticalScrollBarWidth, columnHeaderHeight);
    } else {
      verticalScrollBarParentData.visible = false;
    }

    // Handle corner components

    if (columnHeaderHeight > 0 && rowHeaderWidth > 0) {
      _ScrollPaneParentData parentData2 = parentDataFor(topLeftCorner);
      parentData2.offset = Offset.zero;
      parentData2.visible = true;
      topLeftCorner.layout(BoxConstraints.tightFor(width: rowHeaderWidth, height: columnHeaderHeight));
    } else {
      topLeftCorner.layout(BoxConstraints.tight(Size.zero));
      parentDataFor(topLeftCorner).visible = false;
    }

    if (rowHeaderWidth > 0 && horizontalScrollBarHeight > 0) {
      _ScrollPaneParentData parentData2 = parentDataFor(bottomLeftCorner);
      parentData2.offset = Offset(0, height - horizontalScrollBarHeight);
      parentData2.visible = true;
      bottomLeftCorner.layout(BoxConstraints.tightFor(width: rowHeaderWidth, height: horizontalScrollBarHeight));
    } else {
      bottomLeftCorner.layout(BoxConstraints.tight(Size.zero));
      parentDataFor(bottomLeftCorner).visible = false;
    }

    if (verticalScrollBarWidth > 0 && horizontalScrollBarHeight > 0) {
      _ScrollPaneParentData parentData2 = parentDataFor(bottomRightCorner);
      parentData2.offset = Offset(width - verticalScrollBarWidth, height - horizontalScrollBarHeight);
      parentData2.visible = true;
      bottomRightCorner
          .layout(BoxConstraints.tightFor(width: verticalScrollBarWidth, height: horizontalScrollBarHeight));
    } else {
      bottomRightCorner.layout(BoxConstraints.tight(Size.zero));
      parentDataFor(bottomRightCorner).visible = false;
    }

    if (columnHeaderHeight > 0 && verticalScrollBarWidth > 0) {
      _ScrollPaneParentData parentData2 = parentDataFor(topRightCorner);
      parentData2.offset = Offset(width - verticalScrollBarWidth, 0);
      parentData2.visible = true;
      topRightCorner.layout(BoxConstraints.tightFor(width: verticalScrollBarWidth, height: columnHeaderHeight));
    } else {
      topRightCorner.layout(BoxConstraints.tight(Size.zero));
      parentDataFor(topRightCorner).visible = false;
    }

    // Perform bounds checking on the scrollTop and scrollLeft values,
    // and adjust them as necessary. Make sure to do this after we've laid
    // everything out, since our maxScrollXYZ methods rely on valid
    // sizes from our components.

    scrollController._skipBoundscheck(() {
      _updatingScrollOffsetDuringLayout = true;
      try {
        scrollController.scrollOffset = _boundsCheckScrollOffset(
          scrollOffset,
          horizontalScrollBarHeight: horizontalScrollBarHeight,
          verticalScrollBarWidth: verticalScrollBarWidth,
        );
      } finally {
        _updatingScrollOffsetDuringLayout = false;
      }
    });

    if (view != null) {
      _ScrollPaneParentData parentData = parentDataFor(view);
      parentData.offset = Offset(rowHeaderWidth - scrollOffset.dx, columnHeaderHeight - scrollOffset.dy);
      parentData.visible = true;
    }

    if (columnHeader != null) {
      _ScrollPaneParentData parentData = parentDataFor(columnHeader);
      parentData.offset = Offset(rowHeaderWidth - scrollOffset.dx, 0);
      parentData.visible = true;
    }

    if (rowHeader != null) {
      _ScrollPaneParentData parentData = parentDataFor(rowHeader);
      parentData.offset = Offset(0, columnHeaderHeight - scrollOffset.dy);
      parentData.visible = true;
    }

    // Adjust the structure of our scroll bars. Make sure to do this after
    // we adjust the scrollTop and scrollLeft values; otherwise we might
    // try to set structure values that are out of bounds.

    if (viewWidth > 0 && horizontalScrollBarHeight > 0) {
      final double viewportWidth = math.max(width - rowHeaderWidth - verticalScrollBarWidth, 0);
      final double horizontalScrollBarWidth = math.max(width - rowHeaderWidth - verticalScrollBarWidth, 0);
      final double extent = math.min(viewWidth, viewportWidth);
      horizontalScrollBar.blockIncrement = math.max(1, viewportWidth - RenderScrollPane._horizontalReveal);
      horizontalScrollBar.layout(
        ScrollBarConstraints.fromBoxConstraints(
          boxConstraints: BoxConstraints.tightFor(width: horizontalScrollBarWidth, height: horizontalScrollBarHeight),
          enabled: !(scrollOffset.dx == 0 && extent == viewWidth),
          start: 0,
          end: viewWidth,
          value: scrollOffset.dx,
          extent: extent,
        ),
        parentUsesSize: true,
      );
    } else {
      horizontalScrollBar.layout(
        ScrollBarConstraints.fromBoxConstraints(
          boxConstraints: BoxConstraints.tight(Size.zero),
          enabled: horizontalScrollBar.enabled,
          start: horizontalScrollBar.start,
          end: horizontalScrollBar.end,
          value: horizontalScrollBar.value,
          extent: horizontalScrollBar.extent,
        ),
        parentUsesSize: true,
      );
    }

    if (viewHeight > 0 && verticalScrollBarWidth > 0) {
      final double viewportHeight = math.max(height - columnHeaderHeight - horizontalScrollBarHeight, 0);
      final double verticalScrollBarHeight = math.max(height - columnHeaderHeight - horizontalScrollBarHeight, 0);
      final double extent = math.min(viewHeight, viewportHeight);
      verticalScrollBar.blockIncrement = math.max(1, viewportHeight - RenderScrollPane._verticalReveal);
      verticalScrollBar.layout(
        ScrollBarConstraints.fromBoxConstraints(
          boxConstraints: BoxConstraints.tightFor(width: verticalScrollBarWidth, height: verticalScrollBarHeight),
          enabled: !(scrollOffset.dy == 0 && extent == viewHeight),
          start: 0,
          end: viewHeight,
          value: scrollOffset.dy,
          extent: extent,
        ),
        parentUsesSize: true,
      );
    } else {
      verticalScrollBar.layout(
        ScrollBarConstraints.fromBoxConstraints(
          boxConstraints: BoxConstraints.tight(Size.zero),
          enabled: verticalScrollBar.enabled,
          start: verticalScrollBar.start,
          end: verticalScrollBar.end,
          value: verticalScrollBar.value,
          extent: verticalScrollBar.extent,
        ),
        parentUsesSize: true,
      );
    }

    _cachedHorizontalScrollBarHeight = horizontalScrollBar.size.height;
    _cachedVerticalScrollBarWidth = verticalScrollBar.size.width;
  }

  double _cachedHorizontalScrollBarHeight = 0;
  double _cachedVerticalScrollBarWidth = 0;

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, _paintChildren);
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    double rowHeaderWidth = rowHeader?.size?.width ?? 0;
    double columnHeaderHeight = columnHeader?.size?.height ?? 0;
    double viewportWidth = size.width - rowHeaderWidth - verticalScrollBar.size.width;
    double viewportHeight = size.height - columnHeaderHeight - horizontalScrollBar.size.height;

    if (view != null) {
      final _ScrollPaneParentData viewParentData = parentDataFor(view);
      if (_clipBehavior == Clip.none) {
        context.paintChild(view, offset + viewParentData.offset);
      } else {
        Rect clipRect = Rect.fromLTWH(rowHeaderWidth, columnHeaderHeight, viewportWidth, viewportHeight).shift(offset);
        context.clipRectAndPaint(clipRect, _clipBehavior, clipRect, () {
          context.paintChild(view, offset + viewParentData.offset);
        });
      }
    }

    if (rowHeader != null) {
      final _ScrollPaneParentData rowHeaderParentData = parentDataFor(rowHeader);
      if (rowHeaderParentData.visible) {
        if (_clipBehavior == Clip.none) {
          context.paintChild(rowHeader, offset + rowHeaderParentData.offset);
        } else {
          Rect clipRect = Rect.fromLTWH(0, columnHeaderHeight, rowHeaderWidth, viewportHeight).shift(offset);
          context.clipRectAndPaint(clipRect, _clipBehavior, clipRect, () {
            context.paintChild(rowHeader, offset + rowHeaderParentData.offset);
          });
        }
      }
    }

    if (columnHeader != null) {
      final _ScrollPaneParentData columnHeaderParentData = parentDataFor(columnHeader);
      if (columnHeaderParentData.visible) {
        if (_clipBehavior == Clip.none) {
          context.paintChild(columnHeader, offset + columnHeaderParentData.offset);
        } else {
          Rect clipRect = Rect.fromLTWH(rowHeaderWidth, 0, viewportWidth, columnHeaderHeight).shift(offset);
          context.clipRectAndPaint(clipRect, _clipBehavior, clipRect, () {
            context.paintChild(columnHeader, offset + columnHeaderParentData.offset);
          });
        }
      }
    }

    _ScrollPaneParentData horizontalScrollBarParentData = parentDataFor(horizontalScrollBar);
    if (horizontalScrollBarParentData.visible) {
      context.paintChild(horizontalScrollBar, offset + horizontalScrollBarParentData.offset);
    }

    _ScrollPaneParentData verticalScrollBarParentData = parentDataFor(verticalScrollBar);
    if (verticalScrollBarParentData.visible) {
      context.paintChild(verticalScrollBar, offset + verticalScrollBarParentData.offset);
    }

    _ScrollPaneParentData topLeftCornerParentData = parentDataFor(topLeftCorner);
    if (topLeftCornerParentData.visible) {
      context.paintChild(topLeftCorner, offset + topLeftCornerParentData.offset);
    }

    _ScrollPaneParentData bottomLeftCornerParentData = parentDataFor(bottomLeftCorner);
    if (bottomLeftCornerParentData.visible) {
      context.paintChild(bottomLeftCorner, offset + bottomLeftCornerParentData.offset);
    }

    _ScrollPaneParentData bottomRightCornerParentData = parentDataFor(bottomRightCorner);
    if (bottomRightCornerParentData.visible) {
      context.paintChild(bottomRightCorner, offset + bottomRightCornerParentData.offset);
    }

    _ScrollPaneParentData topRightCornerParentData = parentDataFor(topRightCorner);
    if (topRightCornerParentData.visible) {
      context.paintChild(topRightCorner, offset + topRightCornerParentData.offset);
    }
  }

  @override
  void redepthChildren() {
    if (view != null) redepthChild(view);
    if (rowHeader != null) redepthChild(rowHeader);
    if (columnHeader != null) redepthChild(columnHeader);
    if (topLeftCorner != null) redepthChild(topLeftCorner);
    if (bottomLeftCorner != null) redepthChild(bottomLeftCorner);
    if (bottomRightCorner != null) redepthChild(bottomRightCorner);
    if (topRightCorner != null) redepthChild(topRightCorner);
    if (horizontalScrollBar != null) redepthChild(horizontalScrollBar);
    if (verticalScrollBar != null) redepthChild(verticalScrollBar);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> result = <DiagnosticsNode>[];
    void add(RenderBox child, String name) {
      if (child != null) result.add(child.toDiagnosticsNode(name: name));
    }

    add(view, 'view');
    add(rowHeader, 'rowHeader');
    add(columnHeader, 'columnHeader');
    add(topLeftCorner, 'topLeftCorner');
    add(bottomLeftCorner, 'bottomLeftCorner');
    add(bottomRightCorner, 'bottomRightCorner');
    add(topRightCorner, 'topRightCorner');
    add(horizontalScrollBar, 'horizontalScrollBar');
    add(verticalScrollBar, 'verticalScrollBar');
    return result;
  }
}

class _ScrollPaneParentData extends BoxParentData {
  bool _visible = true;
  bool get visible => _visible;
  set visible(bool value) {
    assert(value != null);
    _visible = value;
  }
}
