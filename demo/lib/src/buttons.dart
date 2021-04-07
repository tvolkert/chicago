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

class ButtonsDemo extends StatefulWidget {
  const ButtonsDemo({Key? key}) : super(key: key);

  @override
  _ButtonsDemoState createState() => _ButtonsDemoState();
}

class _ButtonsDemoState extends State<ButtonsDemo> {
  late chicago.RollupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = chicago.RollupController(isExpanded: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return chicago.Rollup(
      controller: _controller,
      heading: HeaderText('Buttons'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BasicButtonsDemo(),
          SizedBox(width: 4),
          RadioButtonsDemo(),
          SizedBox(width: 4),
          CheckboxesDemo(),
          SizedBox(width: 4),
          LinkButtonsDemo(),
        ],
      ),
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
          ],
        ),
      ),
    );
  }
}

class RadioButtonsDemo extends StatefulWidget {
  @override
  _RadioButtonsDemoState createState() => _RadioButtonsDemoState();
}

class _RadioButtonsDemoState extends State<RadioButtonsDemo> {
  late chicago.RadioButtonController<String> _basicController;
  late chicago.RadioButtonController<String> _imageController;

  @override
  void initState() {
    super.initState();
    _basicController = chicago.RadioButtonController('three');
    _imageController = chicago.RadioButtonController('house');
  }

  @override
  void dispose() {
    _basicController.dispose();
    super.dispose();
  }

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
            BoldText('Basic Radio Buttons'),
            SizedBox(height: 4),
            Row(
              children: [
                chicago.RadioButton<String>(
                  value: 'one',
                  controller: _basicController,
                  trailing: Text('One'),
                ),
                SizedBox(width: 4),
                chicago.RadioButton<String>(
                  value: 'two',
                  controller: _basicController,
                  trailing: Text('Two'),
                ),
                SizedBox(width: 4),
                chicago.RadioButton<String>(
                  value: 'three',
                  controller: _basicController,
                  trailing: Text('Three'),
                  isEnabled: false,
                ),
              ],
            ),
            SizedBox(height: 10),
            BoldText('Image Radio Buttons'),
            SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chicago.RadioButton<String>(
                  value: 'bell',
                  controller: _imageController,
                  trailing: Row(
                    children: [
                      Image.asset('assets/bell.png'),
                      SizedBox(width: 4),
                      Text('Bell'),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                chicago.RadioButton<String>(
                  value: 'clock',
                  controller: _imageController,
                  trailing: Row(
                    children: [
                      Image.asset('assets/clock.png'),
                      SizedBox(width: 4),
                      Text('Clock'),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                chicago.RadioButton<String>(
                  value: 'house',
                  controller: _imageController,
                  isEnabled: false,
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

class CheckboxesDemo extends StatefulWidget {
  @override
  _CheckboxesDemoState createState() => _CheckboxesDemoState();
}

class _CheckboxesDemoState extends State<CheckboxesDemo> {
  late chicago.CheckboxController _threeController;
  late chicago.CheckboxController _houseController;
  late chicago.CheckboxController _readController;
  late chicago.CheckboxController _writeController;
  late chicago.CheckboxController _executeController;

  @override
  void initState() {
    super.initState();
    _threeController = chicago.CheckboxController.simple(true);
    _houseController = chicago.CheckboxController.simple(true);
    _readController = chicago.CheckboxController.triState(
      state: chicago.CheckboxState.checked,
      canUserToggleMixed: true,
    );
    _writeController = chicago.CheckboxController.triState(
      state: chicago.CheckboxState.unchecked,
      canUserToggleMixed: true,
    );
    _executeController = chicago.CheckboxController.triState(
      state: chicago.CheckboxState.mixed,
      canUserToggleMixed: true,
    );
  }

  @override
  void dispose() {
    _threeController.dispose();
    _houseController.dispose();
    _readController.dispose();
    _writeController.dispose();
    _executeController.dispose();
    super.dispose();
  }

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
            BoldText('Basic Checkboxes'),
            SizedBox(height: 4),
            Row(
              children: [
                chicago.Checkbox(trailing: Text('One')),
                SizedBox(width: 4),
                chicago.Checkbox(trailing: Text('Two')),
                SizedBox(width: 4),
                chicago.Checkbox(
                  trailing: Text('Three'),
                  controller: _threeController,
                  isEnabled: false,
                ),
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
                  controller: _houseController,
                  isEnabled: false,
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
            SizedBox(height: 10),
            BoldText('Tri-state Checkboxes'),
            SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chicago.Checkbox(
                  controller: _readController,
                  trailing: Text('Read'),
                ),
                SizedBox(height: 4),
                chicago.Checkbox(
                  controller: _writeController,
                  trailing: Text('Write'),
                ),
                SizedBox(height: 4),
                chicago.Checkbox(
                  controller: _executeController,
                  trailing: Text('Execute'),
                  isEnabled: false,
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
    return chicago.Border(
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
