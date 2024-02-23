import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '/database/functions.dart';
import '/constants/assets_constants.dart';
import '/utils/picture_utils.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart'
// hide ProgressBar;

import '../sl_container.dart';

/// Homepage
class YoutubePlayerPageNew extends StatefulWidget {
  const YoutubePlayerPageNew({Key? key}) : super(key: key);

  static const String routeName = '/ytLiveNew';

  @override
  _YoutubePlayerPageNewState createState() => _YoutubePlayerPageNewState();
}

class _YoutubePlayerPageNewState extends State<YoutubePlayerPageNew> {
  var provider = sl<PlayerProviderNew>();
  @override
  void initState() {
    super.initState();
    // provider.init();
  }

  @override
  void dispose() {
    // provider.controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var controller = YoutubePlayerController(
    //   initialVideoId: 'iLnmTe5Q2Qw',
    //   flags: YoutubePlayerFlags(
    //     autoPlay: true,
    //     mute: true,
    //   ),
    // );
    // warningLog('YoutubePlayerPageNew', 'build',
    //     'controller: $controller ${controller.initialVideoId}}');
    // return YoutubePlayer(controller: controller);
    return Consumer<PlayerProviderNew>(builder: (context, provider, _) {
      return OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: [
            YoutubePlayerScaffold(
                controller: YoutubePlayerController(
                    params: YoutubePlayerParams(
                  captionLanguage: 'en',
                  showControls: false,
                ))
                  ..loadVideoById(videoId: 'iLnmTe5Q2Qw'),
                builder: (context, player) {
                  return player;
                }),
            // _buildLandscape(context),
          ],
        );
      });
    });
  }

  Widget _buildPortrait(BuildContext context, Widget player) {
    return player;
  }

  Widget _buildLandscape(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: LayoutBuilder(builder: (context, bound) {
        print('bound: ${bound.maxWidth}x${bound.maxHeight}');
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.redAccent.withOpacity(0.2),
              ),
              // build stack none
              _buildStackNone(),
              // build stack controls
              _buildControls(),
            ],
          ),
        );
      }),
    );
  }

  _buildStackNone() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.black.withOpacity(0.0),
        child: Center(
            child: Text('Hello',
                style: TextStyle(color: Colors.white, fontSize: 32))),
      ),
    );
  }
}

class _buildControls extends StatelessWidget {
  const _buildControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProviderNew>(builder: (context, provider, _) {
      var controller = provider.controller;
      var state = controller.value.playerState;
      var isPlaying = state == PlayerState.playing;
      var isPaused = state == PlayerState.paused;
      var isBuffering = state == PlayerState.buffering;
      var duration = controller.metadata.duration;
      var position = provider.progressNotifier.value;
      // var error = controller.value.error;
      // var isFullScreen = controller.value.fullScreenOption.enabled;
      // var playBackSpeed = controller.value.playbackRate;
      // var volume = controller.volume;
      // var isMuted = controller.currentTime;

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: LayoutBuilder(builder: (context, bound) {
          return Container(
            color: Colors.black.withOpacity(0.5),
            child: Column(
              children: [
                Container(
                  color: Colors.red.withOpacity(0.5),
                  height: bound.maxHeight * 0.2,
                  child: Row(
                    children: [],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey.withOpacity(0.5),
                    child: Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                                // onDoubleTap: () => provider.seekPrevious(),
                                child: Container(
                                    color: Colors.blue.withOpacity(0.5),
                                    child: Center(
                                        child: Icon(Icons.replay_10,
                                            color: Colors.white, size: 32))))),
                        Expanded(
                            child: GestureDetector(
                                // onDoubleTap: () => provider.seekNext(),
                                child: Container(
                                    color: Colors.blue.withOpacity(0.5),
                                    child: Center(
                                        child: Icon(Icons.forward_10,
                                            color: Colors.white, size: 32))))),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.red.withOpacity(0.5),
                  height: bound.maxHeight * 0.1,
                  child: PlayPauseButtonBar(),
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}

///
class PlayPauseButtonBar extends StatelessWidget {
  PlayPauseButtonBar({super.key});
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProviderNew>(builder: (context, provider, _) {
      var playerState = provider.value.playerState;
      // var isFullScreen = provider.value.fullScreenOption.enabled;
      var isFullScreen = false;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              playerState == PlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            onPressed: () {
              // playerState == PlayerState.playing
              // ? provider.controller.pauseVideo()
              // : provider.controller.playVideo();
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isMuted,
            builder: (context, isMuted, _) {
              return IconButton(
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                onPressed: () {
                  _isMuted.value = !isMuted;
                  isMuted
                      ? provider.controller.unMute()
                      : provider.controller.mute();
                },
              );
            },
          ),
          //progress bar
          Expanded(
              child: Container(
            color: Colors.black.withOpacity(0.5),
          )),

          //quality

          //toogle full screen
          IconButton(
            icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: () {
              // isFullScreen
              //     ? provider.controller.exitFullScreen()
              //     : provider.controller.enterFullScreen();
            },
          ),
        ],
      );
    });
  }
}

class PlayerProviderNew extends ChangeNotifier {
  late YoutubePlayerController controller;
  ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  ValueNotifier<double> get progressNotifier => _progressNotifier;

  late YoutubePlayerValue value;

  Future<void> init() async {}

  // void seekNext() => controller.seekTo(seconds: 10);
  // void seekPrevious() => controller.seekTo(seconds: -10);
}
