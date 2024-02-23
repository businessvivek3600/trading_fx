import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Response;
import 'package:permission_handler/permission_handler.dart';
import '../utils/my_logger.dart';
import '/screens/dashboard/company_trade_ideas_page.dart';
import '/screens/youtube_video_play_widget.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/repositories/auth_repo.dart';
import '/main.dart';
import '/providers/notification_provider.dart';
import '/screens/drawerPages/inbox/inbox_screen.dart';
import '/sl_container.dart';
import '/utils/default_logger.dart';
import '/utils/network_info.dart';
import '/utils/notification_sqflite_helper.dart';
import '/utils/sp_utils.dart';
import 'package:path_provider/path_provider.dart';

import '../myapp.dart';
import '../screens/Notification/notification_page.dart';

int notificationId = 0;

String? notificationPaylod;

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

class ReceivedNotification {
  ReceivedNotification(
      {required this.id,
      required this.title,
      required this.body,
      required this.payload});

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  infoLog(
      'notificationTapBackground notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}',
      MyNotification.tag);
  if (notificationResponse.input?.isNotEmpty ?? false) {}
}

bool _notificationsEnabled = false;
late InitializationSettings initializationSettings;

class MyNotification {
  static const String tag = 'MyNotification';
  Future<void> initialize() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        sound: true);

    ///flp initialisation
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(darwinNotificationCategoryText,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.text('text_1', 'Action 1',
                buttonTitle: 'Send', placeholder: 'Placeholder')
          ]),
      DarwinNotificationCategory(darwinNotificationCategoryPlain,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain('id_2', 'Action 2 (destructive)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive
                }),
            DarwinNotificationAction.plain(
                navigationActionId, 'Action 3 (foreground)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground
                }),
            DarwinNotificationAction.plain('id_4', 'Action 4 (auth required)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.authenticationRequired
                }),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle
          })
    ];
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        selectNotificationStream.add(parseHtmlString(payload ?? ""));
        didReceiveLocalNotificationStream.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      },
      notificationCategories: darwinNotificationCategories,
    );
    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream
              .add(parseHtmlString(notificationResponse.payload ?? ""));
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream
                .add(parseHtmlString(notificationResponse.payload ?? ''));
          }
          break;
      }
    }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    final RemoteMessage? initialMessages = await messaging.getInitialMessage();
    if (initialMessages != null) {
      //todo: handle initial message
      warningLog('messaging.getInitialMessage ${initialMessages.data}', tag,
          'initialMessages');
      // Future.delayed(Duration(seconds: 6), () async {
      //   selectNotificationStream
      //       .add(parseHtmlString(jsonEncode(initialMessages.data)));
      // });
      notificationPaylod = jsonEncode(initialMessages.data);
    }
    infoLog(
        'this is FirebaseMessaging on initialMessages ${initialMessages?.data}',
        tag);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _clearAppNotificationBadge();
      _handleNotificationData(message, true, fromBg: false);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    infoLog('notification is selected now ', MyNotification.tag);
    _clearAppNotificationBadge();
    selectNotificationStream.add(parseHtmlString(jsonEncode(message.data)));
  }

  // static Future<void> requestPermissions() async {
  //   if (Platform.isIOS || Platform.isMacOS) {
  //     _notificationsEnabled = await flutterLocalNotificationsPlugin
  //             .resolvePlatformSpecificImplementation<
  //                 IOSFlutterLocalNotificationsPlugin>()
  //             ?.requestPermissions(alert: true, badge: true, sound: true) ??
  //         false;
  //     _notificationsEnabled = await flutterLocalNotificationsPlugin
  //             .resolvePlatformSpecificImplementation<
  //                 MacOSFlutterLocalNotificationsPlugin>()
  //             ?.requestPermissions(alert: true, badge: true, sound: true) ??
  //         false;
  //   } else if (Platform.isAndroid) {
  //     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
  //         flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //             AndroidFlutterLocalNotificationsPlugin>();
  //     final bool? granted = await androidImplementation?.requestPermission();
  //     _notificationsEnabled = granted ?? false;
  //   }
  // }

  ///request permission
  static Future<void> requestPermissions() async {
    ///check request permission
    await Permission.notification
        .onDeniedCallback(() {
          logger.w('Permission.notification.onDeniedCallback');
          _permissionForNotification();
        })
        .onGrantedCallback(() {
          logger.w('Permission.notification.onGrantedCallback');
          // _permission();
        })
        .onPermanentlyDeniedCallback(() {
          logger.w('Permission.notification.onPermanentlyDeniedCallback');
          _permissionForNotification();
        })
        .onRestrictedCallback(() {
          logger.w('Permission.notification.onRestrictedCallback');
          _permissionForNotification();
        })
        .onLimitedCallback(() {
          logger.w('Permission.notification.onLimitedCallback');
          _permissionForNotification();
        })
        .onProvisionalCallback(() {
          logger.w('Permission.notification.onProvisionalCallback');
          _permissionForNotification();
        })
        .request()
        .then((value) => logger.i('Permission.notification.request: $value'));
  }

  static void _permissionForNotification() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _notificationsEnabled = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await androidImplementation?.requestPermission();
      _notificationsEnabled = granted ?? false;
    }
  }

  static void configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      warningLog(
          'notification tapped from _configureDidReceiveLocalNotificationSubject',
          tag,
          'configureDidReceiveLocalNotificationSubject');
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await MyApp.navigatorKey.currentState?.pushNamed(
                    NotificationPage.routeName,
                    arguments: receivedNotification.payload);
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  static void configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      warningLog(
          'notification tapped from _configureSelectNotificationSubject {data: $payload}',
          tag,
          'configureSelectNotificationSubject');

      Map<String, dynamic>? data = payload != null ? jsonDecode(payload) : null;
      String localUser = (await sl.get<AuthRepo>().getUserID()).toLowerCase();
      bool isLoggedIn = localUser != '';
      if (data != null) {
        String? _topic = data['topic'];
        String? _type = data['type'];
        String? routeName;
        infoLog(
            'notification type is $_type localUser : ${localUser != ''} and it has match with ${_matchType(_type, notificationType.inbox)}',
            MyNotification.tag);

        ///if user is logged in
        if (localUser != '') {
          if (_matchType(_type, notificationType.inbox)) {
            routeName = InboxScreen.routeName;
          } else if (_matchType(_type, notificationType.ytLive)) {
            routeName = YoutubePlayerPage.routeName;
            payload = jsonEncode({
              'videoId': data['videoId'],
              'isLive': data['isLive'].toString() == true.toString()
            });
          } else if (_matchTopic(_topic, topics.forex_signal)) {
            routeName = CompanyTradeIdeasPage.routeName;
          } else {
            routeName = NotificationPage.routeName;
          }
          // errorLog('notification tapped from  : $routeName', tag,
          //     'configureSelectNotificationSubject and payload: $payload');
          if (routeName == YoutubePlayerPage.routeName) {
            if (data['isLive'] != null &&
                data['isLive'].toString() == true.toString()) {
              await MyApp.navigatorKey.currentState
                  ?.pushNamed(routeName, arguments: payload);
            } else {
              // await MyCarClub.navigatorKey.currentState
              //     ?.pushReplacementNamed(MainPage.routeName);
            }
          } else if (routeName != YoutubePlayerPage.routeName) {
            await MyApp.navigatorKey.currentState
                ?.pushNamed(routeName, arguments: payload);
          }

          // MyCarClub.navigatorKey.currentState
          //     ?.pushNamed(routeName, arguments: payload);
          // MyCarClub.navigatorKey.currentState?.pushNamed(
          // YoutubePlayerPage.routeName,
          // arguments:
          // jsonEncode({'videoId': 'ePplpyOQd74', 'isLive': false}));
        }
      }
    });
  }
}

bool isUserOnSamePage(BuildContext context, String routeName) {
  return ModalRoute.of(context)?.settings.name == routeName;
}

Future<void> _handleNotificationData(RemoteMessage message, bool data,
    {required bool fromBg}) async {
  String _title;
  String _body;
  String? payload;
  String? _image;

  ///
  if (data) {
    _title = parseHtmlString(message.data['title'] ?? '');
    _body = parseHtmlString(message.data['body'] ?? '');
    payload = jsonEncode(message.data);
    _image = _getImageFromData(message);
  } else {
    _title = parseHtmlString(message.notification?.title ?? '');
    _body = parseHtmlString(message.notification?.body ?? '');
    if (Platform.isAndroid) {
      _image = _getImageAndroidImage(message);
    } else if (Platform.isIOS) {
      _image = _getImageIosImage(message);
    }
  }

  ///
  handleAppNotificationBadge(fromBg);
  infoLog('title: $_title  ', MyNotification.tag);
  String localUser = (await sl.get<AuthRepo>().getUserID()).toLowerCase();

  bool isUserLoggedIn = localUser != '';
  Map<String, dynamic> _data = payload != null ? jsonDecode(payload) ?? {} : {};
  String unknownUser = 'unknown';
  String notificationUser = (_data['user_id'] ?? '').toString().toLowerCase();
  String topic = _data['topic'] ?? 'none';
  String type = _data['type'] ?? '';
  try {
    infoLog(
        'localUser user id $localUser   and  notificationUser is ** $notificationUser **',
        MyNotification.tag);

    /// 1. if notification is to specific user
    // if ((topic == '' || topic == topics.testing.name)) {
    /// 3. store if notification user is not blank
    if (notificationUser != '' && topic == 'none') {
      /// store
      ///check for type
      infoLog(
          'notification type is $type  and it has match with ${_matchType(type, notificationType.inbox)}',
          MyNotification.tag);
      if (!_matchType(type, notificationType.inbox)) {
        ///store notifications
        _saveNotification(_title, notificationUser, localUser,
            data: message.data);
      }

      /// 4. if user logged in
      if (localUser != '') {
        /// 6. check for same user
        if (localUser == notificationUser && !fromBg) {
          // show notification and navigate to the content
          showCustomizedNotification(_title, _body, payload, _image);
        }

        /// 7. handle for diff user
        else {
          // don't show the notification
        }
      }

      /// 5. if user not logged in
      else {
        // show login notification
        if (!fromBg) {
          showCustomizedNotification('New message',
              'Authentication required to read the message.', payload, null);
        }
      }
    }

    ///   if notification user is blank
    else {
      var user = localUser != '' ? localUser : topic;
      infoLog('this is topic notification : $topic, user:$user',
          MyNotification.tag);

      /// 8. store notification if not match
      if (!_matchType(type, notificationType.ytLive) &&
          !_matchTopic(topic, topics.forex_signal)) {
        _saveNotification(_title, user, user, data: message.data);
      }
      if (!fromBg) {
        if (_matchTopic(topic, topics.forex_signal)) {
          if (isUserLoggedIn) {
            showCustomizedNotification(_title, _body, payload, _image);
          }
        } else {
          showCustomizedNotification(_title, _body, payload, _image);
        }
      }
    }
    // }
    /// 2. handle topic notification
    // else {
    //   infoLog('handling topic notification to local db', MyNotification.tag);
    //   await storeNotification(_title, 'unknown', data: jsonEncode(message.data))
    //       .then((value) async {
    //     infoLog('Topic notification createItem to local db successfully!👏',
    //         MyNotification.tag);
    //     addToNotificationStream();
    //     infoLog('Topic notification added to controller successfully!👏',
    //         MyNotification.tag);
    //   }).then((value) => sl.get<NotificationProvider>().getUnRead());
    //   showDynamicNotification(_title, _body, payload, _image, fln);
    // }
  } catch (e) {
    infoLog('adding notification to local db failed', MyNotification.tag);
  }
}

Future<void> handleAppNotificationBadge(bool fromBg) async {
  try {
    var spUtil = sl.get<SpUtil>();
    int badges = spUtil.getInt(SPConstants.appBadge) ?? 0;
    spUtil.setInt(SPConstants.appBadge, badges + 1);
    await FlutterAppBadger.updateBadgeCount(badges + 1)
        .then((value) => successLog(
            'FlutterAppBadger.updateBadgeCount ${fromBg ? 'myBackgroundMessageHandler' : '_handleNotificationData'} running...'))
        .onError((error, stackTrace) => errorLog(
            'FlutterAppBadger.updateBadgeCount ${fromBg ? 'myBackgroundMessageHandler' : '_handleNotificationData'} error ${error.toString()}...'));
  } catch (e) {
    errorLog('handleAppNotificationBadge error $e');
  }
}

Future<void> _clearAppNotificationBadge() async {
  sl.get<SpUtil>().setInt(SPConstants.appBadge, 0);
  FlutterAppBadger.removeBadge();
}

bool _matchType(data, notificationType _type) {
  warningLog(
      'type: $data',
      'matched with ${notificationType.values.any((type) => type.name == data)}',
      '_matchType');
  return data != null &&
      data.toString().toLowerCase() == _type.name.toLowerCase();
}

bool _matchTopic(data, topics _topic) {
  return data != null &&
      data.toString().toLowerCase() == _topic.name.toLowerCase();
}

Future<void> showCustomizedNotification(
    String title, String body, String? payload, String? image) async {
  infoLog(
      'Finally notification ->payLoad $payload -> title: $title image $image ',
      MyNotification.tag,
      'showDynamicNotification');

  //show notification
  if (image != null && image.isNotEmpty) {
    try {
      Platform.isIOS || Platform.isMacOS
          ? await _showBigTextNotification(title, body, payload)
          : await _showBigPictureNotificationHiddenLargeIcon(
                  title, body, payload, image)
              .onError((error, stackTrace) => logger.e('big picture error',
                  error: error, stackTrace: stackTrace));
    } catch (e) {
      await _showBigTextNotification(title, body, payload);
    }
  } else {
    await _showBigTextNotification(title, body, payload);
  }
}

_saveNotification(String? title, String? notificationUser, String? localUser,
    {dynamic data}) async {
  await _storeNotification(title, notificationUser, data: jsonEncode(data))
      .then((value) async {
    infoLog(
        'notification createItem to local db successfully!👏 for user $notificationUser',
        MyNotification.tag);
    _addToNotificationStream();
    infoLog(
        'notification added to controller successfully!👏 for user $localUser',
        MyNotification.tag);
  }).then((value) => sl.get<NotificationProvider>().getUnRead());
}

void _addToNotificationStream() async => sl
    .get<NotificationProvider>()
    .notifications
    .add(await sl.get<NotificationDatabaseHelper>().listenToSqlNotifications());

Future<int> _storeNotification(String? title, String? userId,
    {dynamic data}) async {
  return await sl
      .get<NotificationDatabaseHelper>()
      .createItem(title, userId, additional: data);
}

String? _getImageFromData(RemoteMessage message) {
  return (message.data['image'] != null && message.data['image'].isNotEmpty)
      ? message.data['image'].startsWith('http') ||
              message.data['image'].startsWith('https')
          ? message.data['image']
          : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
      : null;
}

String? _getImageAndroidImage(RemoteMessage message) {
  var android = message.notification?.android;
  return (android != null && android.imageUrl != null)
      ? android.imageUrl!.startsWith('http') ||
              android.imageUrl!.startsWith('https')
          ? android.imageUrl!
          : '${AppConstants.baseUrl}/storage/app/public/notification/${android.imageUrl}'
      : null;
}

String? _getImageIosImage(RemoteMessage message) {
  var apple = message.notification?.apple;
  return (apple != null && apple.imageUrl != null)
      ? apple.imageUrl!.startsWith('http') ||
              apple.imageUrl!.startsWith('https')
          ? apple.imageUrl!
          : '${AppConstants.baseUrl}/storage/app/public/notification/${apple.imageUrl}'
      : null;
}

int get getUniqueNotificationId => Random().nextInt(1000);

Future<void> _showTextNotification(
    String title, String body, String payload) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel desc',
    playSound: true,
    importance: Importance.max,
    priority: Priority.max,
    sound: RawResourceAndroidNotificationSound('notification'),
  );
  DarwinNotificationDetails iOSPlatformChannelSpecifics =
      const DarwinNotificationDetails(
          attachments: <DarwinNotificationAttachment>[
        DarwinNotificationAttachment(
          'https://via.placeholder.com/400x800',
          identifier: 'bigPicture',
        )
      ],
          presentAlert: true,
          presentBadge: true,
          presentSound: true);
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    // iOS: iOSPlatformChannelSpecifics,
    // macOS: iOSPlatformChannelSpecifics,
  );
  errorLog(
      'getUniqueNotificationId $getUniqueNotificationId', MyNotification.tag);
  await flutterLocalNotificationsPlugin.show(
      getUniqueNotificationId, title, body, platformChannelSpecifics,
      payload: payload);
}

Future<void> _showBigTextNotification(
    String title, String body, String? payload) async {
  BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
    body,
    htmlFormatBigText: true,
    contentTitle: title,
    htmlFormatContentTitle: true,
  );
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel desc',
    importance: Importance.max,
    styleInformation: bigTextStyleInformation,
    priority: Priority.max,
    playSound: true,
    // sound: RawResourceAndroidNotificationSound('notification'),
  );
  DarwinNotificationDetails iOSPlatformChannelSpecifics =
      const DarwinNotificationDetails(
          attachments: <DarwinNotificationAttachment>[],
          presentAlert: true,
          presentBadge: true,
          presentSound: true);
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    // iOS: iOSPlatformChannelSpecifics,
    // macOS: iOSPlatformChannelSpecifics,
  );
  errorLog(
      'getUniqueNotificationId big text $getUniqueNotificationId title:$title',
      MyNotification.tag);
  await flutterLocalNotificationsPlugin.show(
      getUniqueNotificationId, title, body, platformChannelSpecifics,
      payload: payload);
}

Future<void> _showBigPictureNotificationHiddenLargeIcon(
    String title, String body, String? payload, String image) async {
// infoLog(data)('this is big picture notification',MyNotification.tag);
  final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
  final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
  final BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
    FilePathAndroidBitmap(bigPicturePath),
    hideExpandedLargeIcon: true,
    contentTitle: title,
    htmlFormatContentTitle: true,
    summaryText: body,
    htmlFormatSummaryText: true,
  );
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
// 'your channel desc',
    largeIcon: FilePathAndroidBitmap(largeIconPath),
    priority: Priority.max,
    playSound: true,
    styleInformation: bigPictureStyleInformation,
    importance: Importance.max,
// sound: RawResourceAndroidNotificationSound('notification'),
  );
  DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(attachments: <DarwinNotificationAttachment>[
    DarwinNotificationAttachment(bigPicturePath,
        identifier: 'bigPicture${DateTime.now().millisecondsSinceEpoch}')
  ], presentAlert: true, presentBadge: true, presentSound: true);

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    // iOS: iOSPlatformChannelSpecifics,
    // macOS: iOSPlatformChannelSpecifics,
  );
  errorLog(
      'getUniqueNotificationId _showBigPictureNotificationHiddenLargeIcon $getUniqueNotificationId  title:$title',
      MyNotification.tag);
  await flutterLocalNotificationsPlugin.show(
      getUniqueNotificationId, title, body, platformChannelSpecifics,
      payload: payload);
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final Response response =
      await Dio().get(url, options: Options(responseType: ResponseType.bytes));
  final File file = File(filePath);
  await file.writeAsBytes(response.data);
  return filePath;
}

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initRepos().then((value) async {
    await sl.get<NetworkInfo>().isConnected;
    await sl.get<NotificationDatabaseHelper>().db();
  });
  infoLog("Handling a background message: ${message.messageId}",
      MyNotification.tag);
  await FirebaseMessaging.instance.getInitialMessage();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  await handleAppNotificationBadge(false);
  _handleNotificationData(message, true, fromBg: true);
}

///enums
enum notificationType { inbox, notification, subscription, ytLive, none }

enum topics {
  none,
  subscribe_to_all,
  forex_signal,
  subscribe_to_testing,
  platinum,
  monthly,
  deActive,
  nonActive
}
