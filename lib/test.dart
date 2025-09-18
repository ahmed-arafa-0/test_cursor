import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
import 'package:web/web.dart' as html;

import 'services/google_sheet_service.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  final String _viewType = 'web-video-player';
  late html.HTMLVideoElement _videoElement;
  bool _isVideoCreated = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    cc();
  }

  void cc() async {
    var x = await fetchSheetByGid('0');
    x.forEach((element) {
      print(element);
    });
  }

  void _initializeVideo() {
    // Register the platform view
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      _videoElement = html.HTMLVideoElement()
        // ..src =
        // 'assets/videos/default.mp4' // For asset video
        ..src =
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4' // For network video
        ..autoplay = true
        ..loop = true
        ..muted =
            true // Required for autoplay on most browsers
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // Handle video events
      _videoElement.onCanPlay.listen((event) {
        setState(() {
          _isVideoCreated = true;
        });
      });

      _videoElement.onError.listen((event) {
        print('Video error: ${_videoElement.error?.message}');
      });

      return _videoElement;
    });

    setState(() {
      _isVideoCreated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // HTML Video Element
          SizedBox.expand(child: HtmlElementView(viewType: _viewType)),

          // Dark overlay for better content visibility
          Container(color: Colors.black.withOpacity(0.2)),

          // Loading indicator
          if (!_isVideoCreated)
            Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
