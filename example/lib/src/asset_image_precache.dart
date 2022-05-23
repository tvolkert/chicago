import 'package:flutter/widgets.dart';

class AssetImagePrecache extends StatefulWidget {
  const AssetImagePrecache({
    Key? key,
    required this.paths,
    required this.child,
    this.loadingIndicator,
  }) : super(key: key);

  final List<String> paths;
  final Widget child;
  final Widget? loadingIndicator;

  @override
  _AssetImagePrecacheState createState() => _AssetImagePrecacheState();
}

class _AssetImagePrecacheState extends State<AssetImagePrecache> {
  Iterable<Future<void>>? _futures;
  bool _isComplete = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_futures == null && !_isComplete) {
      // precacheImage() guarantees that the futures will not throw
      _futures = widget.paths
          .map<AssetImage>((String path) => AssetImage(path))
          .map<Future<void>>(
              (AssetImage image) => precacheImage(image, context));
      Future.wait<void>(_futures!).then((void _) {
        setState(() {
          _futures = null;
          _isComplete = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isComplete ? widget.child : widget.loadingIndicator ?? widget.child;
  }
}
