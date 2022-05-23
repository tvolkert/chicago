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
import 'package:flutter/services.dart';

import 'foundation.dart';

class TextInput extends StatefulWidget {
  const TextInput({
    super.key,
    this.controller,
    this.onKeyEvent,
    this.onTextUpdated,
    this.validator,
    this.focusNode,
    this.backgroundColor = const Color(0xffffffff),
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final ValueChanged<RawKeyEvent>? onKeyEvent;
  final ValueChanged<String>? onTextUpdated;
  final Predicate<String>? validator;
  final FocusNode? focusNode;
  final Color backgroundColor;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  FocusNode? _focusNode;
  TextEditingController? _controller;
  late TextEditingValue _lastValidValue;

  static const InputBorder _inputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff999999)),
    borderRadius: BorderRadius.zero,
  );

  static const Color _disabledBackgroundColor = Color(0xffdddcd5);

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  TextEditingController get controller => widget.controller ?? _controller!;

  void _handleEdit() {
    final String text = controller.text;
    if (text == _lastValidValue.text) {
      _lastValidValue = controller.value;
    } else if (widget.validator == null) {
      _lastValidValue = controller.value;
      if (widget.onTextUpdated != null) widget.onTextUpdated!(text);
    } else if (widget.validator!(text)) {
      _lastValidValue = controller.value;
      if (widget.onTextUpdated != null) widget.onTextUpdated!(text);
    } else {
      controller.value = _lastValidValue;
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
    }
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
    controller.addListener(_handleEdit);
    _lastValidValue = controller.value;
    if (widget.autofocus) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        if (mounted) {
          focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (widget.focusNode == null) {
        assert(_focusNode == null);
        _focusNode = FocusNode();
      } else if (oldWidget.focusNode == null) {
        assert(_focusNode != null);
        _focusNode!.dispose();
        _focusNode = null;
      }
    }
    if (widget.controller != oldWidget.controller) {
      if (widget.controller == null) {
        assert(_controller == null);
        oldWidget.controller!.removeListener(_handleEdit);
        _controller = TextEditingController();
        _controller!.addListener(_handleEdit);
      } else if (oldWidget.controller == null) {
        assert(_controller != null);
        _controller!.removeListener(_handleEdit);
        _controller!.dispose();
        _controller = null;
        widget.controller!.addListener(_handleEdit);
      } else {
        oldWidget.controller!.removeListener(_handleEdit);
        widget.controller!.addListener(_handleEdit);
      }
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller?.removeListener(_handleEdit);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = TextField(
      controller: controller,
      focusNode: widget.onKeyEvent == null ? focusNode : null,
      cursorWidth: 1,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      cursorColor: const Color(0xff000000),
      style: const TextStyle(fontFamily: 'Verdana', fontSize: 11),
      decoration: InputDecoration(
        fillColor:
            widget.enabled ? widget.backgroundColor : _disabledBackgroundColor,
        hoverColor: widget.backgroundColor,
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(3, 13, 0, 4),
        isDense: true,
        enabledBorder: _inputBorder,
        focusedBorder: _inputBorder,
        disabledBorder: _inputBorder,
      ),
    );

    if (widget.onKeyEvent != null) {
      result = RawKeyboardListener(
        focusNode: focusNode,
        onKey: widget.onKeyEvent,
        child: result,
      );
    }

    return result;
  }
}
