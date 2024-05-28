import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MoviePlayer extends StatefulWidget {
  final String videoUrl;
  final String videoText;

  const MoviePlayer({Key? key, required this.videoUrl, required this.videoText})
      : super(key: key);

  @override
  _MoviePlayerState createState() => _MoviePlayerState();
}

class _MoviePlayerState extends State<MoviePlayer> {
  late MethodChannel _channel;
  late BmsVideoPlayerController _controller;
  bool isNormalScreen = true;

  @override
  void initState() {
    super.initState();
    _channel = const MethodChannel('bms_video_player');
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'fullScreen':
        setFullScreen();
        break;
      case 'normalScreen':
        setNormalScreen();
        break;
      case 'onBackButtonClicked':
        handleBackButton();
        break;
      default:
        return Future.value();
    }
  }

  void setFullScreen() {
    isNormalScreen = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() {});
  }

  void setNormalScreen() {
    isNormalScreen = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    setState(() {});
  }

  void handleBackButton() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    setState(() {});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BmsVideoPlayer(
        onCreated: onViewPlayerCreated,
        x: 0.0,
        y: 0.0,
        width: width,
        height: height,
        videoUrl: widget.videoUrl,
        videoText: widget.videoText,
      ),
    );
  }

  void onViewPlayerCreated(BmsVideoPlayerController controller) {
    _controller = controller;
    _controller.autoplay();
  }
}

typedef void BmsVideoPlayerCreatedCallback(BmsVideoPlayerController controller);

class BmsVideoPlayerController {
  late MethodChannel _channel;

  BmsVideoPlayerController.init(int id)
      : _channel = MethodChannel('bms_video_player');

  Future<void> loadUrl(String url) async {
    assert(url != null);
    return _channel.invokeMethod('loadUrl', url);
  }

  Future<void> autoplay() async {
    return _channel.invokeMethod('autoplay');
  }

  Future<void> pauseVideo() async {
    return _channel.invokeMethod('pauseVideo');
  }

  Future<void> resumeVideo() async {
    return _channel.invokeMethod('resumeVideo');
  }
}

class BmsVideoPlayer extends StatefulWidget {
  final BmsVideoPlayerCreatedCallback onCreated;
  final double x;
  final double y;
  final double width;
  final double height;
  final String videoUrl;
  final String videoText;

  const BmsVideoPlayer(
      {Key? key,
      required this.onCreated,
      required this.x,
      required this.y,
      required this.width,
      required this.height,
      required this.videoUrl,
      required this.videoText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<BmsVideoPlayer> {
  String viewType = 'MyPlayerView';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: nativeView(),
    );
  }

  Widget nativeView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
          "videoURL": widget.videoUrl,
          "videoText": widget.videoText
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
          "videoURL": widget.videoUrl,
          "videoText": widget.videoText
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    widget.onCreated(BmsVideoPlayerController.init(id));
  }
}
