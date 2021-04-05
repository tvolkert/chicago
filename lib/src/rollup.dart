import 'package:flutter/widgets.dart';

const double _arrowWidth = 7;

class RollupController extends ChangeNotifier {
  RollupController({bool isExpanded = false}) : _isExpanded = isExpanded;

  bool _isExpanded;
  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) {
    if (value != _isExpanded) {
      _isExpanded = value;
      notifyListeners();
    }
  }

  void toggleExpanded() {
    isExpanded = !isExpanded;
  }
}

class Rollup extends StatefulWidget {
  const Rollup({
    Key? key,
    required this.heading,
    this.child,
    this.controller,
    this.isCollapsible = true,
  }) : super(key: key);

  final Widget heading;
  final Widget? child;
  final RollupController? controller;
  final bool isCollapsible;

  @override
  _RollupState createState() => _RollupState();
}

class _RollupState extends State<Rollup> {
  RollupController? _controller;

  RollupController get controller => _controller ?? widget.controller!;

  void _handleToggleExpanded() {
    controller.toggleExpanded();
  }

  void _handleIsExpandedChanged() {
    setState(() {
      // We pull our expanded state from the controller.
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = RollupController();
    }
    controller.addListener(_handleIsExpandedChanged);
  }

  @override
  void didUpdateWidget(covariant Rollup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final RollupController oldController = _controller ?? oldWidget.controller!;
      oldController.removeListener(_handleIsExpandedChanged);
      _controller?.dispose();
      _controller = null;
      if (widget.controller == null) {
        _controller = RollupController();
      }
      controller.addListener(_handleIsExpandedChanged);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleIsExpandedChanged);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _handleToggleExpanded,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: CustomPaint(
                  size: Size.square(_arrowWidth),
                  painter: _ArrowPainter(controller.isExpanded),
                ),
              ),
              SizedBox(width: 4),
              widget.heading,
            ],
          ),
        ),
        SizedBox(height: 4),
        if (widget.child != null && controller.isExpanded) Row(
          children: [
            SizedBox(width: _arrowWidth),
            SizedBox(width: 4),
            widget.child!,
          ],
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.expanded);

  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xffc4c3bc)
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;
    final Path path;
    if (expanded) {
      path = Path()..lineTo(3, 6)..lineTo(6, 0)..close();
    } else {
      path = Path()..lineTo(6, 3)..lineTo(0, 6)..close();
    }
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return expanded != oldDelegate.expanded;
  }
}
