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

import 'package:flutter/widgets.dart';

import 'calendar.dart';
import 'foundation.dart';

const _kPrototypeDate = CalendarDate(2000, 11, 30);

class CalendarButton extends StatefulWidget {
  const CalendarButton({
    super.key,
    this.format = CalendarDateFormat.medium,
    this.initialSelectedDate,
    this.initialMonth,
    this.initialYear,
    this.selectionController,
    this.disabledDateFilter,
    this.onDateChanged,
    this.width = CalendarButtonWidth.expand,
    this.isEnabled = true,
  });

  final CalendarDateFormat format;
  final CalendarDate? initialSelectedDate;
  final int? initialMonth;
  final int? initialYear;
  final CalendarSelectionController? selectionController;
  final Predicate<CalendarDate>? disabledDateFilter;
  final ValueChanged<CalendarDate?>? onDateChanged;
  final CalendarButtonWidth width;
  final bool isEnabled;

  @override
  State<CalendarButton> createState() => _CalendarButtonState();
}

/// Enum that specifies how a [CalendarButton] will calculate its width.
enum CalendarButtonWidth {
  expand,

  shrinkWrap,
}

class _CalendarButtonState extends State<CalendarButton> {
  CalendarSelectionController? _selectionController;
  CalendarDate? _selectedDate;
  bool _pressed = false;

  void _handleSelectedDateChanged() {
    CalendarDate? selectedDate = selectionController.value;
    if (widget.onDateChanged != null) {
      widget.onDateChanged!(selectedDate);
    }
    setState(() {
      _selectedDate = selectedDate;
    });
  }

  void _showPopup() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final OverlayState? overlayState = Overlay.of(context);
    assert(() {
      if (overlayState == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No overlay found in widget ancestry.'),
          ErrorDescription('Usually the Navigator created by WidgetsApp provides the overlay. '
              'Perhaps your app content was created above the Navigator with the WidgetsApp '
              'builder parameter.'),
        ]);
      }
      return true;
    }());
    final RenderBox overlay = overlayState!.context.findRenderObject() as RenderBox;
    final Offset buttonGlobalOffset = button.localToGlobal(Offset.zero, ancestor: overlay);
    // TODO: Why do we need to ceil here?
    final Offset buttonPosition = Offset(
      buttonGlobalOffset.dx.ceilToDouble(),
      buttonGlobalOffset.dy.ceilToDouble(),
    );
    final _PopupCalendarRoute<CalendarDate> popupCalendarRoute = _PopupCalendarRoute<CalendarDate>(
      position: RelativeRect.fromRect(buttonPosition & button.size, Offset.zero & overlay.size),
      initialMonth: widget.initialMonth,
      initialYear: widget.initialYear,
      selectedDate: selectionController.value,
      disabledDateFilter: widget.disabledDateFilter,
      showMenuContext: context,
    );
    Navigator.of(context).push<CalendarDate>(popupCalendarRoute).then((CalendarDate? date) {
      if (mounted) {
        setState(() {
          _pressed = false;
        });
        if (date != null) {
          selectionController.value = date;
        }
      }
    });
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
    color: Color(0xffdddcd5),
  );

  CalendarSelectionController get selectionController {
    return _selectionController ?? widget.selectionController!;
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectionController == null) {
      _selectionController = CalendarSelectionController();
    }
    selectionController.value ??= widget.initialSelectedDate;
    selectionController.addListener(_handleSelectedDateChanged);
    _handleSelectedDateChanged(); // to set the initial value of _selectedDate
  }

  @override
  void didUpdateWidget(covariant CalendarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionController != widget.selectionController) {
      if (oldWidget.selectionController == null) {
        assert(widget.selectionController != null);
        assert(_selectionController != null);
        _selectionController!.removeListener(_handleSelectedDateChanged);
        _selectionController!.dispose();
        _selectionController = null;
      } else {
        assert(_selectionController == null);
        oldWidget.selectionController!.removeListener(_handleSelectedDateChanged);
      }
      if (widget.selectionController == null) {
        _selectionController = CalendarSelectionController();
        _selectionController!.addListener(_handleSelectedDateChanged);
      } else {
        widget.selectionController!.addListener(_handleSelectedDateChanged);
      }
      _handleSelectedDateChanged(); // to set the initial value of _selectedDate
    }
  }

  @override
  void dispose() {
    selectionController.removeListener(_handleSelectedDateChanged);
    if (_selectionController != null) {
      assert(widget.selectionController == null);
      _selectionController!.dispose();
      _selectionController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    if (widget.isEnabled) {
      decoration = _pressed ? _pressedDecoration : _enabledDecoration;
    } else {
      decoration = _disabledDecoration;
    }

    final CalendarDate date = _selectedDate ?? _kPrototypeDate;
    Widget content = Text(
      widget.format.format(date),
      maxLines: 1,
      softWrap: false,
    );
    if (_selectedDate == null) {
      content = Opacity(opacity: 0, child: content);
    }

    Widget result = DecoratedBox(
      decoration: decoration,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          Widget contentArea = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: content,
            ),
          );
          if (widget.width == CalendarButtonWidth.expand && constraints.hasBoundedWidth) {
            contentArea = Expanded(child: contentArea);
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              contentArea,
              const SizedBox(
                width: 1,
                height: 20,
                child: ColoredBox(color: Color(0xff999999)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: CustomPaint(
                  size: Size(7, 4),
                  painter: _ArrowPainter(),
                ),
              ),
            ],
          );
        },
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
              _showPopup();
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

class _PopupCalendarRoute<T> extends PopupRoute<T> {
  _PopupCalendarRoute({
    required this.position,
    required this.initialMonth,
    required this.initialYear,
    required this.selectedDate,
    required this.disabledDateFilter,
    required this.showMenuContext,
  });

  final RelativeRect position;
  final int? initialMonth;
  final int? initialYear;
  final CalendarDate? selectedDate;
  final Predicate<CalendarDate>? disabledDateFilter;
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
        delegate: _PopupCalendarRouteLayout(position),
        child: InheritedTheme.captureAll(
          showMenuContext,
          _PopupCalendar<T>(
            route: this,
            initialMonth: initialMonth,
            initialYear: initialYear,
            selectedDate: selectedDate,
            disabledDateFilter: disabledDateFilter,
          ),
        ),
      ),
    );
  }
}

class _PopupCalendarRouteLayout extends SingleChildLayoutDelegate {
  _PopupCalendarRouteLayout(this.position);

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
  bool shouldRelayout(_PopupCalendarRouteLayout oldDelegate) => position != oldDelegate.position;
}

class _PopupCalendar<T> extends StatefulWidget {
  const _PopupCalendar({
    required this.initialMonth,
    required this.initialYear,
    required this.selectedDate,
    required this.disabledDateFilter,
    required this.route,
  });

  final int? initialMonth;
  final int? initialYear;
  final CalendarDate? selectedDate;
  final Predicate<CalendarDate>? disabledDateFilter;
  final _PopupCalendarRoute<T> route;

  @override
  _PopupCalendarState<T> createState() => _PopupCalendarState<T>();
}

class _PopupCalendarState<T> extends State<_PopupCalendar<T>> {
  late CalendarSelectionController _selectionController;

  void _handleDateSelected(CalendarDate? date) {
    assert(date != null);
    assert(date == _selectionController.value);
    Navigator.of(context).pop(date!);
  }

  @override
  void initState() {
    super.initState();
    _selectionController = CalendarSelectionController();
    _selectionController.value = widget.selectedDate;
  }

  @override
  void dispose() {
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
    final CalendarDate today = CalendarDate.today();

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
                boxShadow: [shadow],
              ),
              child: Calendar(
                initialMonth: widget.initialMonth ?? widget.selectedDate?.month ?? today.month,
                initialYear: widget.initialYear ?? widget.selectedDate?.year ?? today.year,
                selectionController: _selectionController,
                disabledDateFilter: widget.disabledDateFilter,
                onDateChanged: _handleDateSelected,
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

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const _ArrowImage arrow = _ArrowImage();
    double arrowX = (size.width - arrow.preferredSize.width) / 2;
    double arrowY = (size.height - arrow.preferredSize.height) / 2;
    canvas.save();
    try {
      canvas.translate(arrowX, arrowY);
      arrow.paint(canvas, arrow.preferredSize);
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
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
