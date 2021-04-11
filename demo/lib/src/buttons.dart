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

VoidCallback _acknowledgeAction(BuildContext context, String action) {
  return () {
    Prompt.open(
      context: context,
      messageType: MessageType.info,
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
  late RollupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RollupController(isExpanded: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Rollup(
      controller: _controller,
      heading: HeaderText('Buttons'),
      childBuilder: (BuildContext context) {
        return Row(
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
        );
      },
    );
  }
}

class BasicButtonsDemo extends StatelessWidget {
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
            BoldText('Basic Push Buttons'),
            SizedBox(height: 4),
            Row(
              children: [
                PushButton(
                  label: 'One',
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                PushButton(
                  label: 'Two',
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                PushButton(label: 'Three'),
              ],
            ),
            SizedBox(height: 10),
            BoldText('Image Buttons'),
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PushButton(
                  label: 'Bell',
                  icon: 'assets/bell.png',
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                PushButton(
                  label: 'Clock',
                  icon: 'assets/clock.png',
                  axis: Axis.vertical,
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                PushButton(
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
                PushButton(
                  icon: 'assets/bell.png',
                  isToolbar: true,
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                PushButton(
                  icon: 'assets/clock.png',
                  isToolbar: true,
                  onPressed: _acknowledgeButtonPress(context),
                ),
                SizedBox(width: 4),
                PushButton(
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
  late RadioButtonController<String> _basicController;
  late RadioButtonController<String> _imageController;

  @override
  void initState() {
    super.initState();
    _basicController = RadioButtonController('three');
    _imageController = RadioButtonController('house');
  }

  @override
  void dispose() {
    _basicController.dispose();
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
            BoldText('Basic Radio Buttons'),
            SizedBox(height: 4),
            Row(
              children: [
                RadioButton<String>(
                  value: 'one',
                  controller: _basicController,
                  trailing: Text('One'),
                ),
                SizedBox(width: 4),
                RadioButton<String>(
                  value: 'two',
                  controller: _basicController,
                  trailing: Text('Two'),
                ),
                SizedBox(width: 4),
                RadioButton<String>(
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
                RadioButton<String>(
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
                RadioButton<String>(
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
                RadioButton<String>(
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
  late CheckboxController _threeController;
  late CheckboxController _houseController;
  late CheckboxController _readController;
  late CheckboxController _writeController;
  late CheckboxController _executeController;

  @override
  void initState() {
    super.initState();
    _threeController = CheckboxController.simple(true);
    _houseController = CheckboxController.simple(true);
    _readController = CheckboxController.triState(
      state: CheckboxState.checked,
      canUserToggleMixed: true,
    );
    _writeController = CheckboxController.triState(
      state: CheckboxState.unchecked,
      canUserToggleMixed: true,
    );
    _executeController = CheckboxController.triState(
      state: CheckboxState.mixed,
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
    return BorderPane(
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
                Checkbox(trailing: Text('One')),
                SizedBox(width: 4),
                Checkbox(trailing: Text('Two')),
                SizedBox(width: 4),
                Checkbox(
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
                Checkbox(
                  trailing: Row(
                    children: [
                      Image.asset('assets/clock.png'),
                      SizedBox(width: 4),
                      Text('Clock'),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Checkbox(
                  trailing: Row(
                    children: [
                      Image.asset('assets/bell.png'),
                      SizedBox(width: 4),
                      Text('Bell'),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Checkbox(
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
                Checkbox(
                  controller: _readController,
                  trailing: Text('Read'),
                ),
                SizedBox(height: 4),
                Checkbox(
                  controller: _writeController,
                  trailing: Text('Write'),
                ),
                SizedBox(height: 4),
                Checkbox(
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
    return BorderPane(
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
                LinkButton(
                  text: 'One',
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(width: 4),
                LinkButton(
                  text: 'Two',
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(width: 4),
                LinkButton(text: 'Three'),
              ],
            ),
            SizedBox(height: 10),
            BoldText('Image Link Buttons'),
            SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinkButton(
                  text: 'Bell',
                  image: AssetImage('assets/bell.png'),
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(height: 4),
                LinkButton(
                  text: 'Clock',
                  image: AssetImage('assets/clock.png'),
                  onPressed: _acknowledgeLinkPress(context),
                ),
                SizedBox(height: 4),
                LinkButton(
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
