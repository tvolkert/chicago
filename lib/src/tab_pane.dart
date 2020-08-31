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
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Tab {
  const Tab({
    this.label,
    this.builder,
  });

  final String label;
  final WidgetBuilder builder;
}

class TabPane extends StatefulWidget {
  const TabPane({
    Key key,
    this.initialSelectedIndex = 0,
    this.tabs,
  })  : assert(tabs != null),
        super(key: key);

  final int initialSelectedIndex;
  final List<Tab> tabs;

  @override
  _TabPaneState createState() => _TabPaneState();
}

class _TabPaneState extends State<TabPane> {
  int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[];
    for (int i = 0; i < widget.tabs.length; i++) {
      final Tab tab = widget.tabs[i];
      if (i == selectedIndex) {
        tabs.add(
          Ink(
            decoration: const BoxDecoration(
              color: Color(0xfff7f5ee),
              border: Border(
                top: BorderSide(width: 1, color: Color(0xff999999)),
                bottom: BorderSide(width: 1, color: Color(0xfff7f5ee)),
                left: BorderSide(width: 1, color: Color(0xff999999)),
                right: BorderSide(width: 1, color: Color(0xff999999)),
              ),
              gradient: LinearGradient(
                begin: Alignment(0, -0.85),
                end: Alignment(0, -0.65),
                colors: <Color>[Color(0xffe2e0d8), Color(0xfff7f5ee)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
              child: Text(tab.label),
            ),
          ),
        );
      } else {
        tabs.add(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = i;
                });
              },
              child: Ink(
                decoration: const BoxDecoration(
                  color: Color(0xffc4c3bc),
                  border: Border(
                    top: BorderSide(width: 1, color: Color(0xff999999)),
                    bottom: BorderSide(width: 1, color: Color(0xff999999)),
                    left: BorderSide(width: 1, color: Color(0xff999999)),
                    right: BorderSide(width: 1, color: Color(0xff999999)),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment(0, -0.85),
                    end: Alignment(0, -0.65),
                    colors: <Color>[Color(0xffdad8d0), Color(0xffc4c3bc)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
                  child: Text(tab.label),
                ),
              ),
            ),
          ),
        );
      }
      tabs.add(
        Ink(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: Color(0xff999999)),
            ),
          ),
          child: const SizedBox(width: 2),
        ),
      );
    }
    tabs.add(
      Expanded(
        child: Ink(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: Color(0xff999999)),
            ),
          ),
          child: const SizedBox(width: 4),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: tabs,
        ),
        Expanded(
          child: Ink(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(width: 1, color: Color(0xff999999)),
                right: BorderSide(width: 1, color: Color(0xff999999)),
                bottom: BorderSide(width: 1, color: Color(0xff999999)),
              ),
              color: const Color(0xfff7f5ee),
            ),
            child: widget.tabs[selectedIndex].builder(context),
          ),
        ),
      ],
    );
  }
}
