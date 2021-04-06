import 'dart:math' as math;

import 'package:flutter/rendering.dart';
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
    return RawRollup(
      heading: widget.heading,
      child: widget.child,
      isExpanded: controller.isExpanded,
      isCollapsible: widget.isCollapsible,
      onToggleExpanded: _handleToggleExpanded,
    );
  }
}

class RawRollup extends ImplicitlyAnimatedWidget {
  const RawRollup({
    Key? key,
    required this.heading,
    required this.child,
    required this.isExpanded,
    required this.isCollapsible,
    required this.onToggleExpanded,
  }) : super(key: key, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  final Widget heading;
  final Widget? child;
  final bool isExpanded;
  final bool isCollapsible;
  final VoidCallback onToggleExpanded;

  @override
  _RawRollupState createState() => _RawRollupState();
}

class _RawRollupState extends AnimatedWidgetBaseState<RawRollup> {
  Tween<double>? _expansionTween;
  Tween<double>? _arrowRotationTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _expansionTween = visitor(_expansionTween, widget.isExpanded ? 1.0 : 0.0,
        (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>?;
    _arrowRotationTween = visitor(_arrowRotationTween, widget.isExpanded ? math.pi / 2 : 0.0,
        (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final double reveal = _expansionTween?.evaluate(animation) ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onToggleExpanded,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Transform.rotate(
                  angle: _arrowRotationTween?.evaluate(animation) ?? 0.0,
                  child: CustomPaint(
                    size: Size.square(_arrowWidth),
                    painter: _ArrowPainter(),
                  ),
                ),
              ),
              SizedBox(width: 4),
              widget.heading,
            ],
          ),
        ),
        if (widget.child != null && reveal > 0)
          _RevealBox(
            reveal: reveal,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  SizedBox(width: _arrowWidth),
                  SizedBox(width: 4),
                  widget.child!,
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RevealBox extends SingleChildRenderObjectWidget {
  const _RevealBox({
    Key? key,
    required this.reveal,
    required Widget? child,
  }) : super(key: key, child: child);

  final double reveal;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRevealBox(reveal: reveal);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderRevealBox renderObject) {
    renderObject..reveal = reveal;
  }
}

class _RenderRevealBox extends RenderProxyBox {
  _RenderRevealBox({required double reveal}) : _reveal = reveal;

  double? _reveal;
  double get reveal => _reveal!;
  set reveal(double value) {
    if (value != _reveal) {
      _reveal = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    super.performLayout();
    final Size childSize = child!.size;
    size = Size(childSize.width, childSize.height * reveal);
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    _clipRectLayer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      clipBehavior: Clip.hardEdge,
      oldLayer: _clipRectLayer,
    );
  }

  ClipRectLayer? _clipRectLayer;
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xffc4c3bc)
      ..style = PaintingStyle.fill;
    final Path path = Path()
      ..lineTo(7, 3.5)
      ..lineTo(0, 7)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) => false;
}
