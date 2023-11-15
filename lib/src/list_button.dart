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

import 'basic_list_view.dart';
import 'foundation.dart';
import 'list_view.dart';
import 'widget_surveyor.dart';

/// Enum that specifies how a [ListButton] will calculate its width.
enum ListButtonWidth {
  /// Specification of [ListButton] width that causes the button to adopt the
  /// intrinsic width of the currently selected item.
  ///
  /// This specification will cause the button width to change as different
  /// items are selected, if those items have different intrinsic widths.
  ///
  /// Along with [expand], this specification is the fastest in  runtime
  /// efficiency because it doesn't need to pre-calculate the intrinsic widths
  /// of the list button's items.
  shrinkWrapCurrentItem,

  /// Specification of [ListButton] width that causes the button to adopt the
  /// largest intrinsic width of _all_ the button's items.
  ///
  /// This specification will yield a stable button width. As the selected item
  /// changes, the button width will always be at least as wide as it needs to
  /// be, sometimes wider.
  ///
  /// This specification is relatively expensive in runtime efficiency, because
  /// it requires pre-calculating the unconstrained widths of the list button's
  /// items.
  ///
  /// This will cause the list button's [ListButton.builder] to be invoked for
  /// every one of the button's list items in order to measure their widths.
  /// The list button element will be passed as the build context. When this
  /// measurement is taken, the widgets will be rendered in a synthetic widget
  /// tree that doesn't contain the normal application widget ancestry. If any
  /// of those widgets depend on inherited widgets in their ancestry, this
  /// measurement will fail.
  shrinkWrapAllItems,

  /// Specification of [ListButton] width that causes the button to adopt the
  /// widest possible width given the constraints passed to the list button.
  ///
  /// This specification will cause the button width to remain stable as long
  /// as the input constraints remain stable.
  ///
  /// Along with [shrinkWrapCurrentItem], this specification is the fastest in
  /// runtime efficiency because it doesn't need to pre-calculate the intrinsic
  /// widths of the list button's items.
  expand,
}

typedef ListButtonBuilder<T> = Widget Function(
  BuildContext context,
  T? item,
  bool isForMeasurementOnly,
);

typedef ListButtonItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
  bool isHighlighted,
  bool isDisabled,
);

class ListButton<T> extends StatefulWidget {
  ListButton({
    Key? key,
    required this.items,
    this.builder = defaultBuilder,
    this.itemBuilder = defaultItemBuilder,
    this.width = ListButtonWidth.shrinkWrapCurrentItem,
    this.selectionController,
    this.disabledItemFilter,
    this.isEnabled = true,
    this.roundToWholePixel = false,
  })  : assert(selectionController == null || selectionController.selectMode == SelectMode.single),
        super(key: key);

  final List<T> items;
  final ListButtonBuilder<T> builder;
  final ListButtonItemBuilder<T> itemBuilder;
  final ListButtonWidth width;
  final ListViewSelectionController? selectionController;
  final Predicate<T>? disabledItemFilter;
  final bool isEnabled;
  final bool roundToWholePixel;

  static Widget defaultBuilder(BuildContext context, Object? item, bool isForMeasurementOnly) {
    if (item == null) {
      return Container();
    }
    final TextStyle style = DefaultTextStyle.of(context).style;
    final TextDirection textDirection = Directionality.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 1),
      child: Text(
        '$item',
        maxLines: 1,
        softWrap: false,
        textDirection: textDirection,
        style: style,
      ),
    );
  }

  static Widget defaultItemBuilder(
    BuildContext context,
    Object? item,
    bool isSelected,
    bool isHighlighted,
    bool isDisabled,
  ) {
    TextStyle style = DefaultTextStyle.of(context).style;
    if (isSelected) {
      style = style.copyWith(color: const Color(0xffffffff));
    }
    if (isDisabled) {
      style = style.copyWith(color: const Color(0xff999999));
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 75),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        child: Text('$item', style: style),
      ),
    );
  }

  static ListButtonBuilder<Map<K, V>> mapBuilderFor<K, V>(K key) {
    return (BuildContext context, Map<K, V>? item, bool isForMeasurementOnly) {
      return defaultBuilder(
        context,
        item == null ? null : item[key],
        isForMeasurementOnly,
      );
    };
  }

  static ListButtonItemBuilder<Map<K, V>> mapItemBuilderFor<K, V>(K key) {
    return (
      BuildContext context,
      Map<K, V> item,
      bool isSelected,
      bool isHighlighted,
      bool isDisabled,
    ) {
      return defaultItemBuilder(
        context,
        item[key],
        isSelected,
        isHighlighted,
        isDisabled,
      );
    };
  }

  @override
  _ListButtonState<T> createState() => _ListButtonState<T>();
}

class _ListButtonState<T> extends State<ListButton<T>> {
  ListViewSelectionController? _selectionController;

  int _selectedIndex = -1;
  bool _pressed = false;
  _ConstraintsAdjuster _constraintsAdjuster = const _PassthroughAdjuster();

  void _handleSelectionChanged() {
    setState(() {
      _selectedIndex = selectionController.selectedIndex;
    });
  }

  void _updateButtonWidth() {
    switch (widget.width) {
      case ListButtonWidth.shrinkWrapCurrentItem:
        _constraintsAdjuster = const _PassthroughAdjuster();
        break;
      case ListButtonWidth.shrinkWrapAllItems:
        const WidgetSurveyor surveyor = WidgetSurveyor();
        final BasicListItemBuilder itemBuilder = _adaptBuilder(
          widget.builder,
          isForMeasurementOnly: true,
        );
        double maxWidth = 0;
        for (int i = -1; i < widget.items.length; i++) {
          Widget built = _buildContent(itemBuilder, index: i, useLocalBuildContext: true);
          maxWidth = math.max(maxWidth, surveyor.measureWidget(built).width);
        }
        _constraintsAdjuster = _WidthTightener(maxWidth);
        break;
      case ListButtonWidth.expand:
        _constraintsAdjuster = _WidthMaximizer();
        break;
    }
  }

  BasicListItemBuilder _adaptBuilder(ListButtonBuilder<T> builder, {bool isForMeasurementOnly = false}) {
    return (BuildContext context, int index) {
      final T? item = index == -1 ? null : widget.items[index];
      return builder(context, item, isForMeasurementOnly);
    };
  }

  ListItemBuilder _adaptItemBuilder(ListButtonItemBuilder<T> itemBuilder) {
    return (
      BuildContext context,
      int index,
      bool isSelected,
      bool isHighlighted,
      bool isDisabled,
    ) {
      return itemBuilder(
        context,
        widget.items[index],
        isSelected,
        isHighlighted,
        isDisabled,
      );
    };
  }

  Predicate<int>? _adaptDisabledItemFilter(Predicate<T>? predicate) {
    if (predicate == null) {
      return null;
    }
    return (int index) {
      return predicate(widget.items[index]);
    };
  }

  Widget _buildContent(
    BasicListItemBuilder itemBuilder, {
    int? index,
    bool useLocalBuildContext = false,
  }) {
    Widget result;
    if (useLocalBuildContext) {
      result = itemBuilder(context, index ?? _selectedIndex);
    } else {
      result = Builder(builder: (BuildContext context) {
        return itemBuilder(context, index ?? _selectedIndex);
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: result,
    );
  }

  ListViewSelectionController get selectionController {
    return _selectionController ?? widget.selectionController!;
  }

  void showPopup() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonGlobalOffset = button.localToGlobal(Offset.zero, ancestor: overlay);
    // TODO: Why do we need to ceil here?
    final Offset buttonPosition = Offset(
      buttonGlobalOffset.dx.ceilToDouble(),
      buttonGlobalOffset.dy.ceilToDouble(),
    );
    final _PopupListRoute<int> popupListRoute = _PopupListRoute<int>(
      position: RelativeRect.fromRect(buttonPosition & button.size, Offset.zero & overlay.size),
      length: widget.items.length,
      itemBuilder: _adaptItemBuilder(widget.itemBuilder),
      selectionController: selectionController,
      disabledItemFilter: _adaptDisabledItemFilter(widget.disabledItemFilter),
      showMenuContext: context,
    );
    Navigator.of(context).push<int>(popupListRoute).then((int? selectedIndex) {
      if (mounted) {
        setState(() {
          _pressed = false;
        });
        if (selectedIndex != null) {
          selectionController.selectedIndex = selectedIndex;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectionController == null) {
      _selectionController = ListViewSelectionController();
    }
    selectionController.addListener(_handleSelectionChanged);
    _handleSelectionChanged(); // to set the initial value of _selectedIndex
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateButtonWidth();
  }

  @override
  void didUpdateWidget(covariant ListButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateButtonWidth();
    if (oldWidget.selectionController != widget.selectionController) {
      if (oldWidget.selectionController == null) {
        assert(_selectionController != null);
        _selectionController!.removeListener(_handleSelectionChanged);
        _selectionController!.dispose();
        _selectionController = null;
      } else {
        assert(_selectionController == null);
        oldWidget.selectionController!.removeListener(_handleSelectionChanged);
      }
      if (widget.selectionController == null) {
        _selectionController = ListViewSelectionController();
        _selectionController!.addListener(_handleSelectionChanged);
      } else {
        widget.selectionController!.addListener(_handleSelectionChanged);
      }
      _handleSelectionChanged(); // to set the initial value of _selectedIndex
    }
  }

  @override
  void dispose() {
    selectionController.removeListener(_handleSelectionChanged);
    if (_selectionController != null) {
      assert(widget.selectionController == null);
      _selectionController!.dispose();
      _selectionController = null;
    }
    super.dispose();
  }

  static const BoxDecoration _enabledDecoration = BoxDecoration(
    border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: <Color>[Color(0xffdddcd5), Color(0xfff3f1fa)],
    ),
  );

  static const BoxDecoration _pressedDecoration = BoxDecoration(
    border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: <Color>[Color(0xffdddcd5), Color(0xffc8c7c0)],
    ),
  );

  static const BoxDecoration _disabledDecoration = BoxDecoration(
    border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
    color: const Color(0xffdddcd5),
  );

  @override
  Widget build(BuildContext context) {
    final BasicListItemBuilder itemBuilder = _adaptBuilder(widget.builder);

    late final BoxDecoration decoration;
    if (widget.isEnabled) {
      decoration = _pressed ? _pressedDecoration : _enabledDecoration;
    } else {
      decoration = _disabledDecoration;
    }

    Widget result = DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: EdgeInsets.all(1),
        child: _RawListButton(
          childAdjuster: _constraintsAdjuster,
          roundToWholePixel: widget.roundToWholePixel,
          child: _buildContent(itemBuilder),
        ),
      ),
    );

    if (widget.isEnabled) {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            setState(() {
              _pressed = true;
            });
          },
          onTapCancel: () {
            setState(() {
              _pressed = false;
            });
          },
          onTap: () {
            setState(() {
              showPopup();
            });
          },
          child: result,
        ),
      );
    } else {
      result = DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(color: const Color(0xff999999)),
        child: result,
      );
    }

    return result;
  }
}

@immutable
abstract class _ConstraintsAdjuster {
  const _ConstraintsAdjuster._();

  BoxConstraints adjust(BoxConstraints constraints);
}

class _PassthroughAdjuster extends _ConstraintsAdjuster {
  const _PassthroughAdjuster() : super._();

  @override
  BoxConstraints adjust(BoxConstraints constraints) => constraints;
}

class _WidthTightener extends _ConstraintsAdjuster {
  const _WidthTightener(this.width) : super._();

  final double width;

  @override
  BoxConstraints adjust(BoxConstraints constraints) => constraints.tighten(width: width);
}

class _WidthMaximizer extends _ConstraintsAdjuster {
  const _WidthMaximizer() : super._();

  @override
  BoxConstraints adjust(BoxConstraints constraints) => constraints.copyWith(minWidth: constraints.maxWidth);
}

class _RawListButton extends SingleChildRenderObjectWidget {
  const _RawListButton({
    Key? key,
    required Widget child,
    required this.childAdjuster,
    this.roundToWholePixel = false,
  }) : super(key: key, child: child);

  final _ConstraintsAdjuster childAdjuster;
  final bool roundToWholePixel;

  @override
  Widget get child => super.child!;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRawListButton(
      childAdjuster: childAdjuster,
      roundToWholePixel: roundToWholePixel,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderRawListButton renderObject) {
    renderObject
      ..childConstraintAdjuster = childAdjuster
      ..roundToWholePixel = roundToWholePixel;
  }
}

class _RenderRawListButton extends RenderBox with RenderObjectWithChildMixin<RenderBox>, RenderBoxWithChildDefaultsMixin {
  _RenderRawListButton({
    required _ConstraintsAdjuster childAdjuster,
    bool roundToWholePixel = false,
  }) {
    this.childConstraintAdjuster = childAdjuster;
    this.roundToWholePixel = roundToWholePixel;
  }

  static const double _kMinHeight = 18;
  static const double _kPulldownWidth = 15;
  static const double _kDividerWidth = 1;
  static const double _kReservedWidth = _kPulldownWidth + _kDividerWidth;

  _ConstraintsAdjuster? _childConstraintAdjuster;
  _ConstraintsAdjuster get childConstraintAdjuster => _childConstraintAdjuster!;
  set childConstraintAdjuster(_ConstraintsAdjuster value) {
    if (_childConstraintAdjuster == value) return;
    _childConstraintAdjuster = value;
    markNeedsLayout();
  }

  bool _roundToWholePixel = false;
  bool get roundToWholePixel => _roundToWholePixel;
  set roundToWholePixel(bool value) {
    if (_roundToWholePixel == value) return;
    _roundToWholePixel = value;
    markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    if (child != null) {
      final double? childBaseline = child!.getDistanceToActualBaseline(baseline);
      if (childBaseline != null) {
        final BoxParentData childParentData = child!.parentData as BoxParentData;
        return childBaseline + childParentData.offset.dy;
      }
    }
    return super.computeDistanceToActualBaseline(baseline);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return (child == null ? 0 : child!.getMinIntrinsicWidth(height)) + _kReservedWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return (child == null ? 0 : child!.getMinIntrinsicWidth(height)) + _kReservedWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return child == null ? _kMinHeight : math.max(child!.getMinIntrinsicHeight(width), _kMinHeight);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return child == null ? _kMinHeight : math.max(child!.getMinIntrinsicHeight(width), _kMinHeight);
  }

  double _dividerDx = 0;

  @override
  void performLayout() {
    Size childSize = Size.zero;
    if (child != null) {
      BoxConstraints childConstraints = constraints.deflate(EdgeInsets.only(left: _kReservedWidth));
      if (roundToWholePixel) {
        childConstraints = childConstraints.copyWith(maxWidth: childConstraints.maxWidth.floorToDouble());
      }
      childConstraints = childConstraintAdjuster.adjust(childConstraints);
      assert(() {
        if (childConstraints.minWidth.isInfinite) {
          child!.layout(BoxConstraints.tight(Size.zero));
          size = Size.zero; // To avoid ancillary exceptions that will confuse things.
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('ListButtonWidth.expand cannot be used with unbounded with.'),
            ErrorDescription('ListButtonWidth.expand causes a ListButton to expand to fill the '
                'available space. It cannot be used in a layout setting where it is given unbounded '
                '(infinite) width constraints, because doing so would cause the ListButton to have '
                'infinite width, which is not allowed.'),
            ErrorSpacer(),
            DiagnosticsProperty<BoxConstraints>('The constraints passed to the ListButton '
                'content were', constraints),
            ErrorSpacer(),
            DiagnosticsProperty<Object>(
                'The widget tree that created the ListButton in question was', debugCreator,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      child!.layout(childConstraints, parentUsesSize: true);
      childSize = child!.size;
      if (roundToWholePixel) {
        childSize = Size(childSize.width.ceilToDouble(), childSize.height);
      }
    }
    size = constraints.constrainDimensions(
      childSize.width + _kReservedWidth,
      math.max(childSize.height, _kMinHeight),
    );
    _dividerDx = childSize.width;
    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      childParentData.offset = Offset(0, (size.height - childSize.height) / 2);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    return defaultHitTestChild(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaintChild(context, offset);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff999999);
    context.canvas.drawLine(offset.translate(_dividerDx + 0.5, 0), offset.translate(_dividerDx + 0.5, size.height), paint);

    const _ArrowImage arrow = _ArrowImage();
    final double pulldownWidth = size.width - (_dividerDx + 1);
    final double pulldownDx = (pulldownWidth - arrow.preferredSize.width) / 2;
    final double pulldownDy = (size.height - arrow.preferredSize.height) / 2;
    context.canvas..save()..translate(offset.dx + _dividerDx + 1 + pulldownDx, offset.dy + pulldownDy);
    try {
      arrow.paint(context.canvas, arrow.preferredSize);
    } finally {
      context.canvas.restore();
    }
  }
}

class _PopupListRoute<T> extends PopupRoute<T> {
  _PopupListRoute({
    required this.position,
    required this.length,
    required this.itemBuilder,
    required this.selectionController,
    this.disabledItemFilter,
    required this.showMenuContext,
  });

  final RelativeRect position;
  final int length;
  final ListItemBuilder itemBuilder;
  final ListViewSelectionController selectionController;
  final Predicate<int>? disabledItemFilter;
  final BuildContext showMenuContext;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SafeArea(
      child: CustomSingleChildLayout(
        delegate: _PopupListRouteLayout(position),
        child: InheritedTheme.captureAll(
          showMenuContext,
          _PopupList<T>(
            route: this,
            length: length,
            itemBuilder: itemBuilder,
            selectionController: selectionController,
            disabledItemFilter: disabledItemFilter,
          ),
        ),
      ),
    );
  }
}

class _PopupListRouteLayout extends SingleChildLayoutDelegate {
  _PopupListRouteLayout(this.position);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    const double padding = 8.0;
    return BoxConstraints.loose(
      constraints.biggest - const Offset(padding, padding) as Size,
    );
  }

  /// `size` is the size of the overlay.
  ///
  /// `childSize` is the size of the menu, when fully open, as determined by
  /// [getConstraintsForChild].
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Rect buttonRect = position.toRect(Offset.zero & size);
    return Offset(buttonRect.left, buttonRect.bottom - 1);
  }

  @override
  bool shouldRelayout(_PopupListRouteLayout oldDelegate) => position != oldDelegate.position;
}

class _PopupList<T> extends StatefulWidget {
  const _PopupList({
    required this.length,
    required this.itemBuilder,
    required this.selectionController,
    this.disabledItemFilter,
    required this.route,
  });

  final int length;
  final ListItemBuilder itemBuilder;
  final ListViewSelectionController selectionController;
  final Predicate<int>? disabledItemFilter;
  final _PopupListRoute<T> route;

  @override
  _PopupListState<T> createState() => _PopupListState<T>();
}

class _PopupListState<T> extends State<_PopupList<T>> {
  late ListViewSelectionController _selectionController;
  ListViewItemDisablerController? _itemDisabledController;
  late double _popupWidth;
  late double _itemHeight;

  void _handleSelectedIndexChanged() {
    Navigator.of(context).pop(_selectionController.selectedIndex);
  }

  void _updateListViewMetrics() {
    final TextDirection textDirection = Directionality.of(context);
    const WidgetSurveyor surveyor = WidgetSurveyor();
    double maxWidth = 0;
    double maxHeight = 0;
    for (int i = 0; i < widget.length; i++) {
      final Widget item = Directionality(
        textDirection: textDirection,
        child: widget.itemBuilder(context, i, false, false, false),
      );
      final Size itemSize = surveyor.measureWidget(item);
      maxWidth = math.max(maxWidth, itemSize.width);
      maxHeight = math.max(maxHeight, itemSize.height);
    }
    _popupWidth = maxWidth;
    _itemHeight = maxHeight;
  }

  ListViewItemDisablerController? _createItemDisabledController() {
    return widget.disabledItemFilter == null
        ? null : ListViewItemDisablerController(filter: widget.disabledItemFilter);
  }

  @override
  void initState() {
    super.initState();
    _selectionController = ListViewSelectionController();
    _selectionController.selectedIndex = widget.selectionController.selectedIndex;
    _selectionController.addListener(_handleSelectedIndexChanged);
    _itemDisabledController = _createItemDisabledController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateListViewMetrics();
  }

  @override
  void didUpdateWidget(covariant _PopupList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateListViewMetrics();
    _itemDisabledController = _createItemDisabledController();
  }

  @override
  void dispose() {
    _selectionController.removeListener(_handleSelectedIndexChanged);
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const BoxShadow shadow = BoxShadow(
      color: Color(0x40000000),
      blurRadius: 3,
      offset: Offset(3, 3),
    );

    final CurveTween opacity = CurveTween(curve: Curves.linear);

    return AnimatedBuilder(
      animation: widget.route.animation!,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: opacity.evaluate(widget.route.animation!),
          child: ClipRect(
            clipper: const _ShadowClipper(shadow),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
                border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
                boxShadow: [shadow],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: SizedBox(
                  width: _popupWidth,
                  child: ScrollableListView(
                    itemHeight: _itemHeight,
                    length: widget.length,
                    itemBuilder: widget.itemBuilder,
                    selectionController: _selectionController,
                    itemDisabledController: _itemDisabledController,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShadowClipper extends CustomClipper<Rect> {
  const _ShadowClipper(this.shadow);

  final BoxShadow shadow;

  @override
  Rect getClip(Size size) {
    final double shadowRadius = shadow.blurRadius * 2 + shadow.spreadRadius;
    return Offset.zero & (size + Offset(shadowRadius, shadowRadius));
  }

  @override
  bool shouldReclip(_ShadowClipper oldClipper) => false;
}

class _ArrowImage {
  const _ArrowImage();

  Size get preferredSize => const Size(7, 4);

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = const Color(0xff000000);
    Path arrow = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height + 0.5)
      ..lineTo(size.width, 0);
    arrow.close();
    canvas.drawPath(arrow, paint);
  }
}
