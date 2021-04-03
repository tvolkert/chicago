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

class WhiteText extends StatelessWidget {
  const WhiteText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle whiteStyle = baseStyle.copyWith(color: Color(0xffffffff));
    return Text(text, style: whiteStyle);
  }
}

class GreyText extends StatelessWidget {
  const GreyText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(context).style;
    final TextStyle greyStyle = baseStyle.copyWith(color: Color(0xff999999));
    return Text(text, style: greyStyle);
  }
}
