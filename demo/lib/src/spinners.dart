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

class SpinnersDemo extends StatefulWidget {
  const SpinnersDemo({Key? key}) : super(key: key);

  @override
  _SpinnersDemoState createState() => _SpinnersDemoState();
}

class _SpinnersDemoState extends State<SpinnersDemo> {
  late chicago.SpinnerController _basicController;
  late chicago.SpinnerController _numericController;
  late chicago.SpinnerController _dateController;

  static Widget _buildBasicItem(context, index, isEnabled) {
    const List<String> numbers = ['One', 'Two', 'Three', 'Four', 'Five'];
    return Text(numbers[index]);
  }

  static Widget _buildNumericItem(context, index, isEnabled) {
    return Text('${index * 4}');
  }

  static Widget _buildDateItem(context, index, isEnabled) {
    const chicago.CalendarDate baseDate = chicago.CalendarDate(2019, 11, 30);
    final chicago.CalendarDate date = baseDate + index;
    return Text(date.toString());
  }

  @override
  void initState() {
    super.initState();
    _basicController = chicago.SpinnerController()..selectedIndex = 0;
    _numericController = chicago.SpinnerController()..selectedIndex = 0;
    _dateController = chicago.SpinnerController()..selectedIndex = 0;
  }

  @override
  void dispose() {
    _basicController.dispose();
    _numericController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return chicago.Rollup(
      heading: const HeaderText('Spinners'),
      childBuilder: (BuildContext context) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chicago.BorderPane(
              borderColor: const Color(0xff999999),
              backgroundColor: const Color(0xffffffff),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chicago.Form(
                      children: [
                        chicago.FormField(
                          label: 'Basic',
                          child: chicago.Spinner(
                            length: 5,
                            isCircular: true,
                            sizeToContent: true,
                            controller: _basicController,
                            itemBuilder: _buildBasicItem,
                          ),
                        ),
                        chicago.FormField(
                          label: 'Numeric',
                          child: SizedBox(
                            width: 60,
                            child: chicago.Spinner(
                              length: 260 ~/ 4,
                              controller: _numericController,
                              itemBuilder: _buildNumericItem,
                            ),
                          ),
                        ),
                        chicago.FormField(
                          label: 'Date',
                          child: chicago.Spinner(
                            length: 365,
                            controller: _dateController,
                            itemBuilder: _buildDateItem,
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
        );
      },
    );
  }
}
