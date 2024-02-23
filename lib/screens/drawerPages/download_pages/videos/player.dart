import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/providers/auth_provider.dart';
import '/screens/dashboard/main_page.dart';
import '/utils/default_logger.dart';
import 'package:pod_player/pod_player.dart';
import '/screens/drawerPages/download_pages/videos/drawer_videos_main_page.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/videos_model.dart';
import '/providers/GalleryProvider.dart';
import '/screens/drawerPages/download_pages/videos/controls_flick.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

import 'data_manager.dart';

class CustomOrientationPlayer extends StatefulWidget {
  CustomOrientationPlayer(
      {Key? key,
      required this.videos,
      required this.videoIndex,
      this.showCategoriesButton = false})
      : super(key: key);
  final List<CategoryVideo> videos;
  final int videoIndex;
  final bool showCategoriesButton;
  @override
  _CustomOrientationPlayerState createState() =>
      _CustomOrientationPlayerState();
}

class _CustomOrientationPlayerState extends State<CustomOrientationPlayer> {
  late FlickManager flickManager;
  late DataManager dataManager;
  PodPlayerController? podPlayerController;
  bool isActive = sl.get<AuthProvider>().userData.salesActive == '1';

  bool loading = true;
  load() async {
    if (isActive) {
      await Future(() async {
        //   var url = await getUrlString(
        //       widget.videos[widget.videoIndex].videoUrl ?? '', context);
        //   flickManager = FlickManager(
        //       videoPlayerController: VideoPlayerController.network(url),
        //       onVideoEnd: () {
        //         dataManager.skipToNextVideo(context, Duration(seconds: 5));
        //       });
        // })
        //     .then((value) => dataManager = DataManager(
        //         flickManager: flickManager,
        //         urls: widget.videos.map((e) => e.videoUrl ?? '').toList()))
        //     .then((value) => dataManager.videos = widget.videos)
        //     .then((value) => setState(() {
        //           loading = false;
      });
    } else {
      inActiveUserAccessDeniedDialog(
        context,
        onCancel: () => Get.back(),
        onOk: () => Get.back(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void dispose() {
    // flickManager.dispose();
    dataManager.videos = [];
    sl.get<GalleryProvider>().currentVideo = null;
    sl.get<GalleryProvider>().currentCategoryModel = null;
    super.dispose();
  }

  skipToVideo(String url) {
    flickManager.handleChangeVideo(VideoPlayerController.network(url));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        var playIndex = widget.videos.indexOf(provider.currentVideo!);
        return Scaffold(
            appBar: AppBar(title: Text(provider.currentVideo?.title ?? '')),
            body: SafeArea(
              child: Column(
                children: [
                  // !loading
                  // ? buildPlayerWidget()
                  // ?
                  PlayVideoFromVimeoPrivateId(
                    videoId: provider.currentVideo!.videoUrl!.split('/').last,
                    autoPlay: isActive,
                    onPlayerCreated: (controller) {
                      podPlayerController = controller;
                    },
                  ),
                  // : Container(
                  //     height: 200,
                  //     width: double.maxFinite,
                  //     child: Center(child: CircularProgressIndicator())),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height10(),
                          bodyLargeText(
                              provider.currentVideo?.title ?? "", context,
                              color: Colors.black),
                          height5(),
                          bodyMedText(
                              provider.currentCategoryModel?.header ?? "",
                              context,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          height10(),
                          buildList(provider, context, playIndex),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DrawerVideosMainPage()));
              },
              label: capText('All Videos', context, color: Colors.white),
            ));
      },
    );
  }

  Expanded buildList(
      GalleryProvider provider, BuildContext context, int playIndex) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 10),
        children: [
          ...widget.videos.map((video) {
            var i = widget.videos.indexOf(video);
            return GestureDetector(
              onTap: () {
                provider.setCurrentVideo(video);
                dataManager.playRandom(video, context);
                if (podPlayerController != null &&
                    podPlayerController!.isInitialised) {
                  final Map<String, String> headers = <String, String>{};
                  headers['Authorization'] =
                      'Bearer ${'eb7f7381bc30169014f5665326403cae'}';
                  warningLog('changing video.videoUrl ${video.videoUrl}');
                  podPlayerController!.changeVideo(
                      playVideoFrom: PlayVideoFrom.vimeo(
                          (video.videoUrl ?? '.').split('/').last));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    bottom: playIndex == i ? 20 : 10,
                    left: playIndex == i ? 5 : 0,
                    right: playIndex == i ? 7 : 0),
                decoration: BoxDecoration(
                    color: playIndex == i ? Colors.grey[200] : null,
                    boxShadow: [
                      if (playIndex == i)
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 5)
                    ],
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          // height: (Get.width - 20-10) / 2,
                          width: (Get.width) / 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white70,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: buildCachedNetworkImage(
                              video.videoBanner ?? '',
                              fit: BoxFit.cover,
                              placeholderImg: Assets.noVideoThumbnail,
                              pw: 80,
                              ph: 80,
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white30,
                                        blurRadius: 10,
                                        spreadRadius: 5,
                                      )
                                    ]),
                                child: Icon(Icons.play_arrow_rounded,
                                    color: appLogoColor),
                              ),
                            )),
                        // Positioned(
                        //     child: Container(
                        //   width: (Get.width - 20-10) / 2,
                        //   padding: EdgeInsets.all(3),
                        //   decoration: BoxDecoration(
                        //       color: Colors.white30,
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Colors.black12,
                        //           blurRadius: 1,
                        //           spreadRadius: 1,
                        //         )
                        //       ],
                        //       borderRadius: BorderRadius.only(
                        //           topLeft: Radius.circular(5),
                        //           topRight: Radius.circular(5))),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: capText(
                        //             'Introduction to Trading dfh tion to Trading ',
                        //             context),
                        //       ),
                        //     ],
                        //   ),
                        // )),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: capText(video.title ?? "", context,
                            color: Colors.black,
                            maxLines: 4,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  VisibilityDetector buildPlayerWidget() {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickManager.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager.flickControlManager?.autoResume();
        }
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 200,
            child: FlickVideoPlayer(
              flickManager: flickManager,
              preferredDeviceOrientationFullscreen: [
                DeviceOrientation.portraitUp,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ],
              flickVideoWithControls: FlickVideoWithControls(
                  controls: CustomOrientationControls(dataManager: dataManager),
                  videoFit: BoxFit.contain),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                videoFit: BoxFit.fitWidth,
                controls: CustomOrientationControls(dataManager: dataManager),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
