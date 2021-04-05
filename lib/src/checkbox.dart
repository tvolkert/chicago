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

const double _checkboxSize = 14;
const double _checkmarkSize = 10;
const double _defaultSpacing = 6;
const Color _defaultBorderColor = Color(0xff999999);
const Color _defaultCheckmarkColor = Color(0xff2b5580);

class CheckboxController extends ChangeNotifier {
  bool _checked = false;
  bool get checked => _checked;
  set checked(bool value) {
    if (_checked != value) {
      _checked = value;
      notifyListeners();
    }
  }

  void toggleChecked() => checked = !_checked;
}

class Checkbox extends StatefulWidget {
  const Checkbox({
    Key? key,
    this.spacing = _defaultSpacing,
    this.controller,
    this.checkmarkColor,
    this.onChange,
    this.trailing,
  }) : super(key: key);

  final double spacing;
  final CheckboxController? controller;
  final Color? checkmarkColor;
  final VoidCallback? onChange;
  final Widget? trailing;

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
      _controller = CheckboxController();
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
        _controller = CheckboxController();
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
      checked: controller.checked,
      checkmarkColor: widget.checkmarkColor,
      onTap: () => controller.toggleChecked(),
      trailing: widget.trailing,
    );
  }
}

class BasicCheckbox extends StatelessWidget {
  const BasicCheckbox({
    Key? key,
    this.spacing = _defaultSpacing,
    this.checked = false,
    this.checkmarkColor,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  final double spacing;
  final bool checked;
  final Color? checkmarkColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    Widget selectableRegion = DecoratedBox(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: _defaultBorderColor)),
        color: const Color(0xffffffff),
      ),
      child: SizedBox(
        width: _checkboxSize,
        height: _checkboxSize,
        child: CustomPaint(painter: _CheckPainter(checked, checkmarkColor)),
      ),
    );

    if (trailing != null) {
      selectableRegion = Row(
        children: <Widget>[
          selectableRegion,
          SizedBox(width: spacing),
          trailing!,
        ],
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: selectableRegion,
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.checked, this.checkmarkColor);

  final bool checked;
  final Color? checkmarkColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (checked) {
      final Paint paint = Paint()
        ..color = checkmarkColor ?? _defaultCheckmarkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      double n = _checkmarkSize / 2;
      double m = _checkmarkSize / 4;
      double dx = (_checkboxSize - (n + m)) / 2;
      double dy = (_checkboxSize - n) / 2;
      canvas.translate(0, (size.height - _checkboxSize) / 2);
      canvas.drawLine(Offset(dx, (n - m) + dy), Offset(m + dx, n + dy), paint);
      canvas.drawLine(Offset(m + dx, n + dy), Offset((m + n) + dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => checked != oldDelegate.checked;
}
