import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/additional/fcm_notification_model.dart';
import '/providers/notification_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

import '../../database/functions.dart';
import '../../utils/default_logger.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage(
      {Key? key, this.payload, this.notificationAppLaunchDetails})
      : super(key: key);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  static const String routeName = '/NotificationPage';

  final String? payload;
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool fromNewNotification = false;
  @override
  void initState() {
    super.initState();
    sl.get<NotificationProvider>().init();
    FlutterAppBadger.removeBadge();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      errorLog((await FirebaseMessaging.instance.getToken()).toString());

      final args = ModalRoute.of(context)!.settings.arguments;
      print('arguments--> $args ${args.runtimeType}');
      if (args != null && args is String && args.isNotEmpty) {
        setState(() {
          fromNewNotification = true;
        });
        /*  showDialog<void>(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return NotificationPageFirstMessageDialog(data: jsonDecode(args));
          },
        );
        sl.get<NotificationProvider>().markRead(
            await (sl.get<NotificationProvider>().notifications.stream.first)
                .then((value) => value.first['id']));

       */
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: titleLargeText('Notifications', context),
        shadowColor: Colors.white,
        actions: [
          // ElevatedButton(
          //     onPressed: () {
          //       showDialog<void>(
          //         context: context,
          //         barrierColor: Colors.transparent,
          //         barrierDismissible: true,
          //         builder: (BuildContext dialogContext) {
          //           return NotificationPageFirstMessageDialog(
          //             data: jsonDecode(ModalRoute.of(context)!
          //                 .settings
          //                 .arguments
          //                 .toString()),
          //           );
          //         },
          //       );
          //     },
          //     child: Text('Test')),
        ],
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: userAppBgImageProvider(context),
        //     fit: BoxFit.cover,
        //     opacity: 0.5,
        //   ),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: sl.get<NotificationProvider>().notifications.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    return snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.isNotEmpty
                        ? buildList(snapshot)
                        : snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.isEmpty
                            ? buildNoNotification(context)
                            : Center(
                                child: bodyLargeText(
                                    'Some Thing went wrong', context));
                  } else {
                    return Center(
                        child: bodyLargeText('Some Thing went wrong', context));
                  }
                },
              ),
            ),
            // ElevatedButton(
            //     onPressed: () async {
            //       await FirebaseMessaging.instance.subscribeToTopic('monthly');
            //     },
            //     child: Text('Subscribe')),
            // Center(
            //   child: bodyLargeText(
            //       (ModalRoute.of(context)!.settings.arguments).toString(),
            //       context),
            // ),
          ],
        ),
      ),
    );
  }

  Column buildNoNotification(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        assetImages('no-notifications.png'),
        Center(
            child: titleLargeText('There is no notifications yet.', context)),
        height20(),
        OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back();
              Get.back();
            },
            // onPressed: () => MyCarClub
            //     .navigatorKey.currentState
            //     ?.pushNamedAndRemoveUntil(
            //         MainPage.routeName, (r) => false),
            child: bodyLargeText('Go to DashBoard', context))
      ],
    );
  }

  ListView buildList(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    // print(snapshot.data?.first);

    return ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          var notification = snapshot.data![index];
          return NotificationPageTileWidget(
              notification: notification,
              expanded: index == 0 ? fromNewNotification : false);
        });
  }
}

class NotificationPageFirstMessageDialog extends StatelessWidget {
  const NotificationPageFirstMessageDialog({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    var notification = FCMNotificationData.fromJson(data);

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(CupertinoIcons.clear_circled_solid,
                      color: Colors.white),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10),
                //   color: Colors.white,
                // ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Scaffold(
                    // backgroundColor: Colors.transparent,
                    body: Column(
                      children: [
                        height10(),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: titleLargeText(
                                    '${data['title']}', context,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(10),
                            children: [
                              bodyLargeText(notification.body ?? '', context,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                              if (notification.image != null &&
                                  notification.image != '')
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    height10(),
                                    height10(),
                                    CachedNetworkImage(
                                      imageUrl: notification.image!,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  strokeWidth: 2)),
                                        ],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          assetImages(Assets.imageNotFound,
                                              color: Colors.white,
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.contain),
                                      cacheManager: CacheManager(Config(
                                        "${AppConstants.appName}_notification_${notification.timestamp}",
                                        stalePeriod: const Duration(days: 7),
                                        //one week cache period
                                      )),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        (notification.actions != null &&
                                notification.actions!.isNotEmpty)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ...notification.actions!.map(
                                      (e) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3.0),
                                          child: TextButton(
                                            onPressed: () {
                                              Get.back();
                                              launchTheLink(
                                                  e.entries.first.value);
                                            },
                                            child: capText(
                                                e.entries.first.key
                                                    .toString()
                                                    .toUpperCase(),
                                                context,
                                                textAlign: TextAlign.center,
                                                color: CupertinoColors.link,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationPageFirstMessageDialog2 extends StatelessWidget {
  const NotificationPageFirstMessageDialog2({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    var notification = FCMNotificationData.fromJson(data);

    return Stack(
      // alignment: AlignmentDirectional.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: kTextTabBarHeight),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    height10(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: titleLargeText('${data['title']}', context,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: Get.height * 0.4,
                      padding: const EdgeInsets.all(10.0),
                      child: ListView(
                        children: [
                          bodyLargeText(notification.body ?? '', context,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          if (notification.image != null &&
                              notification.image != '')
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                height10(),
                                height10(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CachedNetworkImage(
                                        imageUrl: notification.image!,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                                height: 25,
                                                width: 25,
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                        strokeWidth: 2)),
                                          ],
                                        ),
                                        errorWidget: (context, url, error) =>
                                            assetImages(Assets.imageNotFound,
                                                color: Colors.white,
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.contain),
                                        cacheManager: CacheManager(Config(
                                          "${AppConstants.appName}_notification_${notification.timestamp}",
                                          stalePeriod: const Duration(days: 7),
                                          //one week cache period
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (notification.actions != null &&
                        notification.actions!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ...notification.actions!.map(
                              (e) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0),
                                  child: TextButton(
                                    onPressed: () {
                                      Get.back();
                                      launchTheLink(e.entries.first.value);
                                    },
                                    child: capText(
                                        e.entries.first.key
                                            .toString()
                                            .toUpperCase(),
                                        context,
                                        textAlign: TextAlign.center,
                                        color: CupertinoColors.link,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              )),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon:
                  Icon(CupertinoIcons.clear_circled_solid, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationPageTileWidget extends StatefulWidget {
  const NotificationPageTileWidget(
      {super.key, required this.notification, required this.expanded});
  final Map<String, dynamic> notification;
  final bool expanded;
  @override
  State<NotificationPageTileWidget> createState() =>
      _NotificationPageTileWidgetState();
}

class _NotificationPageTileWidgetState
    extends State<NotificationPageTileWidget> {
  bool expanded = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      expanded = widget.expanded;
      () => sl.get<NotificationProvider>().markRead(widget.notification['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.notification['isRead'] == 0
              ? () => sl
                  .get<NotificationProvider>()
                  .markRead(widget.notification['id'])
                  .then((value) => setState(() => expanded = !expanded))
              : () => setState(() => expanded = !expanded),
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // color: widget.notification['isRead'] != 0
              //     ? Colors.white10
              //     : Colors.white24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    capText(
                        '${DateFormat().add_jm().format(DateTime.parse(widget.notification['createdAt']))}',
                        context,
                        color: widget.notification['isRead'] != 0
                            ? Colors.white70
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10)
                  ],
                ),
                height5(),
                Row(
                  children: [
                    Expanded(
                      child: bodyLargeText(
                          '${widget.notification['title']}', context,
                          color: widget.notification['isRead'] != 0
                              ? expanded
                                  ? Colors.white
                                  : Colors.white70
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          maxLines: expanded ? 10 : null),
                    ),
                    if (widget.notification['data'] != null && !expanded)
                      Builder(builder: (context) {
                        var data = FCMNotificationData.fromJson(
                            jsonDecode(widget.notification['data']));
                        return Column(
                          children: [
                            if (data.image != null && data.image != '')
                              CachedNetworkImage(
                                imageUrl: data.image!,
                                fit: BoxFit.contain,
                                imageBuilder: (context, imageP) => Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageP,
                                                fit: BoxFit.contain))),
                                  ],
                                ),
                                placeholder: (context, url) => Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            strokeWidth: 2)),
                                  ],
                                ),
                                errorWidget: (context, url, error) =>
                                    assetImages(Assets.imageNotFound,
                                        color: Colors.white,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.contain),
                                cacheManager: CacheManager(Config(
                                  "${AppConstants.appName}_notification_${widget.notification['createdAt']}",
                                  stalePeriod: const Duration(days: 7),
                                )),
                              ),
                            // Container(
                            //   height: 40,
                            //   width: 80,
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(5),
                            //     image: DecorationImage(
                            //       image: netImageProvider(data.image!),
                            //       fit: BoxFit.contain,
                            //     ),
                            //   ),
                            // ),
                          ],
                        );
                      }),
                  ],
                ),
                if (widget.notification['data'] != null && expanded)
                  Builder(builder: (context) {
                    var data = FCMNotificationData.fromJson(
                        jsonDecode(widget.notification['data']));
                    // print(data.actions);

                    return Column(
                      children: [
                        height10(),
                        capText(parseHtmlString(data.body ?? ''), context,
                            maxLines: 100,
                            color: widget.notification['isRead'] != 0
                                ? Colors.white70
                                : Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 14),
                        if (data.image != null && data.image != '')
                          Column(
                            children: [
                              height10(),
                              height10(),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: data.image!,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            strokeWidth: 2),
                                      )),
                                  errorWidget: (context, url, error) =>
                                      assetImages(Assets.imageNotFound,
                                          color: Colors.white,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.contain),
                                  cacheManager: CacheManager(Config(
                                    "${AppConstants.appName}_notification_${widget.notification['createdAt']}",
                                    stalePeriod: const Duration(days: 7),
                                    //one week cache period
                                  )),
                                ),
                              ),
                              height10(),
                              height10(),
                            ],
                          ),
                        if (data.actions != null && data.actions!.isNotEmpty)
                          Wrap(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            alignment: WrapAlignment.end,
                            spacing: 10,
                            children: [
                              ...data.actions!.map(
                                (e) => TextButton(
                                  onPressed: () =>
                                      launchTheLink(e.entries.first.value),
                                  child: capText(
                                      e.entries.first.key
                                          .toString()
                                          .toUpperCase(),
                                      context,
                                      color: CupertinoColors.link,
                                      decoration: TextDecoration.underline),
                                ),
                              )
                            ],
                          ),
                      ],
                    );
                  }),
                height5(),
                if (widget.notification['data'] != null)
                  Builder(builder: (context) {
                    var data = FCMNotificationData.fromJson(
                        jsonDecode(widget.notification['data']));
                    return capText(
                        // '${DateFormat().add_yMMMd().add_jms().format(DateTime.parse(widget.notification['createdAt']))}',
                        '${DateFormat().add_yMMMd().format(DateTime.parse(widget.notification['createdAt']))}',
                        context,
                        color: widget.notification['isRead'] != 0
                            ? Colors.white70
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10);
                  }),
              ],
            ),
          ),
        ),
        Divider(color: Colors.white, height: 0),
      ],
    );
  }
}
