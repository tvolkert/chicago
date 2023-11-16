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
import 'package:flutter/material.dart' show PopupMenuEntry, PopupMenuItemSelected, showMenu, Theme, Tooltip;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'action_tracker.dart';
import 'colors.dart';
import 'focus_indicator.dart';
import 'foundation.dart';
import 'sorting.dart';

const Axis _defaultAxis = Axis.horizontal;
const Color _defaultColor = Color(0xff000000);
const Color _defaultBackgroundColor = Color(0xffdddcd5);
const Color _defaultBorderColor = Color(0xff999999);
const Color _defaultDisabledBackgroundColor = Color(0xffdddcd5);
const Color _defaultDisabledBorderColor = Color(0xff999999);
const EdgeInsets _defaultPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 4);
const bool _defaultIsToolbar = false;
const bool _defaultShowTooltip = true;
const bool _defaultIsFocusable = true;

class PushButton<T extends Object> extends StatefulWidget {
  const PushButton({
    Key? key,
    this.icon,
    this.label,
    this.axis = _defaultAxis,
    this.isToolbar = _defaultIsToolbar,
    this.onPressed,
    this.menuItems,
    this.onMenuItemSelected,
    this.minimumAspectRatio,
    this.color = _defaultColor,
    this.backgroundColor = _defaultBackgroundColor,
    this.borderColor = _defaultBorderColor,
    this.disabledBackgroundColor = _defaultDisabledBackgroundColor,
    this.disabledBorderColor = _defaultDisabledBorderColor,
    this.padding = _defaultPadding,
    this.focusIndicatorPadding = const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    this.isFocusable = _defaultIsFocusable,
    this.autofocus = false,
    this.showTooltip = _defaultShowTooltip,
  }) : super(key: key);

  final String? icon;
  final String? label;
  final Axis axis;
  final bool isToolbar;
  final VoidCallback? onPressed;
  final List<PopupMenuEntry<T>>? menuItems;
  final PopupMenuItemSelected<T?>? onMenuItemSelected;
  final double? minimumAspectRatio;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final Color disabledBackgroundColor;
  final Color disabledBorderColor;
  final EdgeInsets padding;
  final EdgeInsets focusIndicatorPadding;
  final bool isFocusable;
  final bool autofocus;
  final bool showTooltip;

  @override
  _PushButtonState<T> createState() => _PushButtonState<T>();
}

class _ActivatePushButtonAction<T extends Object> extends ActivateAction {
  _ActivatePushButtonAction(this._state);

  final _PushButtonState<T> _state;

  @override
  void invoke(Intent intent) {
    _state._handlePress();
  }
}

class _PushButtonState<T extends Object> extends State<PushButton<T>> {
  bool hover = false;
  bool pressed = false;
  bool menuActive = false;
  bool focused = false;
  FocusNode? focusNode;

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      focused = hasFocus;
      if (!hasFocus) {
        pressed = false;
      }
    });
  }

  KeyEventResult _handleKey(FocusNode focusNode, RawKeyEvent event) {
    // The actual "pressing" of the button happens via the `ActivateIntent`.
    // This code merely visually shows the button in the pressed state.
    if (isActivateKey(event.logicalKey)) {
      setState(() {
        pressed = event is RawKeyDownEvent;
      });
    }
    return KeyEventResult.ignored;
  }

  void _handlePress() {
    _handleSimplePress();
    if (widget.menuItems != null) {
      _handleMenuPress();
    }
  }

  void _handleSimplePress() {
    focusNode!.requestFocus();
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _handleMenuPress() {
    setState(() {
      menuActive = true;
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
    showMenu<T>(
      context: context,
      position: position,
      elevation: 4,
      items: widget.menuItems!,
    ).then((T? value) {
      if (mounted) {
        setState(() {
          menuActive = false;
        });
        if (widget.onMenuItemSelected != null) {
          widget.onMenuItemSelected!(value);
        }
      }
    });
  }

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

  bool get isEnabled => widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(canRequestFocus: isEnabled);
    if (widget.autofocus) {
      focusNode!.requestFocus();
    }
  }

  @override
  void didUpdateWidget(PushButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed != oldWidget.onPressed) {
      focusNode!.canRequestFocus = isEnabled;
      if (!isEnabled) {
        hover = false;
        pressed = false;
        if (menuActive) {
          Navigator.of(context).pop();
          menuActive = false;
        }
      }
    }
  }

  @override
  void dispose() {
    focusNode!.dispose();
    focusNode = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttonData = <Widget>[];
    if (widget.icon != null) {
      Widget iconImage = Image(image: AssetImage(widget.icon!));
      if (!isEnabled) {
        iconImage = Opacity(
          opacity: 0.5,
          child: iconImage,
        );
      }
      buttonData..add(iconImage)..add(SizedBox(width: 4, height: 4));
    }

    if (widget.label != null) {
      TextStyle style = Theme.of(context).textTheme.bodyMedium!;
      if (isEnabled) {
        style = style.copyWith(color: widget.color);
      } else {
        style = style.copyWith(color: const Color(0xff999999));
      }
      buttonData.add(Text(widget.label!, style: style));
    }

    Widget button =
        widget.axis == Axis.horizontal ? Row(children: buttonData) : Column(children: buttonData);

    button = Center(
      child: Padding(
        padding: widget.padding,
        child: button,
      ),
    );

    if (!widget.isToolbar) {
      button = FocusIndicator(
        isFocused: focused,
        insets: widget.focusIndicatorPadding,
        color: widget.borderColor,
        child: button,
      );
    }

    button = Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: _ActivatePushButtonAction<T>(this),
      },
      child: Focus(
        canRequestFocus: isEnabled && widget.isFocusable,
        descendantsAreFocusable: isEnabled && widget.isFocusable,
        focusNode: focusNode,
        onKey: _handleKey,
        onFocusChange: _handleFocusChange,
        child: button,
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
                color: const Color(0xff000000),
              ),
            ),
          )
        ],
      );
    }

    if (menuActive || hover || focused || !widget.isToolbar) {
      final Border border = Border.fromBorderSide(
        BorderSide(color: isEnabled ? widget.borderColor : widget.disabledBorderColor),
      );
      Decoration decoration;
      if (isEnabled && (pressed || menuActive)) {
        decoration = BoxDecoration(border: border, gradient: pressedGradient);
      } else if (isEnabled) {
        decoration = BoxDecoration(border: border, gradient: highlightGradient);
      } else {
        decoration = BoxDecoration(border: border, color: widget.disabledBackgroundColor);
      }
      button = DecoratedBox(decoration: decoration, child: button);
    }

    if (isEnabled) {
      if (widget.showTooltip && widget.label != null) {
        button = Tooltip(
          message: widget.label!,
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
            onTap: _handlePress,
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
    Key? key,
    required Widget child,
    required this.minimumAspectRatio,
  }) : super(key: key, child: child);

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
    RenderBox? child,
    required double minimumAspectRatio,
  }) : super(child) {
    this.minimumAspectRatio = minimumAspectRatio;
  }

  double? _minimumAspectRatio;
  double get minimumAspectRatio => _minimumAspectRatio!;
  set minimumAspectRatio(double value) {
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
      height = child!.getMaxIntrinsicHeight(double.infinity);
    }
    assert(height.isFinite);
    return math.max(height * minimumAspectRatio, child!.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child == null) {
      return 0.0;
    }
    if (!height.isFinite) {
      height = child!.getMaxIntrinsicHeight(double.infinity);
    }
    assert(height.isFinite);
    return math.max(height * minimumAspectRatio, child!.getMaxIntrinsicWidth(height));
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
        final double height = child!.getMaxIntrinsicHeight(childConstraints.maxWidth);
        assert(height.isFinite);
        childConstraints = childConstraints.tighten(height: height);
      }
      childConstraints = childConstraints.copyWith(
        minWidth: childConstraints.constrainWidth(childConstraints.maxHeight * minimumAspectRatio),
      );
      child!.layout(childConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      performResize();
    }
  }
}

class CommandPushButton extends StatelessWidget {
  const CommandPushButton({
    Key? key,
    required this.label,
    this.autofocus = false,
    required this.onPressed,
  }) : super(key: key);

  final String label;
  final bool autofocus;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PushButton(
      color: const Color(0xffffffff),
      backgroundColor: const Color(0xff3c77b2),
      borderColor: const Color(0xff2b5580),
      padding: EdgeInsets.fromLTRB(3, 4, 4, 5),
      autofocus: autofocus,
      showTooltip: false,
      minimumAspectRatio: 3,
      onPressed: onPressed,
      label: label,
    );
  }
}

class ActionPushButton<I extends Intent> extends ActionTracker<I> {
  const ActionPushButton({
    Key? key,
    required I intent,
    ValueChanged<Object?>? onActionInvoked,
    this.icon,
    this.label,
    this.axis = _defaultAxis,
    this.isToolbar = _defaultIsToolbar,
    this.minimumAspectRatio,
    this.color = _defaultColor,
    this.backgroundColor = _defaultBackgroundColor,
    this.borderColor = _defaultBorderColor,
    this.padding = _defaultPadding,
    this.showTooltip = _defaultShowTooltip,
    this.isFocusable = _defaultIsFocusable,
  }) : super(key: key, intent: intent, onActionInvoked: onActionInvoked);

  final String? icon;
  final String? label;
  final Axis axis;
  final bool isToolbar;
  final double? minimumAspectRatio;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsets padding;
  final bool showTooltip;
  final bool isFocusable;

  @override
  _ActionPushButtonState<I> createState() => _ActionPushButtonState<I>();
}

class _ActionPushButtonState<I extends Intent> extends State<ActionPushButton<I>>
    with ActionTrackerStateMixin<I, ActionPushButton<I>> {
  @override
  Widget build(BuildContext context) {
    return PushButton(
      icon: widget.icon,
      label: widget.label,
      axis: widget.axis,
      isToolbar: widget.isToolbar,
      onPressed: isEnabled ? invokeAction : null,
      minimumAspectRatio: widget.minimumAspectRatio,
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      padding: widget.padding,
      showTooltip: widget.showTooltip,
      isFocusable: widget.isFocusable,
    );
  }
}
