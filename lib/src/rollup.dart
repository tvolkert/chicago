import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'focus_indicator.dart';

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
    required this.childBuilder,
    this.controller,
    this.isCollapsible = true,
    this.semanticLabel,
  }) : super(key: key);

  final Widget heading;
  final WidgetBuilder childBuilder;
  final RollupController? controller;
  final bool isCollapsible;
  final String? semanticLabel;

  @override
  _RollupState createState() => _RollupState();
}

class _RollupState extends State<Rollup> {
  RollupController? _controller;
  FocusNode? _focusNode;

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
    _focusNode = FocusNode();
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
    _focusNode!.dispose();
    _focusNode = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawRollup(
      heading: widget.heading,
      childBuilder: widget.childBuilder,
      focusNode: _focusNode!,
      isExpanded: controller.isExpanded,
      isCollapsible: widget.isCollapsible,
      onToggleExpanded: _handleToggleExpanded,
      semanticLabel: widget.semanticLabel,
    );
  }
}

class RawRollup extends ImplicitlyAnimatedWidget {
  const RawRollup({
    Key? key,
    required this.heading,
    required this.childBuilder,
    required this.focusNode,
    required this.isExpanded,
    required this.isCollapsible,
    required this.onToggleExpanded,
    required this.semanticLabel,
  }) : super(key: key, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  final Widget heading;
  final WidgetBuilder childBuilder;
  final FocusNode focusNode;
  final bool isExpanded;
  final bool isCollapsible;
  final VoidCallback onToggleExpanded;
  final String? semanticLabel;

  @override
  _RawRollupState createState() => _RawRollupState();
}

class _RawRollupState extends AnimatedWidgetBaseState<RawRollup> {
  bool _isFocused = false;
  Tween<double>? _expansionTween;
  Tween<double>? _arrowRotationTween;

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
  }

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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onToggleExpanded,
          child: Actions(
            actions: <Type, Action<Intent>>{
              ActivateIntent: _ActivateRollupAction(this),
            },
            child: Semantics(
              label: widget.semanticLabel ?? 'Rollup widget',
              focusable: true,
              focused: _isFocused,
              child: Focus(
                focusNode: widget.focusNode,
                onFocusChange: _handleFocusChange,
                child: FocusIndicator(
                  isFocused: _isFocused,
                  insets: EdgeInsets.fromLTRB(-3, 0, -3, -1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
              ),
            ),
          ),
        ),
        if (reveal > 0)
          _RevealBox(
            reveal: reveal,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: _arrowWidth),
                  SizedBox(width: 4),
                  widget.childBuilder(context),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivateRollupAction extends ActivateAction {
  _ActivateRollupAction(this._state);

  final _RawRollupState _state;

  @override
  void invoke(Intent intent) {
    _state.widget.onToggleExpanded();
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
    _clipRectLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      clipBehavior: Clip.hardEdge,
      oldLayer: _clipRectLayer.layer,
    );
  }

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();
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
