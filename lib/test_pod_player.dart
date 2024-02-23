import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromNetwork extends StatefulWidget {
  const PlayVideoFromNetwork({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromNetwork> createState() => _PlayVideoFromNetworkState();
}

class _PlayVideoFromNetworkState extends State<PlayVideoFromNetwork> {
  late final PodPlayerController controller;

  @override
  void initState() {
    // controller = PodPlayerController(
    //   playVideoFrom: PlayVideoFrom.youtube(
    //     // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    //     'https://www.youtube.com/watch?v=sr-PjDVpuM8',
    //   ),
    // )..initialise();
    controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.youtube(
            'https://www.youtube.com/watch?v=nPt8bK2gbaU'),
        // playVideoFrom: PlayVideoFrom.vimeo('518228118'),
        podPlayerConfig: const PodPlayerConfig(
            autoPlay: true, isLooping: false, videoQualityPriority: [720, 360]))
      ..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PodVideoPlayer(controller: controller),
    );
  }
}
