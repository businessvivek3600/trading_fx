import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    Key? key,
    required this.path,
    this.fromNetwork = false,
    this.autoPlay = true,
  }) : super(key: key);
  final String path;
  final bool fromNetwork;
  final bool autoPlay;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = (widget.fromNetwork
        ? VideoPlayerController.network(widget.path)
        : VideoPlayerController.asset('assets/videos/${widget.path}'))
      ..initialize().then((value) => videoPlayerController.addListener(() {
            setState(() {});
            if (videoPlayerController.value.isInitialized) {
              videoPlayerController.play();
            }
          }));
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(videoPlayerController);
  }
}
