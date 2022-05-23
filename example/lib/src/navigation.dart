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

import 'package:chicago/chicago.dart';
import 'package:flutter/widgets.dart';

import 'text.dart';

class NavigationDemo extends StatelessWidget {
  const NavigationDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Rollup(
      heading: const HeaderText('Navigation'),
      semanticLabel: 'Navigation',
      childBuilder: (BuildContext context) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            TabsDemo(),
            SizedBox(width: 12),
            // ExpandersDemo(),
            // SizedBox(width: 12),
            // AccordionDemo(),
            // SizedBox(width: 12),
            RollupDemo(),
          ],
        );
      },
    );
  }
}

class TabsDemo extends StatelessWidget {
  const TabsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BorderPane(
      borderColor: Color(0xff999999),
      backgroundColor: const Color(0xffffffff),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoldText('Tab Pane'),
            SizedBox(height: 4),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: 100,
              ),
              child: TabPane(
                tabs: [
                  Tab(
                    label: 'Pomegranate',
                    builder: (BuildContext context) {
                      return Center(
                          child: ColoredText('Red', Color(0xffff0000)));
                    },
                  ),
                  Tab(
                    label: 'Mango',
                    builder: (BuildContext context) {
                      return Center(
                          child: ColoredText('Orange', Color(0xffffa500)));
                    },
                  ),
                  Tab(
                    label: 'Banana',
                    builder: (BuildContext context) {
                      return Center(
                          child: ColoredText('Yellow', Color(0xffffff00)));
                    },
                  ),
                  Tab(
                    label: 'Lime',
                    builder: (BuildContext context) {
                      return Center(
                          child: ColoredText('Green', Color(0xff00ff00)));
                    },
                  ),
                  Tab(
                    label: 'Blueberry',
                    builder: (BuildContext context) {
                      return Center(
                          child: ColoredText('Blue', Color(0xff0000ff)));
                    },
                  ),
                  Tab(
                    label: 'Plum',
                    builder: (BuildContext context) {
                      return Center(
                          child: ColoredText('Purple', Color(0xff800080)));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RollupDemo extends StatefulWidget {
  const RollupDemo({Key? key}) : super(key: key);

  @override
  _RollupDemoState createState() => _RollupDemoState();
}

class _RollupDemoState extends State<RollupDemo> {
  late CheckboxController _ellipseController;
  late CheckboxController _squareController;
  late CheckboxController _octagonController;
  late RadioButtonController<String> _radioController;

  @override
  void initState() {
    super.initState();
    _ellipseController = CheckboxController.simple(true);
    _squareController = CheckboxController.simple(true);
    _octagonController = CheckboxController.simple(true);
    _radioController = RadioButtonController<String>('star');
  }

  @override
  void dispose() {
    _ellipseController.dispose();
    _squareController.dispose();
    _octagonController.dispose();
    _radioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BorderPane(
      borderColor: Color(0xff999999),
      backgroundColor: const Color(0xffffffff),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoldText('Rollups'),
            SizedBox(height: 4),
            Rollup(
              heading: Text('Colors'),
              semanticLabel: 'Colors',
              childBuilder: (BuildContext context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ColoredText('Red', Color(0xffff0000)),
                    ColoredText('Orange', Color(0xffffa500)),
                    ColoredText('Yellow', Color(0xffffff00)),
                    ColoredText('Green', Color(0xff00ff00)),
                    ColoredText('Blue', Color(0xff0000ff)),
                    ColoredText('Purple', Color(0xff800080)),
                  ],
                );
              },
            ),
            Rollup(
              heading: Text('Shapes'),
              semanticLabel: 'Shapes',
              childBuilder: (BuildContext context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Checkbox(trailing: Text('Circle')),
                    Checkbox(
                        trailing: Text('Ellipse'),
                        controller: _ellipseController),
                    Checkbox(
                        trailing: Text('Square'),
                        controller: _squareController),
                    const Checkbox(trailing: Text('Rectangle')),
                    const Checkbox(trailing: Text('Hexagon')),
                    Checkbox(
                        trailing: Text('Octagon'),
                        controller: _octagonController),
                  ],
                );
              },
            ),
            Rollup(
              heading: Text('Images'),
              semanticLabel: 'Images',
              childBuilder: (BuildContext context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioButton<String>(
                      value: 'anchor',
                      controller: _radioController,
                      trailing: Row(
                        children: [
                          Image(image: AssetImage('assets/anchor.png')),
                          SizedBox(width: 4),
                          Text('Anchor'),
                        ],
                      ),
                    ),
                    RadioButton<String>(
                      value: 'bell',
                      controller: _radioController,
                      trailing: Row(
                        children: [
                          Image(image: AssetImage('assets/bell.png')),
                          SizedBox(width: 4),
                          Text('Bell'),
                        ],
                      ),
                    ),
                    RadioButton<String>(
                      value: 'clock',
                      controller: _radioController,
                      trailing: Row(
                        children: [
                          Image(image: AssetImage('assets/clock.png')),
                          SizedBox(width: 4),
                          Text('Clock'),
                        ],
                      ),
                    ),
                    RadioButton<String>(
                      value: 'cup',
                      controller: _radioController,
                      trailing: Row(
                        children: [
                          Image(image: AssetImage('assets/cup.png')),
                          SizedBox(width: 4),
                          Text('Cup'),
                        ],
                      ),
                    ),
                    RadioButton<String>(
                      value: 'house',
                      controller: _radioController,
                      trailing: Row(
                        children: [
                          Image(image: AssetImage('assets/house.png')),
                          SizedBox(width: 4),
                          Text('House'),
                        ],
                      ),
                    ),
                    RadioButton<String>(
                      value: 'star',
                      controller: _radioController,
                      trailing: Row(
                        children: [
                          Image(image: AssetImage('assets/star.png')),
                          SizedBox(width: 4),
                          Text('Star'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
