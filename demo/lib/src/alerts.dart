import 'package:chicago/chicago.dart' as chicago;
import 'package:flutter/widgets.dart';

import 'text.dart';

class AlertsDemo extends StatelessWidget {
  const AlertsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderText('Alerts'),
        SizedBox(height: 4),
        chicago.Border(
          borderColor: Color(0xff999999),
          backgroundColor: const Color(0xffffffff),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(height: 6),
                chicago.PushButton(
                  label: 'Show Prompt',
                  onPressed: () {
                    chicago.Prompt.open(
                      context: context,
                      messageType: chicago.MessageType.error,
                      message: 'This is an error message.',
                      body: Container(),
                      options: ['OK'],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
