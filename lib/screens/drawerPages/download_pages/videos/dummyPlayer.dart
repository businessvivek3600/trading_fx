import 'package:flutter/material.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

class DummyPlayer extends StatefulWidget {
  const DummyPlayer({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  State<DummyPlayer> createState() => _DummyPlayerState();
}

class _DummyPlayerState extends State<DummyPlayer> {
  @override
  Widget build(BuildContext context) {
    return VimeoVideoPlayer(url: 'https://player.vimeo.com/video/733479436');
    ;
  }
}
