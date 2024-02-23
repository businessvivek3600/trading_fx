import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_manager.dart';

class CustomOrientationControls extends StatelessWidget {
  const CustomOrientationControls(
      {Key? key, this.iconSize = 20, this.fontSize = 12, this.dataManager})
      : super(key: key);
  final double iconSize;
  final double fontSize;
  final DataManager? dataManager;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: flickVideoManager.nextVideoAutoPlayTimer != null
                    ? FlickVideoProgressBar(
                        flickProgressBarSettings: FlickProgressBarSettings(
                          height: 10,
                          handleRadius: 10,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.white24,
                          bufferedColor: Colors.white38,
                          getPlayedPaint: (
                              {double? handleRadius,
                              double? height,
                              double? playedPart,
                              double? width}) {
                            return Paint()
                              ..shader = LinearGradient(colors: [
                                Color.fromRGBO(108, 165, 242, 1),
                                Color.fromRGBO(97, 104, 236, 1)
                              ], stops: [
                                0.0,
                                0.5
                              ]).createShader(
                                Rect.fromPoints(
                                  Offset(0, 0),
                                  Offset(width!, 0),
                                ),
                              );
                          },
                          getHandlePaint: (
                              {double? handleRadius,
                              double? height,
                              double? playedPart,
                              double? width}) {
                            return Paint()
                              ..shader = RadialGradient(
                                colors: [
                                  Color.fromRGBO(97, 104, 236, 1),
                                  Color.fromRGBO(97, 104, 236, 1),
                                  Colors.white,
                                ],
                                stops: [0.0, 0.4, 0.5],
                                radius: 0.4,
                              ).createShader(
                                Rect.fromCircle(
                                  center: Offset(playedPart!, height! / 2),
                                  radius: handleRadius!,
                                ),
                              );
                          },
                        ),
                      )
                    : FlickAutoHideChild(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  dataManager!.skipToPreviousVideo(context);
                                },
                                child: Icon(
                                  Icons.skip_previous,
                                  color: dataManager!.hasPreviousVideo()
                                      ? Colors.white
                                      : Colors.white38,
                                  size: 35,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlickPlayToggle(size: 50),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  dataManager!.skipToNextVideo(context);
                                },
                                child: Icon(
                                  Icons.skip_next,
                                  color: dataManager!.hasNextVideo()
                                      ? Colors.white
                                      : Colors.white38,
                                  size: 35,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize),
                          ),
                          FlickTotalDuration(
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickFullScreenToggle(
                        size: iconSize,
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 10,
                      handleRadius: 10,
                      padding:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      getPlayedPaint: (
                          {double? handleRadius,
                          double? height,
                          double? playedPart,
                          double? width}) {
                        return Paint()
                          ..shader = LinearGradient(colors: [
                            Color.fromRGBO(108, 165, 242, 1),
                            Color.fromRGBO(97, 104, 236, 1)
                          ], stops: [
                            0.0,
                            0.5
                          ]).createShader(
                            Rect.fromPoints(
                              Offset(0, 0),
                              Offset(width!, 0),
                            ),
                          );
                      },
                      getHandlePaint: (
                          {double? handleRadius,
                          double? height,
                          double? playedPart,
                          double? width}) {
                        return Paint()
                          ..shader = RadialGradient(
                            colors: [
                              Color.fromRGBO(97, 104, 236, 1),
                              Color.fromRGBO(97, 104, 236, 1),
                              Colors.white,
                            ],
                            stops: [0.0, 0.4, 0.5],
                            radius: 0.4,
                          ).createShader(
                            Rect.fromCircle(
                              center: Offset(playedPart!, height! / 2),
                              radius: handleRadius!,
                            ),
                          );
                      },
                    ),
                  ),
                  // FlickVideoProgressBar(
                  //   flickProgressBarSettings: FlickProgressBarSettings(
                  //     height: 5,
                  //     handleRadius: 5,
                  //     curveRadius: 50,
                  //     backgroundColor: Colors.white24,
                  //     bufferedColor: Colors.white38,
                  //     playedColor: Colors.red,
                  //     handleColor: Colors.red,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
