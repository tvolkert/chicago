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

class SplittersDemo extends StatelessWidget {
  const SplittersDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Rollup(
      heading: HeaderText('Splitters'),
      childBuilder: (BuildContext context) {
        return BorderPane(
          borderColor: Color(0xff999999),
          backgroundColor: Color(0xffffffff),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: SizedBox(
              width: 400,
              height: 360,
              child: SplitPane(
                orientation: Axis.vertical,
                initialSplitRatio: 0.5,
                before: SplitPane(
                  orientation: Axis.horizontal,
                  initialSplitRatio: 0.5,
                  before: BorderPane(
                    borderColor: Color(0xff999999),
                    child: Image(image: AssetImage('assets/bell.png')),
                  ),
                  after: BorderPane(
                    borderColor: Color(0xff999999),
                    child: Image(image: AssetImage('assets/clock.png')),
                  ),
                ),
                after: BorderPane(
                  borderColor: Color(0xff999999),
                  child: Image(image: AssetImage('assets/star.png')),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
