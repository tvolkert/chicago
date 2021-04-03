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

VoidCallback _acknowledgeAction(BuildContext context, String action) {
  return () {
    chicago.Prompt.open(
      context: context,
      messageType: chicago.MessageType.info,
      message: 'Registered $action.',
      body: Container(),
      options: ['OK'],
      selectedOption: 0,
    );
  };
}

VoidCallback _acknowledgeButtonPress(BuildContext context) {
  return _acknowledgeAction(context, 'a button press');
}

VoidCallback _acknowledgeLinkPress(BuildContext context) {
  return _acknowledgeAction(context, 'a link');
}

class ButtonsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderText('Buttons'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicButtonsDemo(),
            SizedBox(width: 4),
            CheckboxesDemo(),
            SizedBox(width: 4),
            LinkButtonsDemo(),
          ],
        ),
      ],
    );
  }
}

class BasicButtonsDemo extends StatelessWidget {
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
            BoldText('Basic Push Buttons'),
            SizedBox(height: 4),
            Row(
              children: [
                chicago.PushButton(
                  label: 'One',
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                chicago.PushButton(
                  label: 'Two',
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                chicago.PushButton(label: 'Three'),
              ],
            ),
            SizedBox(height: 10),
            BoldText('Image Buttons'),
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chicago.PushButton(
                  label: 'Bell',
                  icon: 'assets/bell.png',
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                chicago.PushButton(
                  label: 'Clock',
                  icon: 'assets/clock.png',
                  axis: Axis.vertical,
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                chicago.PushButton(
                  label: 'House',
                  icon: 'assets/house.png',
                ),
              ],
            ),
            SizedBox(height: 10),
            BoldText('Toolbar Buttons'),
            SizedBox(height: 4),
            Row(
              children: [
                chicago.PushButton(
                  icon: 'assets/bell.png',
                  isToolbar: true,
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                chicago.PushButton(
                  icon: 'assets/clock.png',
                  isToolbar: true,
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                chicago.PushButton(
                  icon: 'assets/house.png',
                  isToolbar: true,
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class CheckboxesDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return             chicago.Border(
      borderColor: Color(0xff999999),
      backgroundColor: const Color(0xffffffff),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoldText('Basic Checkboxes'),
            SizedBox(height: 4),
            Row(
              children: [
                chicago.Checkbox(trailing: Text('One')),
                SizedBox(width: 4),
                chicago.Checkbox(trailing: Text('Two')),
                SizedBox(width: 4),
                chicago.Checkbox(trailing: Text('Three')),
              ],
            ),
            SizedBox(height: 10),
            BoldText('Image Checkboxes'),
            SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chicago.Checkbox(
                  trailing: Row(
                    children: [
                      Image.asset('assets/clock.png'),
                      SizedBox(width: 4),
                      Text('Clock'),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                chicago.Checkbox(
                  trailing: Row(
                    children: [
                      Image.asset('assets/bell.png'),
                      SizedBox(width: 4),
                      Text('Bell'),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                chicago.Checkbox(
                  trailing: Row(
                    children: [
                      Image.asset('assets/house.png'),
                      SizedBox(width: 4),
                      Text('House'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LinkButtonsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return             chicago.Border(
      borderColor: Color(0xff999999),
      backgroundColor: const Color(0xffffffff),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoldText('Basic Link Buttons'),
            SizedBox(height: 4),
            Row(
              children: [
                chicago.LinkButton(
                  text: 'One',
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(width: 4),
                chicago.LinkButton(
                  text: 'Two',
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(width: 4),
                chicago.LinkButton(text: 'Three'),
              ],
            ),
            SizedBox(height: 10),
            BoldText('Image Link Buttons'),
            SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chicago.LinkButton(
                  text: 'Bell',
                  image: AssetImage('assets/bell.png'),
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(height: 4),
                chicago.LinkButton(
                  text: 'Clock',
                  image: AssetImage('assets/clock.png'),
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(height: 4),
                chicago.LinkButton(
                  text: 'House',
                  image: AssetImage('assets/house.png'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
