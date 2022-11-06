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

import 'package:chicago/src/colors.dart';
import 'package:flutter/widgets.dart';

const double _checkboxSize = 14;
const double _checkmarkSize = 10;
const double _defaultSpacing = 6;

enum CheckboxState {
  checked,
  unchecked,
  mixed,
}

class CheckboxController extends ChangeNotifier {
  CheckboxController.simple([bool checked = false])
      : _isTriState = false,
        _canUserToggleMixed = false,
        _state = checked ? CheckboxState.checked : CheckboxState.unchecked;

  CheckboxController.triState({
    CheckboxState state = CheckboxState.unchecked,
    bool canUserToggleMixed = false,
  })  : _isTriState = true,
        _canUserToggleMixed = canUserToggleMixed,
        _state = state;

  final bool _isTriState;
  bool get isTriState => _isTriState;

  final bool _canUserToggleMixed;
  bool get canUserToggleMixed => _canUserToggleMixed;

  CheckboxState _state;
  CheckboxState get state => _state;
  set state(CheckboxState value) {
    assert(_isTriState || value != CheckboxState.mixed);
    if (_state != value) {
      _state = value;
      notifyListeners();
    }
  }

  bool get checked => _state == CheckboxState.checked;
  set checked(bool value) => state = value ? CheckboxState.checked : CheckboxState.unchecked;

  void toggleState() {
    if (canUserToggleMixed) {
      switch (state) {
        case CheckboxState.checked:
          state = CheckboxState.unchecked;
          break;
        case CheckboxState.unchecked:
          state = CheckboxState.mixed;
          break;
        case CheckboxState.mixed:
          state = CheckboxState.checked;
          break;
      }
    } else {
      checked = !checked;
    }
  }
}

class Checkbox extends StatefulWidget {
  const Checkbox({
    Key? key,
    this.controller,
    this.onChange,
    this.trailing,
    this.spacing = _defaultSpacing,
    this.isEnabled = true,
  }) : super(key: key);

  /// The controller that governs the state of this checkbox.
  ///
  /// If this is unspecified, the checkbox will create and manage its own
  /// simple (non-tri-state) controller.
  final CheckboxController? controller;

  /// Callback that will be invoked when the state of the checkbox changes.
  ///
  /// Users who register for notifications on [controller] will receive the
  /// same notifications.
  final VoidCallback? onChange;

  /// A widget to show after the checkbox.
  ///
  /// Clicking on the widget will act as if the user clicked on the checkbox
  /// itself.
  ///
  /// This widget will be laid out with a spacing in between the checkbox and
  /// the widget. The amount of spacing is determined by the [spacing]
  /// property.
  final Widget? trailing;

  /// The spacing to add in between the checkbox and the [trailing] widget, in
  /// logical pixels.
  ///
  /// If the [trailing] widget is not specified, this value is not used.
  final double spacing;

  /// Whether the checkbox accepts user input.
  ///
  /// If this is false, the checkbox will still respond to changes in its
  /// controller, but the user will not be able to interact with the checkbox.
  final bool isEnabled;

  @override
  _CheckboxState createState() => _CheckboxState();
}

class _CheckboxState extends State<Checkbox> {
  CheckboxController? _controller;

  CheckboxController get controller => _controller ?? widget.controller!;

  void _handleChanged() {
    setState(() {
      // We pull the checked value from the controller.
    });
    if (widget.onChange != null) {
      widget.onChange!();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = CheckboxController.simple();
    }
    controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(covariant Checkbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final CheckboxController oldController = _controller ?? oldWidget.controller!;
      oldController.removeListener(_handleChanged);
      _controller?.dispose();
      _controller = null;
      if (widget.controller == null) {
        _controller = CheckboxController.simple();
      }
      controller.addListener(_handleChanged);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleChanged);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicCheckbox(
      key: widget.key,
      spacing: widget.spacing,
      state: controller.state,
      onTap: widget.isEnabled ? controller.toggleState : null,
      trailing: widget.trailing,
    );
  }
}

class BasicCheckbox extends StatelessWidget {
  const BasicCheckbox({
    Key? key,
    this.state = CheckboxState.unchecked,
    this.onTap,
    this.trailing,
    this.spacing = _defaultSpacing,
  }) : super(key: key);

  final CheckboxState state;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    Widget? styledTrailing = trailing;
    if (styledTrailing != null) {
      styledTrailing = Padding(
        padding: EdgeInsets.only(left: spacing),
        child: styledTrailing,
      );
      if (!isEnabled) {
        styledTrailing = Opacity(
          opacity: 0.5,
          child: styledTrailing,
        );
      }
    }

    final Decoration backgroundDecoration;
    if (isEnabled) {
      backgroundDecoration = BoxDecoration(
        border: const Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            darken(const Color(0xffffffff)),
            const Color(0xffffffff),
          ],
        ),
      );
    } else {
      backgroundDecoration = const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
        color: Color(0xffe6e6e6),
      );
    }

    Widget result = DecoratedBox(
      decoration: backgroundDecoration,
      child: SizedBox(
        width: _checkboxSize,
        height: _checkboxSize,
        child: CustomPaint(painter: CheckPainter(state, isEnabled)),
      ),
    );

    if (styledTrailing != null) {
      result = Row(
        children: <Widget>[
          result,
          styledTrailing,
        ],
      );
    }

    if (isEnabled) {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: result,
          ),
        ),
      );
    }

    return result;
  }
}

class CheckPainter extends CustomPainter {
  const CheckPainter(this.state, this.isEnabled);

  final CheckboxState state;
  final bool isEnabled;

  static const Color _enabledCheckmarkColor = Color(0xff2b5580);
  static const Color _disabledCheckmarkColor = Color(0xff999999);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isEnabled ? _enabledCheckmarkColor : _disabledCheckmarkColor;

    switch (state) {
      case CheckboxState.checked:
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        double n = _checkmarkSize / 2;
        double m = _checkmarkSize / 4;
        double dx = (_checkboxSize - (n + m)) / 2;
        double dy = (_checkboxSize - n) / 2;
        canvas.save();
        canvas.translate(0, (size.height - _checkboxSize) / 2);
        canvas.drawLine(Offset(dx, (n - m) + dy), Offset(m + dx, n + dy), paint);
        canvas.drawLine(Offset(m + dx, n + dy), Offset((m + n) + dx, dy), paint);
        canvas.restore();
        break;
      case CheckboxState.mixed:
        paint
          ..style = PaintingStyle.fill
          ..isAntiAlias = false;
        canvas.drawRect(Rect.fromLTWH(4, _checkboxSize / 2 - 1, _checkboxSize - 8, 2), paint);
        break;
      case CheckboxState.unchecked:
        // Nothing to paint.
        break;
    }
  }

  @override
  bool shouldRepaint(CheckPainter oldDelegate) => state != oldDelegate.state;
}
