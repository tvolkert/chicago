import 'package:flutter/widgets.dart';

class BoldText extends StatelessWidget {
  const BoldText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    return Text(text, style: boldStyle);
  }
}

class HeaderText extends StatelessWidget {
  const HeaderText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle headerStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: Color(0xff2b5580),
    );
    return Text(text, style: headerStyle);
  }
}

class ColoredText extends StatelessWidget {
  const ColoredText(this.text, this.color, {Key? key}) : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle coloredStyle = baseStyle.copyWith(color: color);
    return Text(text, style: coloredStyle);
  }
}

class WhiteText extends ColoredText {
  const WhiteText(String text, {Key? key})
      : super(text, const Color(0xffffffff), key: key);
}

class GreyText extends ColoredText {
  const GreyText(String text, {Key? key})
      : super(text, const Color(0xff999999), key: key);
}
