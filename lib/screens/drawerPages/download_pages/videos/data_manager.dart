import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flick_video_player/flick_video_player.dart';
import '/database/model/response/base/api_response.dart';
import 'package:pod_player/pod_player.dart';
import '/database/functions.dart';
import '/providers/GalleryProvider.dart';
import '/sl_container.dart';
import '/utils/default_logger.dart';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../database/model/response/videos_model.dart';
import 'dart:developer' as dev;

class DataManager {
  DataManager({required this.flickManager, required this.urls});
  var galleryProvider = sl.get<GalleryProvider>();
  int currentPlaying = 0;
  final FlickManager flickManager;
  final List<String> urls;
  List<CategoryVideo> videos = [];
  late Timer videoChangeTimer;

  String getNextVideo() {
    currentPlaying++;
    return urls[currentPlaying];
  }

  bool hasNextVideo() {
    return currentPlaying != urls.length - 1;
  }

  bool hasPreviousVideo() {
    return currentPlaying != 0;
  }

  skipToNextVideo(BuildContext context, [Duration? duration]) async {
    if (hasNextVideo()) {
      // flickManager.handleChangeVideo(
      //     VideoPlayerController.network(
      //         await getUrlString(urls[currentPlaying + 1], context)),
      //     videoChangeDuration: duration);

      currentPlaying++;
      // galleryProvider.setCategoryModel(category);
      // var category = galleryProvider.categoryVideos.firstWhere((element) => element.videoList![currentPlaying].videoUrl==urls[currentPlaying]);
      galleryProvider.setCurrentVideo(videos[currentPlaying]);
    }
  }

  skipToPreviousVideo(BuildContext context) async {
    if (hasPreviousVideo()) {
      currentPlaying--;
      // flickManager.handleChangeVideo(VideoPlayerController.network(
      //     await getUrlString(urls[currentPlaying], context)));
      galleryProvider.setCurrentVideo(videos[currentPlaying]);
    }
  }

  playRandom(CategoryVideo video, BuildContext context) async {
    // flickManager.handleChangeVideo(VideoPlayerController.network(
    //     await getUrlString(video.videoUrl, context)));
    currentPlaying = videos.indexOf(video);
    galleryProvider.setCurrentVideo(video);
  }

  cancelVideoAutoPlayTimer({required bool playNext}) {
    if (playNext != true) {
      currentPlaying--;
    }

    // flickManager.flickVideoManager
    //     ?.cancelVideoAutoPlayTimer(playNext: playNext);
  }
}

// get video url from vimeo
Future<String> getUrlString(url, BuildContext context) async {
  var vimeoMp4Video = '';
  if (isOnline) {
    await _getVimeoVideoConfigFromUrl(context, url).then((value) async {
      final progressiveList = value?.request?.files?.progressive;
      if (progressiveList != null && progressiveList.isNotEmpty) {
        progressiveList.map((element) {
          if (element != null &&
              element.url != null &&
              element.url != '' &&
              vimeoMp4Video == '') {
            vimeoMp4Video = element.url ?? '';
          }
        }).toList();
        if (vimeoMp4Video.isEmpty || vimeoMp4Video == '') {
          showAlertDialog(context, title: 'Error', desc: 'Video not found');
        }
      }
    });
  } else {
    AwesomeDialog(
            dialogType: DialogType.warning,
            context: context,
            headerAnimationLoop: false,
            title: 'No internet connection',
            desc: 'Please check your internet connection and try again.',
            bodyHeaderDistance: 0,
            padding: EdgeInsets.zero,
            customHeader: Container(
                child: Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                    size: 80, color: Colors.red)),
            btnOkText: 'Okay',
            btnOkOnPress: () {})
        .show();
  }
  infoLog(vimeoMp4Video);
  return vimeoMp4Video;
}

showAlertDialog(BuildContext context, {String desc = '', String title = ''}) {
  AwesomeDialog(
          dialogType: DialogType.error,
          context: context,
          headerAnimationLoop: false,
          title: title,
          desc: desc,
          // desc: 'This video can\'t be played.\nSome thing went wrong!',
          bodyHeaderDistance: 0,
          padding: EdgeInsets.zero,
          customHeader:
              Container(child: Icon(Icons.error, size: 40, color: Colors.red)),
          // btnOkText: 'Subscribe Now',
          // btnCancelText: 'Cancel',
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) =>
            //             SubscriptionPage(initPurchaseDialog: true)));
          })
      .show();
  // AlertDialog alert = AlertDialog(
  //   title: const Text("Alert"),
  //   content: const Text("Some thing wrong with this url"),
  //   actions: [
  //     TextButton(
  //       child: const Text("OK"),
  //       onPressed: () {
  //         Navigator.of(context).pop();
  //       },
  //     ),
  //   ],
  // );
  //
  // // show the dialog
  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return alert;
  //   },
  // );
}

/// give vimeo video configuration from api
Future<VimeoVideoConfig?> _getVimeoVideoConfigFromUrl(
  BuildContext context,
  String url, {
  bool trimWhitespaces = true,
}) async {
  if (trimWhitespaces) url = url.trim();
  infoLog('video id is $url');
  var vimeoVideoId = '';
  var videoIdGroup = 4;
  // for (var exp in [
  //   RegExp(r"^((https?)://)?(www.)?vimeo\.com/(\d+).*$"),
  // ]) {
  //   RegExpMatch? match = exp.firstMatch(url);
  //   if (match != null && match.groupCount >= 1) {
  //     vimeoVideoId = match.group(videoIdGroup) ?? '';
  //   }
  // }
  vimeoVideoId = url.split('/').last;
  infoLog('video id is  $vimeoVideoId', '_getVimeoVideoConfigFromUrl');

  final response =
      await _getVimeoVideoConfig(context, vimeoVideoId: vimeoVideoId);
  return (response != null) ? response : null;
}

/// give vimeo video configuration from api
Future<VimeoVideoConfig?> _getVimeoVideoConfig(BuildContext context,
    {required String vimeoVideoId}) async {
  var headers = {
    'Authorization': 'Bearer ${'f106a6b507f0f3652a374a55ee7df97b'}',
    'Accept': 'application/vnd.vimeo.*+json;version=3.4'
  };
  try {
    // var url = 'https://player.vimeo.com/video/${vimeoVideoId}';
    var url = 'https://api.vimeo.com/videos/$vimeoVideoId?fields=play';
    ApiResponse apiResponse =
        await sl.get<GalleryProvider>().galleryRepo.getVimeoVideoCongig(
              url,
              options: Options(headers: headers),
            );
    log('_getVimeoVideoConfig responseData.data res: ${apiResponse.response?.data} error: ${apiResponse.error.toString()}  ${apiResponse.response?.statusCode}');
    if (apiResponse.error != null) {
      var title = 'Error';
      var desc = 'Some thing wrong with this video ';
      try {
        desc = apiResponse.error['error'];
      } catch (e) {
        errorLog('Error : ${e.toString()} ${apiResponse.error.runtimeType}',
            '_getVimeoVideoConfig');
      }
      showAlertDialog(context, title: title, desc: desc);
      return null;
    }
    VimeoVideoConfig? vimeoVideo;
    if (apiResponse.response?.data != null) {
      vimeoVideo = VimeoVideoConfig.fromJson(apiResponse.response?.data);
    }

    return vimeoVideo;
  } catch (e) {
    // showAlertDialog(context);
    errorLog('Error :  name: ${e.toString()} ', '_getVimeoVideoConfig');
    return null;
  }
}

class VimeoVideoPlayer extends StatefulWidget {
  final String url;
  final List<SystemUiOverlay> systemUiOverlay;
  final List<DeviceOrientation> deviceOrientation;
  final Duration? startAt;
  final void Function(Duration timePoint)? onProgress;
  final VoidCallback? onFinished;
  final bool autoPlay;
  const VimeoVideoPlayer({
    required this.url,
    this.systemUiOverlay = const [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ],
    this.deviceOrientation = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
    this.startAt,
    this.onProgress,
    this.onFinished,
    this.autoPlay = false,
    Key? key,
  }) : super(key: key);

  @override
  State<VimeoVideoPlayer> createState() => _VimeoVideoPlayerState();
}

class _VimeoVideoPlayerState extends State<VimeoVideoPlayer> {
  VideoPlayerController? _videoPlayerController;

  final VideoPlayerController _emptyVideoPlayerController =
      VideoPlayerController.network('');
  FlickManager? _flickManager;
  ValueNotifier<bool> isVimeoVideoLoaded = ValueNotifier(false);
  bool get _isVimeoVideo {
    var regExp = RegExp(
      r"^((https?)://)?(www.)?vimeo\.com/(\d+).*$",
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(widget.url);
    if (match != null && match.groupCount >= 1) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    if (_isVimeoVideo) {
      _videoPlayer();
    }
  }

  @override
  void deactivate() {
    _videoPlayerController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _flickManager?.dispose();
    _videoPlayerController?.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    ); // to re-show bars
    super.dispose();
  }

  void _setVideoInitialPosition(VideoPlayerController controller) {
    final Duration? startAt = widget.startAt;
    if (startAt != null) {
      if (controller.value.duration > startAt) {
        controller.seekTo(startAt);
      } // else ignore, incorrect value
    }
  }

  void _setVideoListeners(VideoPlayerController controller) {
    final onProgressCallback = widget.onProgress;
    final onFinishCallback = widget.onFinished;

    if (onProgressCallback != null || onFinishCallback != null) {
      _videoPlayerController?.addListener(() {
        final VideoPlayerValue videoData = _videoPlayerController?.value ??
            const VideoPlayerValue(duration: Duration.zero);
        if (videoData.isInitialized) {
          if (videoData.isPlaying) {
            if (onProgressCallback != null) {
              onProgressCallback.call(videoData.position);
            }
          } else if (videoData.duration == videoData.position) {
            if (onFinishCallback != null) {
              onFinishCallback.call();
            }
          }
        }
      });
    }
  }

  void _videoPlayer() {
    /// getting the vimeo video configuration from api and setting managers
    _getVimeoVideoConfigFromUrl(widget.url).then((value) async {
      final progressiveList = value?.request?.files?.progressive;

      var vimeoMp4Video = '';

      if (progressiveList != null && progressiveList.isNotEmpty) {
        progressiveList.map((element) {
          if (element != null &&
              element.url != null &&
              element.url != '' &&
              vimeoMp4Video == '') {
            vimeoMp4Video = element.url ?? '';
          }
        }).toList();
        if (vimeoMp4Video.isEmpty || vimeoMp4Video == '') {
          showAlertDialog(context);
        }
      }

      _videoPlayerController = VideoPlayerController.network(vimeoMp4Video);
      await _videoPlayerController?.initialize();
      _setVideoInitialPosition(
          _videoPlayerController ?? _emptyVideoPlayerController);
      _setVideoListeners(_videoPlayerController ?? _emptyVideoPlayerController);

      _flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(vimeoMp4Video),
        autoPlay: widget.autoPlay,
        // ignore: use_build_context_synchronously
      )..registerContext(context);

      isVimeoVideoLoaded.value = !isVimeoVideoLoaded.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isVimeoVideoLoaded,
      builder: (context, bool isVideo, child) => Container(
        child: isVideo
            ? FlickVideoPlayer(
                key: ObjectKey(_flickManager),
                flickManager: _flickManager ??
                    FlickManager(
                      videoPlayerController: _emptyVideoPlayerController,
                    ),
                systemUIOverlay: widget.systemUiOverlay,
                preferredDeviceOrientation: widget.deviceOrientation,
                flickVideoWithControls: const FlickVideoWithControls(
                  videoFit: BoxFit.fitWidth,
                  controls: FlickPortraitControls(),
                ),
                flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                  controls: FlickLandscapeControls(),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
                  backgroundColor: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<VimeoVideoConfig?> _getVimeoVideoConfigFromUrl(
    String url, {
    bool trimWhitespaces = true,
  }) async {
    if (trimWhitespaces) url = url.trim();
    var vimeoVideoId = '';
    var videoIdGroup = 4;
    for (var exp in [
      RegExp(r"^((https?)://)?(www.)?vimeo\.com/(\d+).*$"),
    ]) {
      RegExpMatch? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        vimeoVideoId = match.group(videoIdGroup) ?? '';
      }
    }

    final response = await _getVimeoVideoConfig(vimeoVideoId: vimeoVideoId);
    return (response != null) ? response : null;
  }

  /// give vimeo video configuration from api
  Future<VimeoVideoConfig?> _getVimeoVideoConfig({
    required String vimeoVideoId,
  }) async {
    try {
      Response responseData = await Dio().get(
        'https://player.vimeo.com/video/$vimeoVideoId/config',
      );
      var vimeoVideo = VimeoVideoConfig.fromJson(responseData.data);
      return vimeoVideo;
    } on DioException catch (e) {
      log('Dio Error : ', name: e.error.toString());
      return null;
    } on Exception catch (e) {
      log('Error : ', name: e.toString());
      return null;
    }
  }
}

// ignore: library_private_types_in_public_api
extension ShowAlertDialog on _VimeoVideoPlayerState {
  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: const Text("Alert"),
      content: const Text("Some thing wrong with this url"),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class VimeoVideoConfig {
  VimeoVideoConfig({this.request});

  factory VimeoVideoConfig.fromJson(Map<String, dynamic> json) =>
      VimeoVideoConfig(request: VimeoRequest.fromJson(json["request"]));

  VimeoRequest? request;
}

class VimeoRequest {
  VimeoRequest({this.files});

  factory VimeoRequest.fromJson(Map<String, dynamic> json) =>
      VimeoRequest(files: VimeoFiles.fromJson(json["files"]));

  VimeoFiles? files;
}

class VimeoFiles {
  VimeoFiles({this.progressive});

  factory VimeoFiles.fromJson(Map<String, dynamic> json) => VimeoFiles(
        progressive: List<VimeoProgressive>.from(
          json["progressive"].map(
            (x) => VimeoProgressive.fromJson(x),
          ),
        ),
      );

  List<VimeoProgressive?>? progressive;
}

class VimeoProgressive {
  VimeoProgressive({
    this.profile,
    this.width,
    this.mime,
    this.fps,
    this.url,
    this.cdn,
    this.quality,
    this.id,
    this.origin,
    this.height,
  });

  factory VimeoProgressive.fromJson(Map<String, dynamic> json) =>
      VimeoProgressive(
        profile: json["profile"],
        width: json["width"],
        mime: json["mime"],
        fps: json["fps"],
        url: json["url"],
        cdn: json["cdn"],
        quality: json["quality"],
        id: json["id"],
        origin: json["origin"],
        height: json["height"],
      );

  dynamic profile;
  dynamic width;
  dynamic mime;
  dynamic fps;
  dynamic url;
  dynamic cdn;
  dynamic quality;
  dynamic id;
  dynamic origin;
  dynamic height;
}

class ViemoVideoData {
  String? type;
  String? codec;
  int? width;
  int? height;
  String? linkExpirationTime;
  String? link;
  String? createdTime;
  double? fps;
  int? size;
  String? md5;
  String? rendition;

  ViemoVideoData(
      {this.type,
      this.codec,
      this.width,
      this.height,
      this.linkExpirationTime,
      this.link,
      this.createdTime,
      this.fps,
      this.size,
      this.md5,
      this.rendition});

  ViemoVideoData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    codec = json['codec'];
    width = json['width'];
    height = json['height'];
    linkExpirationTime = json['link_expiration_time'];
    link = json['link'];
    createdTime = json['created_time'];
    fps = json['fps'];
    size = json['size'];
    md5 = json['md5'];
    rendition = json['rendition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['codec'] = this.codec;
    data['width'] = this.width;
    data['height'] = this.height;
    data['link_expiration_time'] = this.linkExpirationTime;
    data['link'] = this.link;
    data['created_time'] = this.createdTime;
    data['fps'] = this.fps;
    data['size'] = this.size;
    data['md5'] = this.md5;
    data['rendition'] = this.rendition;
    return data;
  }
}

//
///live event
/*
class AuthApiService {
  /// id : video id
  /// accessKey : your vimeo account access key.
  Future<dynamic> loadByVideoId(
      {required String videoId, required String accessKey}) async {
    Uri uri = Uri.parse("https://api.vimeo.com/videos/$videoId");
    var res = await Dio().get(
      "https://api.vimeo.com/videos/$videoId",
      options: Options(headers: {"Authorization": "Bearer $accessKey"}),
    );

    if (res.statusCode != 200) {
      throw VimeoError(
          error: res.statusMessage,
          developerMessage: "Please check your video id",
          errorCode: res.statusCode);
    }
    return res.data;
    return jsonDecode(res.data);
  }

  Future<dynamic> loadByEventId(
      {required String eventId, required String accessKey}) async {
    infoLog('loadByEventId eventId ==> ${eventId}');
    // Uri uri1 = Uri.parse("https://api.vimeo.com/me/live_events/$eventId");

    // Uri uri2 = Uri.parse(
    //     "https://api.vimeo.com/me/live_events/$eventId/m3u8_playback");
    List<Response> res;
    Dio dio = Dio();
    dio
      ..options.baseUrl = 'https://api.vimeo.com'
      ..options.headers = {"Authorization": "Bearer $accessKey"};

    try {
      // var r = (await dio.get("/me/live_events/$eventId"));
      // warningLog(r.toString());
      res = await Future.wait([
        dio.get("/me/live_events/$eventId"),
        // dio.get("/me/live_events/$eventId/m3u8_playback"),
        // http.get(uri1, headers: {"Authorization": "Bearer $accessKey"}),
        // http.get(uri2, headers: {"Authorization": "Bearer $accessKey"})
      ]);
      errorLog(res.map((e) => e.statusMessage).toString());
      if (res[1].statusCode == 404) {
        throw VimeoError(
            error: res[1].statusMessage,
            developerMessage: 'Live event has ended!',
            errorCode: res[1].statusCode);
      } else if (res[1].statusCode != 200) {
        throw VimeoError(
            error: res[1].statusMessage,
            developerMessage: "Please check your video id",
            errorCode: res[1].statusCode);
      }
      return [res[0].data, res[1].data];
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }
}

Future<ApiResponse> apiResponses(eventId, accessKey) async {
  try {
    print('getting apiResponses');
    Response response = await AuthApiService()
        .loadByEventId(eventId: eventId!, accessKey: accessKey);
    return ApiResponse.withSuccess(response);
  } catch (e) {
    return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  }
}

/// Error on getting vimeo meta data from vimeo server.
class VimeoError extends Error {
  final String? error;
  final String? link;
  final String? developerMessage;
  final int? errorCode;

  VimeoError({this.error, this.link, this.developerMessage, this.errorCode});

  String toString() {
    if (error != null) {
      return "getting vimeo information failed: ${Error.safeToString(error)}";
    }
    return "getting vimeo information failed";
  }

  factory VimeoError.fromJsonAuth(Map<String, dynamic> json) {
    return VimeoError(
      error: json['error'],
      link: json['link'],
      developerMessage: json['developer_message'],
      errorCode: json['error_code'],
    );
  }

  factory VimeoError.fromJsonNoneAuth(Map<String, dynamic> json) {
    return VimeoError(
      error: json['message'],
      link: null,
      developerMessage: json['title'],
      errorCode: null,
    );
  }
}

class NoneAuthApiService {
  /// id : video id
  Future<dynamic> getVimeoData({required String id}) async {
    Uri uri = Uri.parse("https://player.vimeo.com/video/$id/config");
    var res = await Dio().get("https://player.vimeo.com/video/$id/config");
    if (res.statusCode != 200) {
      throw VimeoError(
          error: res.statusMessage,
          developerMessage:
              "Please check your video id\nand accessibility is public",
          errorCode: res.statusCode);
    }

    return res.data;
    return jsonDecode(res.data);
  }
}

class Vimeo {
  final String? videoId;
  final String? eventId;
  final String? accessKey;

  Vimeo({
    this.videoId,
    this.eventId,
    this.accessKey,
  })  : assert(videoId != null || eventId != null),
        assert(eventId != null && accessKey != null);

  // TODO:1
  factory Vimeo.fromUrl(Uri url, {String? accessKey}) {
    String? vId;
    String? eId;
    if (url.pathSegments.contains('event')) {
      eId = url.pathSegments.last;
    } else {
      vId = url.pathSegments.last;
    }
    //3581909
    infoLog('Vimeo.fromUrl video id ==> ${vId}  ${eId}');
    return Vimeo(
      videoId: vId,
      eventId: eId,
      accessKey: accessKey,
    );
  }
}

// TODO:2
extension ExtensionVimeo on Vimeo {
  /// get video meta data from vimeo server.
  Future<dynamic> get load async {
    infoLog('ExtensionVimeo load video id ==> ${videoId}');
    if (videoId != null) {
      if (accessKey?.isEmpty ?? true) {
        return _videoWithoutAuth;
      }

      return _videoWithAuth;
    }

    return _liveStreaming;
  }

  /// get private video meta data from vimeo server
  Future<dynamic> get _videoWithAuth async {
    try {
      var res = await AuthApiService()
          .loadByVideoId(accessKey: accessKey!, videoId: videoId!);
      return await VimeoVideo.fromJsonVideoWithAuth(
          videoId: videoId!,
          accessKey: accessKey!,
          json: (res as Map<String, dynamic>));
    } catch (e) {
      return e;
    }
  }

  /// get public video meta data from vimeo server
  Future<dynamic> get _videoWithoutAuth async {
    try {
      var res = await NoneAuthApiService().getVimeoData(id: videoId!);
      return await VimeoVideo.fromJsonVideoWithoutAuth(
          res as Map<String, dynamic>);
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> get _liveStreaming async {
    Map? map;
    try {
      //   var res = await AuthApiService()
      //       .loadByEventId(eventId: eventId!, accessKey: accessKey!);
      //   if (res is VimeoError) {
      //     errorLog('_liveStreaming  res is VimeoError  ${res.developerMessage}');
      //     return res;
      //   }
      //   return VimeoVideo.fromJsonLiveEvent(res);
      ApiResponse apiResponse = await apiResponses(eventId, accessKey);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        return VimeoVideo.fromJsonLiveEvent(map!);
      } else {
        String errorMessage = "";
        print(apiResponse.error);
        if (apiResponse.error is String) {
          print(apiResponse.error.toString());
          errorMessage = apiResponse.error.toString();
        } else {
          ErrorResponse errorResponse = apiResponse.error;
          print(
              'error message from countries ${errorResponse.errors[0].message}');
          errorMessage = errorResponse.errors[0].message;
        }
        return errorMessage;
      }
    } catch (e) {
      errorLog('_liveStreaming  res is not VimeoError  ');
      return e;
    }
  }
}

class VimeoVideo {
  final bool liveEvent;
  int? width;
  int? height;
  final List<_VimeoQualityFile?> sources;

  VimeoVideo({
    this.liveEvent = false,
    this.width,
    this.height,
    required this.sources,
  });

  static Future<VimeoVideo> fromJsonVideoWithAuth({
    required String videoId,
    required String accessKey,
    required Map<String, dynamic> json,
  }) async {
    if (json.keys.contains("error")) {
      throw VimeoError.fromJsonAuth(json);
    }

    if (json['embed']?['badges']['live']['streaming'] ?? false) {
      Uri uri =
          Uri.parse("https://api.vimeo.com/me/videos/$videoId/m3u8_playback");
      var response = await Dio().get(
          "https://api.vimeo.com/me/videos/$videoId/m3u8_playback",
          options: Options(headers: {"Authorization": "Bearer $accessKey"}));
      // var body = jsonDecode(response.data);
      var body = response.data;

      return VimeoVideo(
          width: json['width'],
          height: json['height'],
          liveEvent: true,
          sources: [
            _VimeoQualityFile(
              quality: _VimeoQualityFile.hls,
              file: VimeoSource(
                height: json['height'],
                width: json['width'],
                url: Uri.parse(body['m3u8_playback_url']),
              ),
            )
          ]);
    }

    var jsonFiles = (json['files']) as List<dynamic>;
    List<_VimeoQualityFile?> files = List<_VimeoQualityFile?>.from(
        jsonFiles.map<_VimeoQualityFile?>((element) {
      if (element['quality'] != null &&
          element['quality'] != _VimeoQualityFile.hls) {
        return _VimeoQualityFile(
          quality: element['quality'],
          file: VimeoSource(
            height: element['height'],
            width: element['width'],
            fps: element['fps'] is double
                ? element['fps']
                : (element['fps'] as int).toDouble(),
            url: Uri.tryParse(element['link'] as String)!,
          ),
        );
      }
    })).toList();
    return VimeoVideo(
      liveEvent: json['embed']['badges']['live']['streaming'],
      width: json['width'],
      height: json['height'],
      sources: files,
    );
  }

  static Future<VimeoVideo> fromJsonVideoWithoutAuth(
      Map<String, dynamic> json) async {
    if (json.keys.contains("message")) {
      throw VimeoError.fromJsonNoneAuth(json);
    }
    late var files;
    bool isLive = json['video']['live_event'] != null;
    if (isLive) {
      var hls = json['request']['files']['hls'];
      var response = (await Dio()
              .get(Uri.parse(hls['cdns']['fastly_live']['json_url']).path))
          .data;
      Uri url = Uri.parse(response['url'] as String);
      files = [
        _VimeoQualityFile(
            quality: 'hls',
            file: VimeoSource(
                height: json['video']['height'],
                width: json['video']['width'],
                fps: json['video']['fps'],
                url: url))
      ];
    } else {
      files = List<_VimeoQualityFile?>.from(json['request']['files']
              ['progressive']
          .map<_VimeoQualityFile?>((element) {
        return _VimeoQualityFile(
          quality: element['quality'],
          file: VimeoSource(
            width: element['width'],
            height: element['height'],
            fps: element['fps'] is double
                ? element['fps']
                : (element['fps'] as int).toDouble(),
            url: Uri.parse(element['url']),
          ),
        );
      })).toList();
    }
    return VimeoVideo(
        liveEvent: isLive,
        width: json['video']['width'],
        height: json['video']['height'],
        sources: files);
  }

  factory VimeoVideo.fromJsonLiveEvent(json) {
    var ret = VimeoVideo(
        liveEvent: true,
        height: json[0]['streamable_clip']['height'],
        width: json[0]['streamable_clip']['width'],
        sources: [
          _VimeoQualityFile(
              quality: _VimeoQualityFile.hls,
              file: VimeoSource(
                height: json[0]['streamable_clip']['height'],
                width: json[0]['streamable_clip']['width'],
                url: Uri.parse(json[1]['m3u8_playback_url']),
              ))
        ]);
    return ret;
  }
}

extension ExtensionVimeoVideo on VimeoVideo {
  Uri? get videoUrl {
    return defaultVideo?.url;
  }

  int get size {
    return width! > height! ? width! : height!;
  }

  double get ratio => width! / height!;

  Map<String, String> get resolutions {
    Map<String, String> ret = {};

    for (var q in sources) {
      if (q == null) {
        continue;
      }
      ret.addAll({q.quality: q.file.url.toString()});
    }

    return ret;
  }

  bool get isLive => liveEvent;

  VimeoSource? get defaultVideo {
    VimeoSource? ret = sources.first?.file;
    for (var file in sources) {
      if (file?.file.size == size) {
        ret = file?.file;
        break;
      }
    }
    return ret;
  }
}

class VimeoSource {
  final int? height;
  final int? width;
  final double? fps;
  final Uri url;

  VimeoSource({
    this.height,
    this.width,
    this.fps,
    required this.url,
  });

  factory VimeoSource.fromJson({required bool isLive, required dynamic json}) {
    return VimeoSource(
      height: json['height'],
      width: json['width'],
      fps: json['fps'],
      url: Uri.parse(json['url']),
    );
  }

  int? get size => (height == null || width == null)
      ? null
      : height! > width!
          ? height
          : width;
}

class _VimeoQualityFile {
  static const String qualityLive = "live";
  static const String hd = "hd";
  static const String sd = "sd";
  static const String hls = "hls";
  static const String quality4k = "4k";
  static const String quality8k = "8k";
  static const String quality1440p = "1440p";
  static const String quality1080p = "1080p";
  static const String quality720p = "720p";
  static const String quality540p = "540p";
  static const String quality360p = "360p";
  static const String quality240p = "240p";

  final String quality;
  final VimeoSource file;

  _VimeoQualityFile({
    required this.quality,
    required this.file,
  });
}
*/

//player
class VimeoEventPlayer extends StatefulWidget {
  // final VimeoVideo vimeoVideo;
  final VideoPlayerController videoController;

  VimeoEventPlayer({Key? key, required this.videoController}) : super(key: key);

  @override
  _VimeoEventPlayerState createState() => _VimeoEventPlayerState();
}

class _VimeoEventPlayerState extends State<VimeoEventPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // widget.videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    dev.log("screen orientation = ${MediaQuery.of(context).orientation}",
        name: "VimeoPlayer");
    dev.log("screen width = ${MediaQuery.of(context).size.width}",
        name: "VimeoPlayer");
    dev.log("screen height = ${MediaQuery.of(context).size.height}",
        name: "VimeoPlayer");
    Widget child = AspectRatio(
      // aspectRatio: widget.vimeoVideo.ratio,
      aspectRatio: 1,
      child: VideoPlayer(widget.videoController),
    );

    if (orientation == Orientation.portrait) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.top,
          SystemUiOverlay.bottom,
        ],
      );
      return Container(
        width: MediaQuery.of(context).size.width,
        child: child,
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
      return Container(
        height: MediaQuery.of(context).size.height,
        child: child,
      );
    }
  }
}
////
/*

class VimeoEventExample extends StatefulWidget {
  @override
  _VimeoEventExampleState createState() => _VimeoEventExampleState();
}

class _VimeoEventExampleState extends State<VimeoEventExample> {
  VimeoVideo? vimeoVideo;
  late VideoPlayerController? controller;
  final String clientId = '307b8eb86353772a789d9d156bdda9dfaa2cf3a6';
  final String clientSecret = '4fc5f48f9f8682f3a0d1d5ba22ca4d89';
  final String authorizationCode =
      'zHUHTTSLcSgTjnRvE9W+vmGD03h4uHCaUTWJhPs1CfGmbp2xcEGc0/rAQAGyY5Im2iGcMtsCAl7fd3Nf5x3M2O71tegh/SnVRGqCaPmDbliy1x41ibbHhVtdOayexeNu';

  Future<String?> requestAccessToken() async {
    final url = Uri.parse('https://api.vimeo.com/oauth/access_token');
    print('encodedAuth $encodedAuth');
    try {
      final response = await Dio().post(
          // 'https://api.vimeo.com/oauth/access_token',
          'https://api.vimeo.com/oauth/authorize/client',
          options: Options(
            headers: {
              'Authorization': 'Basic $encodedAuth',
              "Content-Type": "application/json",
              // "Accept": "Accept: application/vnd.vimeo.user+json;version=3.0,application/vnd.vimeo.video+json;version=3.4"
            },
            // extra: {
            //   'grant_type': 'authorization_code',
            //   'code': authorizationCode
            // },
          ),
          data: {"grant_type": "client_credentials", "scope": "public"});
      infoLog('requestAccessToken res ${response}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return data['access_token'];
      } else {
        throw Exception('Failed to get access token');
      }
    } catch (e) {
      infoLog('requestAccessToken errr ${e}');
    }
  }

  String get encodedAuth {
    final bytes = utf8.encode('$clientId:$authorizationCode');
    return base64.encode(bytes);
  }

  Future<dynamic> initVimeo() async {
    var access_token = await requestAccessToken();
    var res = await Vimeo.fromUrl(Uri.parse('https://vimeo.com/event/3582202'),
            accessKey: access_token)
        .load;
    if (res is String) {
      errorLog('${res}', ' initVimeo res ');
      if (res.toString().toLowerCase().contains('not found')) {
        //show not found
        return VimeoError(
          error: 'Event has been ended',
          errorCode: 404,
          developerMessage: 'Go to videos to continue watching',
        );
      }
      if (res.toString().toLowerCase().contains('401')) {
        //show not authorized
      }
    }

    bool autoPlay = false;
    if (res is VimeoVideo) {
      vimeoVideo = res;
      controller =
          VideoPlayerController.network(vimeoVideo!.videoUrl.toString());
      controller?.initialize().then((value) => controller?.play());
    }

    return vimeoVideo;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(alignment: Alignment.topCenter, children: [
        FutureBuilder<dynamic>(
          future: initVimeo(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700)),
                  child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                          child: Center(child: CircularProgressIndicator()))));
            }

            if (snapshot.data is VimeoError) {
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade700)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        "${(snapshot.data as VimeoError).developerMessage}" +
                            "\n\n${(snapshot.data as VimeoError).errorCode ?? ""}" +
                            "\n\n${(snapshot.data as VimeoError).error}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }

            return VimeoEventPlayer(
              vimeoVideo: vimeoVideo!,
              videoController: controller!,
            );
          },
        ),
      ]),
    ));
  }
}
*/

class PlayVideoFromVimeoPrivateId extends StatefulWidget {
  const PlayVideoFromVimeoPrivateId(
      {Key? key,
      required this.videoId,
      required this.onPlayerCreated,
      this.autoPlay})
      : super(key: key);
  final String videoId;
  final Function(PodPlayerController? controller) onPlayerCreated;
  final bool? autoPlay;

  @override
  State<PlayVideoFromVimeoPrivateId> createState() =>
      _PlayVideoFromVimeoPrivateIdState();
}

class _PlayVideoFromVimeoPrivateIdState
    extends State<PlayVideoFromVimeoPrivateId> {
  late final PodPlayerController controller;
  var headers = {
    'Authorization': 'Bearer ${'f106a6b507f0f3652a374a55ee7df97b'}',
    'Accept': 'application/vnd.vimeo.*+json;version=3.4'
  };
  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.vimeoPrivateVideos(
        widget.videoId,
        videoPlayerOptions: VideoPlayerOptions(),
        httpHeaders: headers,
      ),
      podPlayerConfig: PodPlayerConfig(
        autoPlay: widget.autoPlay ?? true,
      ),
    )..initialise().then((value) => widget.onPlayerCreated(controller));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PodVideoPlayer(
      controller: controller,
      podPlayerLabels: PodPlayerLabels(),
    );
  }

  Row _loadVideoFromUrl() {
    return Row(
      children: [
        FocusScope(
          canRequestFocus: false,
          child: ElevatedButton(
            onPressed: () async {
              try {
                snackBar('Loading....');
                FocusScope.of(context).unfocus();

                final Map<String, String> headers = <String, String>{};
                headers['Authorization'] = 'Bearer ${''}';

                await controller.changeVideo(
                  playVideoFrom: PlayVideoFrom.vimeoPrivateVideos(
                    'videoTextFieldCtr.text',
                    httpHeaders: headers,
                  ),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              } catch (e) {
                snackBar('Unable to load,\n $e');
              }
            },
            child: const Text('Load Video'),
          ),
        ),
      ],
    );
  }

  void snackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }
}
