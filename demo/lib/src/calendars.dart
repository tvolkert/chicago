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

class CalendarsDemo extends StatelessWidget {
  const CalendarsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return chicago.Rollup(
      heading: HeaderText('Calendars'),
      childBuilder: (BuildContext context) {
        return chicago.Border(
          backgroundColor: Color(0xffffffff),
          borderColor: Color(0xff999999),
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 4, 6, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BoldText('Basic'),
                    chicago.Calendar(
                      initialYear: 2021,
                      initialMonth: 2,
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BoldText('Calendar Buttons'),
                    chicago.CalendarButton(
                      initialSelectedDate: chicago.CalendarDate.today(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
