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

import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/widgets.dart';

import 'text.dart';

class NavigationDemo extends StatelessWidget {
  const NavigationDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chicago.Rollup(
      heading: const HeaderText('Navigation'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // TabsDemo(),
          // SizedBox(width: 12),
          // ExpandersDemo(),
          // SizedBox(width: 12),
          // AccordionDemo(),
          // SizedBox(width: 12),
          RollupDemo(),
        ],
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
  @override
  Widget build(BuildContext context) {
    return chicago.Border(
      borderColor: Color(0xff999999),
      backgroundColor: const Color(0xffffffff),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoldText('Rollups'),
            SizedBox(height: 4),
            chicago.Rollup(
              heading: Text('Colors'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ColoredText('Red', Color(0xffff0000)),
                  ColoredText('Orange', Color(0xffffa500)),
                  ColoredText('Yellow', Color(0xffffff00)),
                  ColoredText('Green', Color(0xff00ff00)),
                  ColoredText('Blue', Color(0xff0000ff)),
                  ColoredText('Purple', Color(0xff800080)),
                ],
              ),
            ),
            chicago.Rollup(
              heading: Text('Shapes'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  chicago.Checkbox(trailing: Text('Circle')),
                  chicago.Checkbox(trailing: Text('Ellipse')),
                  chicago.Checkbox(trailing: Text('Square')),
                  chicago.Checkbox(trailing: Text('Rectangle')),
                  chicago.Checkbox(trailing: Text('Hexagon')),
                  chicago.Checkbox(trailing: Text('Octagon')),
                ],
              ),
            ),
            chicago.Rollup(
              heading: Text('Images'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image(image: AssetImage('assets/anchor.png')),
                      SizedBox(width: 4),
                      Text('Anchor'),
                    ],
                  ),
                  Row(
                    children: [
                      Image(image: AssetImage('assets/bell.png')),
                      SizedBox(width: 4),
                      Text('Bell'),
                    ],
                  ),
                  Row(
                    children: [
                      Image(image: AssetImage('assets/clock.png')),
                      SizedBox(width: 4),
                      Text('Clock'),
                    ],
                  ),
                  Row(
                    children: [
                      Image(image: AssetImage('assets/cup.png')),
                      SizedBox(width: 4),
                      Text('Cup'),
                    ],
                  ),
                  Row(
                    children: [
                      Image(image: AssetImage('assets/house.png')),
                      SizedBox(width: 4),
                      Text('House'),
                    ],
                  ),
                  Row(
                    children: [
                      Image(image: AssetImage('assets/star.png')),
                      SizedBox(width: 4),
                      Text('Star'),
                    ],
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
