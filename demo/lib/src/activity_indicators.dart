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

class ActivityIndicatorsDemo extends StatelessWidget {
  const ActivityIndicatorsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chicago.Rollup(
      heading: const HeaderText('Activity Indicators'),
      child: chicago.Border(
        borderColor: const Color(0xff999999),
        backgroundColor: const Color(0xffffffff),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // MetersDemo(),
              // SizedBox(width: 12),
              ActivityIndicatorDemo(),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityIndicatorDemo extends StatelessWidget {
  const ActivityIndicatorDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText('Activity Indicators'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: chicago.ActivityIndicator(),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: chicago.ActivityIndicator(color: Color(0xffaa0000)),
            ),
            SizedBox(
              width: 96,
              height: 96,
              child: chicago.ActivityIndicator(color: Color(0xff4c82b8)),
            ),
          ],
        ),
      ],
    );
  }
}
