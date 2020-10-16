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

import 'dart:ui' show window;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'basic_list_view.dart';
import 'foundation.dart';
import 'list_view.dart';

void main() {
  runApp(
    Localizations(
      locale: Locale('en', 'US'),
      delegates: [
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: MediaQuery(
        data: MediaQueryData.fromWindow(window),
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (BuildContext context) {
                return Material(
                  child: ColoredBox(
                    color: const Color(0xffffffff),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: DefaultTextStyle(
                        style: TextStyle(fontFamily: 'Verdana', color: const Color(0xff000000)),
                        child: Center(
                          child: ListButton(
                            length: 5,
                            builder: ({BuildContext context, int index}) {
                              return Text('$index');
                            },
                            itemBuilder: ({
                              BuildContext context,
                              int index,
                              bool isSelected,
                              bool isHighlighted,
                              bool isDisabled,
                            }) {
                              TextStyle style = DefaultTextStyle.of(context).style;
                              if (isSelected) {
                                style = style.copyWith(color: const Color(0xffffffff));
                              }
                              return Text('$index', style: style);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

class ListButton extends StatefulWidget {
  ListButton({
    Key key,
    @required this.length,
    @required this.builder,
    @required this.itemBuilder,
    this.selectionController,
    this.disabledItemFilter,
  })  : assert(selectionController == null || selectionController.selectMode == SelectMode.single),
        assert(builder != null),
        assert(itemBuilder != null),
        super(key: key);

  final int length;
  final BasicListItemBuilder builder;
  final ListItemBuilder itemBuilder;
  final ListViewSelectionController selectionController;
  final Predicate<int> disabledItemFilter;

  @override
  _ListButtonState createState() => _ListButtonState();
}

class _ListButtonState extends State<ListButton> {
  ListViewSelectionController _selectionController;

  int _selectedIndex = -1;
  bool _pressed = false;

  void _handleSelectionChanged() {
    setState(() {
      _selectedIndex = _selectionController.selectedIndex;
    });
  }

  ListViewSelectionController get selectionController {
    return _selectionController ?? widget.selectionController;
  }

  void showPopup() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonGlobalOffset = button.localToGlobal(Offset.zero, ancestor: overlay);
    // TODO: Why do we need to ceil here?
    final Rect buttonPosition = Offset(buttonGlobalOffset.dx.ceilToDouble(), buttonGlobalOffset.dy.ceilToDouble()) & button.size;
    Navigator.of(context).push<int>(_PopupListRoute<int>(
      position: RelativeRect.fromRect(buttonPosition, Offset.zero & overlay.size),
      length: widget.length,
      itemBuilder: widget.itemBuilder,
      selectionController: selectionController,
      disabledItemFilter: widget.disabledItemFilter,
      showMenuContext: context,
    )).then((int selectedIndex) {
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
  void didUpdateWidget(covariant ListButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionController != widget.selectionController) {
      if (oldWidget.selectionController == null) {
        assert(_selectionController != null);
        _selectionController.removeListener(_handleSelectionChanged);
        _selectionController.dispose();
        _selectionController = null;
      } else {
        assert(_selectionController == null);
        oldWidget.selectionController.removeListener(_handleSelectionChanged);
      }
      if (widget.selectionController == null) {
        _selectionController = ListViewSelectionController();
        _selectionController.addListener(_handleSelectionChanged);
      } else {
        widget.selectionController.addListener(_handleSelectionChanged);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectionController == null) {
      _selectionController = ListViewSelectionController();
    }
    selectionController.addListener(_handleSelectionChanged);
  }

  @override
  void dispose() {
    selectionController.removeListener(_handleSelectionChanged);
    if (_selectionController != null) {
      assert(widget.selectionController == null);
      _selectionController.dispose();
      _selectionController = null;
    }
    super.dispose();
  }

  static const BoxDecoration _decoration = BoxDecoration(
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
        child: DecoratedBox(
          decoration: _pressed ? _pressedDecoration : _decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: widget.builder(context: context, index: _selectedIndex),
                ),
              ),
              SizedBox(
                width: 1,
                height: 20,
                child: ColoredBox(color: const Color(0xff999999)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: const CustomPaint(
                  size: Size(7, 4),
                  painter: _ArrowPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupListRoute<T> extends PopupRoute<T> {
  _PopupListRoute({
    @required this.position,
    this.length,
    this.itemBuilder,
    this.selectionController,
    this.disabledItemFilter,
    this.showMenuContext,
  });

  final RelativeRect position;
  final int length;
  final ListItemBuilder itemBuilder;
  final ListViewSelectionController selectionController;
  final Predicate<int> disabledItemFilter;
  final BuildContext showMenuContext;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
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
    const double _kMenuScreenPadding = 8.0;
    return BoxConstraints.loose(
      constraints.biggest - const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0) as Size,
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
    this.length,
    this.itemBuilder,
    this.selectionController,
    this.disabledItemFilter,
    this.route,
  });

  final int length;
  final ListItemBuilder itemBuilder;
  final ListViewSelectionController selectionController;
  final Predicate<int> disabledItemFilter;
  final _PopupListRoute<T> route;

  @override
  _PopupListState<T> createState() => _PopupListState<T>();
}

class _PopupListState<T> extends State<_PopupList<T>> {
  ListViewSelectionController _selectionController;

  void _handleTap() {
    Navigator.of(context).pop(_selectionController.selectedIndex);
  }

  @override
  void initState() {
    super.initState();
    _selectionController = ListViewSelectionController();
    _selectionController.selectedIndex = widget.selectionController.selectedIndex;
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

    return AnimatedBuilder(
      animation: widget.route.animation,
      builder: (BuildContext context, Widget child) {
        return Opacity(
          opacity: opacity.evaluate(widget.route.animation),
          child: GestureDetector(
            onTap: _handleTap,
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
                    width: 200,
                    child: ScrollableListView(
                      itemHeight: 20,
                      length: widget.length,
                      itemBuilder: widget.itemBuilder,
                      selectionController: _selectionController,
                      // itemDisabledController: disabledItemFilter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

class _ShadowClipper extends CustomClipper<Rect> {
  const _ShadowClipper(this.shadow) : assert(shadow != null);

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
