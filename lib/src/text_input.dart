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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    Key? key,
    this.controller,
    this.onKeyEvent,
    this.focusNode,
    this.backgroundColor = const Color(0xffffffff),
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
  }) : super(key: key);

  final TextEditingController? controller;
  final ValueChanged<RawKeyEvent>? onKeyEvent;
  final FocusNode? focusNode;
  final Color backgroundColor;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Widget result = _TextField(
      controller: controller,
      focusNode: focusNode,
      backgroundColor: backgroundColor,
      obscureText: obscureText,
      enabled: enabled,
    );

    if (autofocus) {
      result = _Autofocus(
        textField: result as _TextField,
      );
    }

    if (onKeyEvent != null) {
      result = _RawKeyboardEventRepeater(
        child: result,
        onKeyEvent: onKeyEvent!,
      );
    }

    return result;
  }
}

class _Autofocus extends StatefulWidget {
  const _Autofocus({
    Key? key,
    required this.textField,
  }) : super(key: key);

  final _TextField textField;

  @override
  _AutofocusState createState() => _AutofocusState();
}

class _AutofocusState extends State<_Autofocus> {
  FocusNode? _focusNode;

  FocusNode get focusNode => widget.textField.focusNode ?? _focusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.textField.focusNode == null) {
      _focusNode = FocusNode();
    }
    SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant _Autofocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textField.focusNode != oldWidget.textField.focusNode) {
      if (widget.textField.focusNode == null) {
        assert(_focusNode == null);
        _focusNode = FocusNode();
      } else if (oldWidget.textField.focusNode == null) {
        assert(_focusNode != null);
        _focusNode!.dispose();
        _focusNode = null;
      }
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _TextField result = widget.textField;
    if (_focusNode != null) {
      result = result.copyWith(focusNode: _focusNode!);
    }
    return result;
  }
}

class _RawKeyboardEventRepeater extends StatefulWidget {
  const _RawKeyboardEventRepeater({
    Key? key,
    required this.onKeyEvent,
    required this.child,
  }) : super(key: key);

  final ValueChanged<RawKeyEvent> onKeyEvent;
  final Widget child;

  @override
  _RawKeyboardEventRepeaterState createState() => _RawKeyboardEventRepeaterState();
}

class _RawKeyboardEventRepeaterState extends State<_RawKeyboardEventRepeater> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: widget.onKeyEvent,
      child: widget.child,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    Key? key,
    this.focusNode,
    this.controller,
    this.backgroundColor = const Color(0xffffffff),
    this.obscureText = false,
    this.enabled = true,
  }) : super(key: key);

  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Color backgroundColor;
  final bool obscureText;
  final bool enabled;

  _TextField copyWith({
    required FocusNode focusNode,
  }) {
    return _TextField(
      focusNode: focusNode,
      controller: controller,
      backgroundColor: backgroundColor,
      obscureText: obscureText,
    );
  }

  static const InputBorder _inputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff999999)),
    borderRadius: BorderRadius.zero,
  );

  static const Color _disabledBackgroundColor = Color(0xffdddcd5);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      cursorWidth: 1,
      obscureText: obscureText,
      enabled: enabled,
      cursorColor: const Color(0xff000000),
      style: const TextStyle(fontFamily: 'Verdana', fontSize: 11),
      decoration: InputDecoration(
        fillColor: enabled ? backgroundColor : _disabledBackgroundColor,
        hoverColor: backgroundColor,
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(3, 13, 0, 4),
        isDense: true,
        enabledBorder: _inputBorder,
        focusedBorder: _inputBorder,
        disabledBorder: _inputBorder,
      ),
    );
  }
}
