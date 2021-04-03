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

final chicago.SpinnerController basicSpinnerController = chicago.SpinnerController()
  ..selectedIndex = 0;
final chicago.SpinnerController numericSpinnerController = chicago.SpinnerController()
  ..selectedIndex = 0;
final chicago.SpinnerController dateSpinnerController = chicago.SpinnerController()
  ..selectedIndex = 0;

class SpinnersDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    final TextStyle headerStyle = boldStyle.copyWith(color: Color(0xff2b5580));

    return Column(
      children: [
        Text('Spinners', style: headerStyle),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chicago.Border(
              borderColor: Color(0xff999999),
              backgroundColor: Color(0xffffffff),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('Spinners', style: boldStyle),
                    // SizedBox(height: 4),
                    chicago.Form(
                      children: [
                        chicago.FormField(
                          label: 'Basic',
                          child: chicago.Spinner(
                            length: 5,
                            isCircular: true,
                            sizeToContent: true,
                            controller: basicSpinnerController,
                            itemBuilder: (context, index, isEnabled) {
                              const List<String> numbers = ['One', 'Two', 'Three', 'Four', 'Five'];
                              return Text(numbers[index]);
                            },
                          ),
                        ),
                        chicago.FormField(
                          label: 'Numeric',
                          child: SizedBox(
                            width: 60,
                            child: chicago.Spinner(
                              length: 260 ~/ 4,
                              controller: numericSpinnerController,
                              itemBuilder: (context, index, isEnabled) {
                                return Text('${index * 4}');
                              },
                            ),
                          ),
                        ),
                        chicago.FormField(
                          label: 'Date',
                          child: chicago.Spinner(
                            length: 365,
                            controller: dateSpinnerController,
                            itemBuilder: (context, index, isEnabled) {
                              const chicago.CalendarDate baseDate =
                                  chicago.CalendarDate(2019, 11, 30);
                              final chicago.CalendarDate date = baseDate + index;
                              return Text(date.toString());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4),
            // chicago.Border(
            //   borderColor: Color(0xff999999),
            //   backgroundColor: Color(0xffffffff),
            //   child: Padding(
            //     padding: EdgeInsets.all(2),
            //     child: Column(
            //       children: [
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}
