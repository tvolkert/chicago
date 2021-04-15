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

import 'dart:ui' as ui;

import 'package:chicago/chicago.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class RadioButtonController<T> extends ValueNotifier<T?> {
  RadioButtonController([T? value]) : super(value);
}

class RadioButton<T> extends StatefulWidget {
  const RadioButton({
    Key? key,
    required this.value,
    required this.controller,
    this.spacing = 4,
    this.trailing,
    this.isEnabled = true,
  }) : super(key: key);

  final T value;
  final RadioButtonController<T> controller;
  final double spacing;
  final Widget? trailing;
  final bool isEnabled;

  @override
  _RadioButtonState<T> createState() => _RadioButtonState<T>();
}

class _RadioButtonState<T> extends State<RadioButton<T>> {
  void _handleGroupValueChanged() {
    setState(() {
      // State is held in our controller.
    });
  }

  void _handleSelected() {
    widget.controller.value = widget.value;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleGroupValueChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleGroupValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicRadioButton(
      key: widget.key,
      isSelected: widget.value == widget.controller.value,
      spacing: widget.spacing,
      trailing: widget.trailing,
      onSelected: widget.isEnabled ? _handleSelected : null,
    );
  }
}

class BasicRadioButton extends StatelessWidget {
  const BasicRadioButton({
    Key? key,
    this.isSelected = false,
    this.spacing = 4,
    this.trailing,
    this.onSelected,
  }) : super(key: key);

  final bool isSelected;
  final double spacing;
  final Widget? trailing;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onSelected != null;

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

    Widget result = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _RawRadioButton(
          isSelected: isSelected,
          isEnabled: isEnabled,
        ),
        if (styledTrailing != null) styledTrailing,
      ],
    );

    if (isEnabled) {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AbsorbPointer(
          child: result,
        ),
      );

      if (!isSelected) {
        result = GestureDetector(
          onTap: onSelected,
          child: result,
        );
      }
    }

    return result;
  }
}

class _RawRadioButton extends LeafRenderObjectWidget {
  const _RawRadioButton({
    Key? key,
    required this.isSelected,
    required this.isEnabled,
  }) : super(key: key);

  final bool isSelected;
  final bool isEnabled;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRawRadioButton(
      isSelected: isSelected,
      isEnabled: isEnabled,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderRawRadioButton renderObject) {
    renderObject
      ..isSelected = isSelected
      ..isEnabled = isEnabled;
  }
}

class _RenderRawRadioButton extends RenderBox {
  _RenderRawRadioButton({
    bool isSelected = false,
    bool isEnabled = true,
  })  : _isSelected = isSelected,
        _isEnabled = isEnabled;

  static const double _diameter = 14;
  static const double _selectionDiameter = 6;

  late bool _isSelected;
  bool get isSelected => _isSelected;
  set isSelected(bool value) {
    if (value != _isSelected) {
      _isSelected = value;
      markNeedsPaint();
    }
  }

  late bool _isEnabled;
  bool get isEnabled => _isEnabled;
  set isEnabled(bool value) {
    if (value != _isEnabled) {
      _isEnabled = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrainDimensions(_diameter, _diameter);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Color buttonColor = const Color(0xffffffff);
    final Color borderColor;
    final Color selectionColor;
    final Paint paint = Paint();
    final Rect backgroundCircle = Rect.fromLTWH(1, 1, _diameter - 3, _diameter - 3);

    if (isEnabled) {
      paint.shader = ui.Gradient.radial(
        backgroundCircle.center,
        backgroundCircle.width * 2 / 3,
        <Color>[darken(buttonColor), buttonColor],
      );
      borderColor = const Color(0xff999999);
      selectionColor = const Color(0xff2b5580);
    } else {
      paint.color = const Color(0xffe6e6e6);
      borderColor = const Color(0xff999999);
      selectionColor = const Color(0xff999999);
    }

    // Center the button vertically
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy + (size.height - _diameter) / 2);
    try {
      // Paint the border
      final Paint borderPaint = Paint()..color = borderColor;
      context.canvas.drawOval(Rect.fromLTWH(0, 0, _diameter - 1, _diameter - 1), borderPaint);

      // Paint the background
      context.canvas.drawOval(backgroundCircle, paint);

      // Paint the selection
      if (isSelected) {
        Paint selectionPaint = Paint()..color = selectionColor;
        final Rect selection = Rect.fromLTWH(
          (_diameter - _selectionDiameter) / 2,
          (_diameter - _selectionDiameter) / 2,
          _selectionDiameter - 1,
          _selectionDiameter - 1,
        );
        context.canvas.drawOval(selection, selectionPaint);
      }
    } finally {
      context.canvas.restore();
    }
  }
}
