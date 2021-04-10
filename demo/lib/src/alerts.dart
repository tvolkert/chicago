import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/widgets.dart';

import 'text.dart';

class AlertsDemo extends StatefulWidget {
  const AlertsDemo({Key? key}) : super(key: key);

  @override
  _AlertsDemoState createState() => _AlertsDemoState();
}

class _AlertsDemoState extends State<AlertsDemo> {
  late chicago.RadioButtonController<chicago.MessageType?> _controller;
  late chicago.RadioButtonController<String> _iconController;

  static const Map<chicago.MessageType, String> _messages = {
    chicago.MessageType.error: 'This is an error message.',
    chicago.MessageType.warning: 'This is a warning message.',
    chicago.MessageType.question: 'This is a question message.',
    chicago.MessageType.info: 'This is an info message.',
  };

  void _handleShowPrompt() {
    if (_controller.value != null) {
      chicago.Prompt.open(
        context: context,
        messageType: _controller.value!,
        message: _messages[_controller.value!]!,
        body: Container(),
        options: ['OK'],
        selectedOption: 0,
      );
    } else {
      chicago.Prompt.open(
        context: context,
        messageType: chicago.MessageType.question,
        message: 'Please select your favorite icon:',
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chicago.RadioButton<String>(
              value: 'bell',
              controller: _iconController,
              trailing: Row(
                children: [
                  Image(image: AssetImage('assets/bell.png')),
                  SizedBox(width: 4),
                  Text('Bell'),
                ],
              ),
            ),
            SizedBox(height: 4),
            chicago.RadioButton<String>(
              value: 'clock',
              controller: _iconController,
              trailing: Row(
                children: [
                  Image(image: AssetImage('assets/clock.png')),
                  SizedBox(width: 4),
                  Text('Clock'),
                ],
              ),
            ),
            SizedBox(height: 4),
            chicago.RadioButton<String>(
              value: 'house',
              controller: _iconController,
              trailing: Row(
                children: [
                  Image(image: AssetImage('assets/house.png')),
                  SizedBox(width: 4),
                  Text('House'),
                ],
              ),
            ),
          ],
        ),
        options: ['OK', 'Cancel'],
        selectedOption: 0,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = chicago.RadioButtonController<chicago.MessageType>(chicago.MessageType.error);
    _iconController = chicago.RadioButtonController<String>('house');
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return chicago.Rollup(
      heading: HeaderText('Alerts'),
      childBuilder: (BuildContext context) {
        return chicago.BorderPane(
          borderColor: Color(0xff999999),
          backgroundColor: const Color(0xffffffff),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chicago.RadioButton<chicago.MessageType?>(
                  value: chicago.MessageType.error,
                  controller: _controller,
                  trailing: Text('Error'),
                ),
                SizedBox(height: 4),
                chicago.RadioButton<chicago.MessageType?>(
                  value: chicago.MessageType.warning,
                  controller: _controller,
                  trailing: Text('Warning'),
                ),
                SizedBox(height: 4),
                chicago.RadioButton<chicago.MessageType?>(
                  value: chicago.MessageType.question,
                  controller: _controller,
                  trailing: Text('Question'),
                ),
                SizedBox(height: 4),
                chicago.RadioButton<chicago.MessageType?>(
                  value: chicago.MessageType.info,
                  controller: _controller,
                  trailing: Text('Info'),
                ),
                SizedBox(height: 4),
                chicago.RadioButton<chicago.MessageType?>(
                  value: null,
                  controller: _controller,
                  trailing: Text('Custom'),
                ),
                SizedBox(height: 6),
                chicago.PushButton(
                  label: 'Show Prompt',
                  onPressed: _handleShowPrompt,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
