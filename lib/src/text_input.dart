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

class TextInput extends StatelessWidget {
  const TextInput({
    Key key,
    this.controller,
    this.backgroundColor = const Color(0xffffffff),
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController controller;

  final Color backgroundColor;

  final bool obscureText;

  static const InputBorder _inputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff999999)),
    borderRadius: BorderRadius.zero,
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorWidth: 1,
      obscureText: obscureText,
      cursorColor: const Color(0xff000000),
      style: const TextStyle(fontFamily: 'Verdana', fontSize: 11),
      decoration: InputDecoration(
        fillColor: backgroundColor,
        hoverColor: backgroundColor,
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(3, 13, 0, 4),
        isDense: true,
        enabledBorder: _inputBorder,
        focusedBorder: _inputBorder,
      ),
    );
  }
}
