// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '/utils/default_logger.dart';

import '../enums/player_state.dart';
import '../utils/youtube_meta_data.dart';
import '../utils/youtube_player_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// A raw youtube player widget which interacts with the underlying webview inorder to play YouTube videos.
///
/// Use [YoutubePlayer] instead.
class RawYoutubePlayer extends StatefulWidget {
  /// Sets [Key] as an identification to underlying web view associated to the player.
  final Key? key;

  /// {@macro youtube_player_flutter.onEnded}
  final void Function(YoutubeMetaData metaData)? onEnded;

  /// Creates a [RawYoutubePlayer] widget.
  RawYoutubePlayer({
    this.key,
    this.onEnded,
  });

  @override
  _RawYoutubePlayerState createState() => _RawYoutubePlayerState();
}

class _RawYoutubePlayerState extends State<RawYoutubePlayer>
    with WidgetsBindingObserver {
  late final PlatformWebViewControllerCreationParams params;
  YoutubePlayerController? controller;
  WebViewController? webViewController;
  PlayerState? _cachedPlayerState;
  bool _isPlayerReady = false;
  bool _onLoadStopCalled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      initController();
    } catch (e) {
      errorLog('Error initializing controller: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_cachedPlayerState != null &&
            _cachedPlayerState == PlayerState.playing) {
          controller?.play();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _cachedPlayerState = controller!.value.playerState;
        controller?.pause();
        break;
      default:
    }
  }

  initController() async {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{});
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController _webController =
        WebViewController.fromPlatformCreationParams(params);
    _webController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          _onLoadStopCalled = true;
          if (_isPlayerReady) {
            controller!.updateValue(
              controller!.value.copyWith(isReady: true),
            );
          }
        },
        onWebResourceError: (WebResourceError error) {
          controller!.updateValue(
            controller!.value.copyWith(errorCode: error.errorCode),
          );
          errorLog('An error occurred: ${error.description}');
        },
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
        onUrlChange: (UrlChange change) async {},
      ))
      ..addJavaScriptChannel('Toaster',
          onMessageReceived: (JavaScriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message.message,
                style: const TextStyle(color: Colors.red))));
      })
      ..loadHtmlString(player);

    // #docregion platform_features
    if (_webController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (_webController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    setState(() {
      webViewController = _webController;
      onWebViewCreated(webViewController!);
    });
  }

  onWebViewCreated(WebViewController webController) {
    (webController) {
      controller!.updateValue(
        controller!.value.copyWith(webViewController: webController),
      );
      webController
        ..addJavaScriptHandler(
          handlerName: 'Ready',
          callback: (_) {
            _isPlayerReady = true;
            if (_onLoadStopCalled) {
              controller!.updateValue(
                controller!.value.copyWith(isReady: true),
              );
            }
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'StateChange',
          callback: (args) {
            switch (args.first as int) {
              case -1:
                controller!.updateValue(
                  controller!.value.copyWith(
                    playerState: PlayerState.unStarted,
                    isLoaded: true,
                  ),
                );
                break;
              case 0:
                widget.onEnded?.call(controller!.metadata);
                controller!.updateValue(
                  controller!.value.copyWith(
                    playerState: PlayerState.ended,
                  ),
                );
                break;
              case 1:
                controller!.updateValue(
                  controller!.value.copyWith(
                    playerState: PlayerState.playing,
                    isPlaying: true,
                    hasPlayed: true,
                    errorCode: 0,
                  ),
                );
                break;
              case 2:
                controller!.updateValue(
                  controller!.value.copyWith(
                    playerState: PlayerState.paused,
                    isPlaying: false,
                  ),
                );
                break;
              case 3:
                controller!.updateValue(
                  controller!.value.copyWith(
                    playerState: PlayerState.buffering,
                  ),
                );
                break;
              case 5:
                controller!.updateValue(
                  controller!.value.copyWith(
                    playerState: PlayerState.cued,
                  ),
                );
                break;
              default:
                throw Exception("Invalid player state obtained.");
            }
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'PlaybackQualityChange',
          callback: (args) {
            controller!.updateValue(
              controller!.value.copyWith(playbackQuality: args.first as String),
            );
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'PlaybackRateChange',
          callback: (args) {
            final num rate = args.first;
            controller!.updateValue(
              controller!.value.copyWith(playbackRate: rate.toDouble()),
            );
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'Errors',
          callback: (args) {
            controller!.updateValue(
              controller!.value.copyWith(errorCode: int.parse(args.first)),
            );
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'VideoData',
          callback: (args) {
            controller!.updateValue(
              controller!.value
                  .copyWith(metaData: YoutubeMetaData.fromRawData(args.first)),
            );
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'VideoTime',
          callback: (args) {
            final position = args.first * 1000;
            final num buffered = args.last;
            controller!.updateValue(
              controller!.value.copyWith(
                position: Duration(milliseconds: position.floor()),
                buffered: buffered.toDouble(),
              ),
            );
          },
        );
    };
  }

  @override
  Widget build(BuildContext context) {
    controller = YoutubePlayerController.of(context);
    warningLog('RawYoutubePlayer page', 'build',
        'controller: $controller ${controller!.initialVideoId}}');
    return IgnorePointer(
        ignoring: true,
        child: webViewController != null
            ? WebViewWidget(controller: webViewController!)
            : Container(color: Colors.black)

        /*
      child: InAppWebView(
        key: widget.key,
        initialData: InAppWebViewInitialData(
          data: player,
          baseUrl: Uri.parse('https://www.youtube.com'),
          encoding: 'utf-8',
          mimeType: 'text/html',
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            userAgent: userAgent,
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: true,
            disableContextMenu: true,
            supportZoom: false,
            disableHorizontalScroll: false,
            disableVerticalScroll: false,
            useShouldOverrideUrlLoading: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
            allowsAirPlayForMediaPlayback: true,
            allowsPictureInPictureMediaPlayback: true,
          ),
          android: AndroidInAppWebViewOptions(
            useWideViewPort: false,
            useHybridComposition: controller!.flags.useHybridComposition,
          ),
        ),
        onWebViewCreated: (webController) {
          controller!.updateValue(
            controller!.value.copyWith(webViewController: webController),
          );
          webController
            ..addJavaScriptHandler(
              handlerName: 'Ready',
              callback: (_) {
                _isPlayerReady = true;
                if (_onLoadStopCalled) {
                  controller!.updateValue(
                    controller!.value.copyWith(isReady: true),
                  );
                }
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'StateChange',
              callback: (args) {
                switch (args.first as int) {
                  case -1:
                    controller!.updateValue(
                      controller!.value.copyWith(
                        playerState: PlayerState.unStarted,
                        isLoaded: true,
                      ),
                    );
                    break;
                  case 0:
                    widget.onEnded?.call(controller!.metadata);
                    controller!.updateValue(
                      controller!.value.copyWith(
                        playerState: PlayerState.ended,
                      ),
                    );
                    break;
                  case 1:
                    controller!.updateValue(
                      controller!.value.copyWith(
                        playerState: PlayerState.playing,
                        isPlaying: true,
                        hasPlayed: true,
                        errorCode: 0,
                      ),
                    );
                    break;
                  case 2:
                    controller!.updateValue(
                      controller!.value.copyWith(
                        playerState: PlayerState.paused,
                        isPlaying: false,
                      ),
                    );
                    break;
                  case 3:
                    controller!.updateValue(
                      controller!.value.copyWith(
                        playerState: PlayerState.buffering,
                      ),
                    );
                    break;
                  case 5:
                    controller!.updateValue(
                      controller!.value.copyWith(
                        playerState: PlayerState.cued,
                      ),
                    );
                    break;
                  default:
                    throw Exception("Invalid player state obtained.");
                }
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'PlaybackQualityChange',
              callback: (args) {
                controller!.updateValue(
                  controller!.value
                      .copyWith(playbackQuality: args.first as String),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'PlaybackRateChange',
              callback: (args) {
                final num rate = args.first;
                controller!.updateValue(
                  controller!.value.copyWith(playbackRate: rate.toDouble()),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'Errors',
              callback: (args) {
                controller!.updateValue(
                  controller!.value.copyWith(errorCode: int.parse(args.first)),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'VideoData',
              callback: (args) {
                controller!.updateValue(
                  controller!.value.copyWith(
                      metaData: YoutubeMetaData.fromRawData(args.first)),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'VideoTime',
              callback: (args) {
                final position = args.first * 1000;
                final num buffered = args.last;
                controller!.updateValue(
                  controller!.value.copyWith(
                    position: Duration(milliseconds: position.floor()),
                    buffered: buffered.toDouble(),
                  ),
                );
              },
            );
        },
        onLoadStop: (_, __) {
          _onLoadStopCalled = true;
          if (_isPlayerReady) {
            controller!.updateValue(
              controller!.value.copyWith(isReady: true),
            );
          }
        },
      ),
    
    */
        );
  }

  String get player => '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            html,
            body {
                margin: 0;
                padding: 0;
                background-color: #000000;
                overflow: hidden;
                position: fixed;
                height: 100%;
                width: 100%;
                pointer-events: none;
            }
        </style>
        <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
    </head>
    <body>
        <div id="player"></div>
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
            var player;
            var timerId;
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    height: '100%',
                    width: '100%',
                    videoId: '${controller?.initialVideoId}',
                    playerVars: {
                        'controls': 0,
                        'playsinline': 1,
                        'enablejsapi': 1,
                        'fs': 0,
                        'rel': 0,
                        'showinfo': 0,
                        'iv_load_policy': 3,
                        'modestbranding': 1,
                        'cc_load_policy': ${boolean(value: controller?.flags.enableCaption ?? false)},
                        'cc_lang_pref': '${controller?.flags.captionLanguage}',
                        'autoplay': ${boolean(value: controller?.flags.autoPlay ?? true)},
                        'start': ${controller?.flags.startAt},
                        'end': ${controller?.flags.endAt}
                    },
                    events: {
                        onReady: function(event) { window.flutter_inappwebview.callHandler('Ready'); },
                        onStateChange: function(event) { sendPlayerStateChange(event.data); },
                        onPlaybackQualityChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackQualityChange', event.data); },
                        onPlaybackRateChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackRateChange', event.data); },
                        onError: function(error) { window.flutter_inappwebview.callHandler('Errors', error.data); }
                    },
                });
            }

            function sendPlayerStateChange(playerState) {
                clearTimeout(timerId);
                window.flutter_inappwebview.callHandler('StateChange', playerState);
                if (playerState == 1) {
                    startSendCurrentTimeInterval();
                    sendVideoData(player);
                }
            }

            function sendVideoData(player) {
                var videoData = {
                    'duration': player.getDuration(),
                    'title': player.getVideoData().title,
                    'author': player.getVideoData().author,
                    'videoId': player.getVideoData().video_id
                };
                window.flutter_inappwebview.callHandler('VideoData', videoData);
            }

            function startSendCurrentTimeInterval() {
                timerId = setInterval(function () {
                    window.flutter_inappwebview.callHandler('VideoTime', player.getCurrentTime(), player.getVideoLoadedFraction());
                }, 100);
            }

            function play() {
                player.playVideo();
                return '';
            }

            function pause() {
                player.pauseVideo();
                return '';
            }

            function loadById(loadSettings) {
                player.loadVideoById(loadSettings);
                return '';
            }

            function cueById(cueSettings) {
                player.cueVideoById(cueSettings);
                return '';
            }

            function loadPlaylist(playlist, index, startAt) {
                player.loadPlaylist(playlist, 'playlist', index, startAt);
                return '';
            }

            function cuePlaylist(playlist, index, startAt) {
                player.cuePlaylist(playlist, 'playlist', index, startAt);
                return '';
            }

            function mute() {
                player.mute();
                return '';
            }

            function unMute() {
                player.unMute();
                return '';
            }

            function setVolume(volume) {
                player.setVolume(volume);
                return '';
            }

            function seekTo(position, seekAhead) {
                player.seekTo(position, seekAhead);
                return '';
            }

            function setSize(width, height) {
                player.setSize(width, height);
                return '';
            }

            function setPlaybackRate(rate) {
                player.setPlaybackRate(rate);
                return '';
            }

            function setTopMargin(margin) {
                document.getElementById("player").style.marginTop = margin;
                return '';
            }
        </script>
    </body>
    </html>
  ''';

  String boolean({required bool value}) => value == true ? "'1'" : "'0'";

  String get userAgent => controller!.flags.forceHD
      ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36'
      : '';
}
