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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'colors.dart';
import 'sorting.dart';

class PushButton extends StatefulWidget {
  const PushButton({
    Key key,
    this.icon,
    this.label,
    this.axis = Axis.horizontal,
    this.isToolbar = false,
    this.onPressed,
    this.menuItems,
    this.minimumAspectRatio,
    this.color = const Color(0xff000000),
    this.backgroundColor = const Color(0xffdddcd5),
    this.borderColor = const Color(0xff999999),
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    this.showTooltip = true,
  }) : super(key: key);

  final String icon;
  final String label;
  final Axis axis;
  final bool isToolbar;
  final VoidCallback onPressed;
  final List<PopupMenuEntry> menuItems;
  final double minimumAspectRatio;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsets padding;
  final bool showTooltip;

  @override
  _PushButtonState createState() => _PushButtonState();
}

class _PushButtonState extends State<PushButton> {
  bool hover;
  bool pressed;

  LinearGradient get highlightGradient {
    return LinearGradient(
      begin: Alignment(0, 0.2),
      end: Alignment.topCenter,
      colors: <Color>[widget.backgroundColor, brighten(widget.backgroundColor)],
    );
  }

  LinearGradient get pressedGradient {
    return LinearGradient(
      begin: Alignment.center,
      end: Alignment.topCenter,
      colors: <Color>[widget.backgroundColor, darken(widget.backgroundColor)],
    );
  }

  @override
  void initState() {
    super.initState();
    hover = false;
    pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;

    final List<Widget> buttonData = <Widget>[];
    if (widget.icon != null) {
      Widget iconImage = Image(image: AssetImage(widget.icon));
      if (!enabled) {
        iconImage = Opacity(
          opacity: 0.5,
          child: iconImage,
        );
      }
      buttonData..add(iconImage)..add(SizedBox(width: 4, height: 4));
    }

    if (widget.label != null) {
      TextStyle style = Theme.of(context).textTheme.bodyText2;
      if (enabled) {
        style = style.copyWith(color: widget.color);
      } else {
        style = style.copyWith(color: const Color(0xff999999));
      }
      buttonData.add(Text(widget.label, style: style));
    }

    Widget button = Center(
      child: Padding(
        padding: widget.padding,
        child: widget.axis == Axis.horizontal ? Row(children: buttonData) : Column(children: buttonData),
      ),
    );

    if (widget.menuItems != null) {
      button = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: button,
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: CustomPaint(
              size: Size(7, 4),
              painter: SortIndicatorPainter(
                sortDirection: SortDirection.descending,
                color: Colors.black,
              ),
            ),
          )
        ],
      );
    }

    if (hover || !widget.isToolbar) {
      final Border border = Border.fromBorderSide(BorderSide(color: widget.borderColor));
      Decoration decoration;
      if (enabled && pressed) {
        decoration = BoxDecoration(border: border, gradient: pressedGradient);
      } else if (enabled) {
        decoration = BoxDecoration(border: border, gradient: highlightGradient);
      } else {
        decoration = BoxDecoration(border: border, color: Color(0xffdddcd5));
      }
      button = DecoratedBox(decoration: decoration, child: button);
    }

    GestureTapCallback callback = widget.onPressed;
    if (widget.menuItems != null) {
      callback = () {
        if (widget.onPressed != null) {
          widget.onPressed();
        }
        setState(() {
          hover = true;
          pressed = true;
        });
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        showMenu<String>(
          context: context,
          position: position,
          items: widget.menuItems,
        ).then((String value) {
          setState(() {
            hover = false;
            pressed = false;
          });
          switch (value) {
            case 'about':
              showAboutDialog(
                context: context,
                applicationName: 'Payouts',
                applicationVersion: '2.0.0',
                applicationIcon: Image.asset('assets/logo-large.png'),
                applicationLegalese:
                    '\u00A9 2001-2020 Satellite Consulting, Inc. All Rights Reserved. SCI Payouts and the Satellite Consulting, Inc. logo are trademarks of Satellite Consulting, Inc. All rights reserved.',
              );
              break;
          }
        });
      };
    }

    if (enabled) {
      if (widget.showTooltip) {
        button = Tooltip(
          message: widget.label,
          waitDuration: Duration(seconds: 1, milliseconds: 500),
          child: button,
        );
      }

      button = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (PointerEnterEvent event) {
          setState(() => hover = true);
        },
        onExit: (PointerExitEvent event) {
          setState(() => hover = false);
        },
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            setState(() => pressed = true);
          },
          onPointerUp: (PointerUpEvent event) {
            setState(() => pressed = false);
          },
          child: GestureDetector(
            onTap: callback,
            child: button,
          ),
        ),
      );
    }

    if (widget.minimumAspectRatio != null) {
      button = _MinimumAspectRatio(
        minimumAspectRatio: 3,
        child: button,
      );
    }

    return button;
  }
}

class _MinimumAspectRatio extends SingleChildRenderObjectWidget {
  const _MinimumAspectRatio({
    Key key,
    Widget child,
    @required this.minimumAspectRatio,
  })  : assert(minimumAspectRatio != null),
        super(key: key, child: child);

  final double minimumAspectRatio;

  @override
  _RenderMinimumAspectRatio createRenderObject(BuildContext context) {
    return _RenderMinimumAspectRatio(minimumAspectRatio: minimumAspectRatio);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMinimumAspectRatio renderObject) {
    renderObject..minimumAspectRatio = minimumAspectRatio;
  }
}

class _RenderMinimumAspectRatio extends RenderProxyBox {
  _RenderMinimumAspectRatio({
    RenderBox child,
    double minimumAspectRatio,
  })  : assert(minimumAspectRatio != null),
        _minimumAspectRatio = minimumAspectRatio,
        super(child);

  double _minimumAspectRatio;
  double get minimumAspectRatio => _minimumAspectRatio;
  set minimumAspectRatio(double value) {
    assert(value != null);
    if (value == _minimumAspectRatio) return;
    _minimumAspectRatio = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child == null) {
      return 0.0;
    }
    if (!height.isFinite) {
      height = child.getMaxIntrinsicHeight(double.infinity);
    }
    assert(height.isFinite);
    return math.max(height * _minimumAspectRatio, child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child == null) {
      return 0.0;
    }
    if (!height.isFinite) {
      height = child.getMaxIntrinsicHeight(double.infinity);
    }
    assert(height.isFinite);
    return math.max(height * _minimumAspectRatio, child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return computeMaxIntrinsicHeight(width);
  }

  @override
  void performLayout() {
    if (child != null) {
      BoxConstraints childConstraints = constraints;
      if (!childConstraints.hasTightHeight) {
        final double height = child.getMaxIntrinsicHeight(childConstraints.maxWidth);
        assert(height.isFinite);
        childConstraints = childConstraints.tighten(height: height);
      }
      childConstraints = childConstraints.copyWith(
        minWidth: childConstraints.constrainWidth(childConstraints.maxHeight * _minimumAspectRatio),
      );
      child.layout(childConstraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }
  }
}
