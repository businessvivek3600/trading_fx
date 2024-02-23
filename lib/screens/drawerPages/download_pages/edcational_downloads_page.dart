import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/database/functions.dart';
import '/database/model/response/download_files_model.dart';
import '../../../sl_container.dart';
import '/providers/GalleryProvider.dart';
import '/utils/default_logger.dart';
import 'package:provider/provider.dart';

import '../../../constants/assets_constants.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/sizedbox_utils.dart';
import '../../../utils/text.dart';

class DowanloadsMainPage extends StatefulWidget {
  const DowanloadsMainPage({super.key});

  @override
  State<DowanloadsMainPage> createState() => _DowanloadsMainPageState();
}

class _DowanloadsMainPageState extends State<DowanloadsMainPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await sl.get<GalleryProvider>().getDownloadFiles(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: titleLargeText("Important Downloads", context,
                useGradient: true),
            elevation: provider.downloadFiles.length > 0 ? null : 0,
            actions: [
              provider.loadingDownloadFiles
                  ? Center(
                      child: Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.only(right: 10),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 1)))
                  : provider.filesLanguages.isNotEmpty
                      ? buildLanguageButton(provider, context)
                      : Container(),
            ],
          ),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: userAppBgImageProvider(context),
                  fit: BoxFit.cover,
                  opacity: 1),
            ),
            child: provider.loadingDownloadFiles
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : provider.downloadFiles.length > 0
                    ? buildFilesList(provider, context)
                    : Center(
                        child: Text("No Files Found",
                            style: TextStyle(color: Colors.white))),
          ),
        ),
      );
    });
  }

  Column buildLanguageButton(GalleryProvider provider, BuildContext context) {
    String currentLanguage;
    if (provider.filesLanguages.isNotEmpty) {
      try {
        currentLanguage =
            provider.filesLanguages[provider.currentFilesLanguage] ?? '';
      } catch (e) {
        currentLanguage = 'Select Language';
      }
    } else {
      currentLanguage = 'Select Language';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 30,
          child: PopupMenuButton<String>(
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  Icon(Icons.language, color: Colors.white, size: 15),
                  width5(),
                  capText(currentLanguage, context, color: Colors.white),
                ],
              ),
            ),
            onSelected: (String value) {
              provider.setFilesLanguage(value);
              provider.getDownloadFiles(true);
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            offset: Offset(0, 50),
            itemBuilder: (BuildContext context) {
              return provider.filesLanguages.entries
                  .map<PopupMenuItem<String>>((MapEntry<String, String> value) {
                return PopupMenuItem<String>(
                    value: value.key,
                    child: Text(value.value,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal)));
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  Widget buildFilesList(GalleryProvider provider, BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: [
        ...provider.downloadFiles.map(
          (e) => _DowloadTileWidget(file: e),
        ),
      ],
    );
  }
}

class _DowloadTileWidget extends StatefulWidget {
  const _DowloadTileWidget({super.key, required this.file});
  final DownloadFilesModel file;
  @override
  State<_DowloadTileWidget> createState() => _DowloadTileWidgetState();
}

class _DowloadTileWidgetState extends State<_DowloadTileWidget> {
  String get title => "flutter_app_downloader_test_file";
  String? fullPath;
  static const String tag = "_DowloadTileWidget";
  final imgUrl = "http://212.183.159.230/100MB.zip";
  var dio = Dio();
  ValueNotifier<bool> downloading = ValueNotifier(false);
  ValueNotifier<String> progress = ValueNotifier("");
  CancelToken cancelToken = CancelToken();
  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(url,
          cancelToken: cancelToken,
          onReceiveProgress: showDownloadProgress,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => (status ?? 0) < 500));
      infoLog(response.headers.toString(), tag);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      errorLog(e.toString(), tag);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      downloading.value = true;
      progress.value = (received / total * 100).toStringAsFixed(0) + "%";
      warningLog((received / total * 100).toStringAsFixed(0) + "%", tag);
      if ((received / total * 100) == 100 ||
          (received / total * 100) >= 100.0) {
        downloading.value = false;
        progress.value = "";
      }
    } else {
      downloading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        dense: true,
        onTap: () => launchTheLink(widget.file.link ?? ''),
        contentPadding: EdgeInsets.symmetric(vertical: 5),
        leading: SizedBox(
            width: 50,
            child: buildCachedNetworkImage(
              widget.file.image ?? '',
              placeholderImg: Assets.appLogo_S,
              ph: 50,
              pw: 50,
              borderRadius: 5,
              // fit: BoxFit.cover,
            )),
        title:
            bodyLargeText(widget.file.text ?? '', context, useGradient: false),
        // subtitle: Row(
        //   children: [
        //     Expanded(
        //       child: ValueListenableBuilder(
        //           valueListenable: progress,
        //           builder: (context, value, child) {
        //             return progress.value.isNotEmpty
        //                 ? capText(progress.value, context,
        //                     color: Colors.white70, fontSize: 12)
        //                 : fullPath != null
        //                     ? capText(fullPath!.split('/0/').last, context,
        //                         color: Colors.white70, fontSize: 8, maxLines: 3)
        //                     : Container();
        //           }),
        //     ),
        //   ],
        // ),

        trailing: Icon(Icons.file_download_rounded, color: Colors.white)

        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     ValueListenableBuilder(
        //         valueListenable: downloading,
        //         builder: (context, value, child) {
        //           return !downloading.value
        //               ? GestureDetector(
        //                   onTap: () async {
        //                     // var tempDir = await getTemporaryDirectory();
        //                     // fullPath = tempDir.path +
        //                     //     "/$title${imgUrl.split('.').last}'";
        //                     // print('full path ${fullPath}');
        //                     // if (fullPath != null) {
        //                     //   download2(dio, imgUrl, fullPath!);
        //                     // }
        //                   },
        //                   child: Icon(Icons.file_download, color: Colors.white),
        //                 )
        //               : Container();
        //         }),
        //     width10(),
        //     ValueListenableBuilder(
        //         valueListenable: downloading,
        //         builder: (context, value, child) {
        //           return downloading.value
        //               ? GestureDetector(
        //                   onTap: () {
        //                     cancelToken.cancel();
        //                     downloading.value = false;
        //                   },
        //                   child: Icon(CupertinoIcons.clear_circled_solid,
        //                       color: Colors.white))
        //               : Container();
        //         }),
        //   ],
        // ),

        );
  }
}
