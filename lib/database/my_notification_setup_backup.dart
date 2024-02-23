import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/repositories/auth_repo.dart';
import '/main.dart';
import '/providers/notification_provider.dart';
import '/sl_container.dart';
import '/utils/network_info.dart';
import '/utils/notification_sqflite_helper.dart';
import 'package:path_provider/path_provider.dart';

import '../myapp.dart';
import '../screens/Notification/notification_page.dart';

int id = 0;

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

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
  // ignore: avoid_print
  print(
      'notificationTapBackground notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    // print(
    //     'notification action tapped with input: ${notificationResponse.input}');
  }
}

class MyNotification {
  Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
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
        provisional: false,
        sound: true);

    ///flp initialisation
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text('text_1', 'Action 1',
              buttonTitle: 'Send', placeholder: 'Placeholder')
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
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
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final RemoteMessage? initialMessages = await messaging.getInitialMessage();
    if (initialMessages != null) {
      ///TODO:handle the initial messages
    }
    print(
        'this is FirebaseMessaging on initialMessages ${initialMessages?.data}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message, flutterLocalNotificationsPlugin, true);
    });
    //TODO:Periodic notification
    /*    flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      "Testing Notification",
      'Hello Everyone. It\'s ${DateFormat().add_jm().format(DateTime.now())}',
      RepeatInterval.hourly,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'Periodic',
          'Testing',
          channelDescription: 'your channel desc',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
        ),
      ),
      payload: jsonEncode({
       "title": "Testing Notification",
        "body":'Hello Everyone. It\'s ${DateFormat().add_jm().format(DateTime.now())}',
      }),
    );*/
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   // print('this is FirebaseMessaging onMessageOpenedApp ');
    //   // showNotification(message,flutterLocalNotificationsPlugin,false);
    //   print(
    //       "onOpenApp: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
    //   // try {
    //   //   if (message.notification?.titleLocKey != null &&
    //   //       (message.notification?.titleLocKey ?? '').isNotEmpty) {
    //   //     MyCarClub.navigatorKey.currentState?.push(MaterialPageRoute(
    //   //         builder: (context) => NotificationPage(
    //   //             // orderModel: null,
    //   //             // orderId: int.parse(message.notification?.titleLocKey),
    //   //             // orderType: 'default_type',
    //   //             )));
    //   //   }
    //   // } catch (e) {}
    // });
    void _handleMessage(RemoteMessage message) {
      print('notification is selected now ');
      selectNotificationStream.add(parseHtmlString(jsonEncode(message.data)));
      MyApp.navigatorKey.currentState
          ?.pushNamed(NotificationPage.routeName, arguments: message.data);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }
}

Future<void> _showNotification(RemoteMessage message,
    FlutterLocalNotificationsPlugin fln, bool data) async {
  String _title;
  String _body;
  String? payload;
  String? _image;
  if (data) {
    _title = parseHtmlString(message.data['title'] ?? '');
    _body = parseHtmlString(message.data['body'] ?? '');
    payload = jsonEncode(message.data);
    _image = (message.data['image'] != null && message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http') ||
                message.data['image'].startsWith('https')
            ? message.data['image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
        : null;
  } else {
    _title = parseHtmlString(message.notification?.title ?? '');
    _body = parseHtmlString(message.notification?.body ?? '');
    payload = jsonEncode(message.notification);
    if (Platform.isAndroid) {
      // _image = (message.notification?.android?.imageUrl != null)
      //     ? message.notification?.android?.imageUrl?.startsWith('http')
      //         ? message.notification?.android.imageUrl
      //         : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification?.android.imageUrl}'
      //     : null;
    } else if (Platform.isIOS) {
      // _image = (message.notification?.apple.imageUrl != null &&
      //         message.notification?.apple.imageUrl.isNotEmpty)
      //     ? message.notification?.apple.imageUrl.startsWith('http')
      //         ? message.notification?.apple.imageUrl
      //         : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification?.apple.imageUrl}'
      //     : null;
    }
  }
  if (_image != null && _image.isNotEmpty) {
    try {
      await showBigPictureNotificationHiddenLargeIcon(
          _title, _body, payload, _image, fln);
    } catch (e) {
      await showBigTextNotification(_title, _body, payload, fln);
    }
  } else {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel desc',
      importance: Importance.max,
      // styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('notification'),
    );
    await showBigTextNotification(_title, _body, payload, fln);
  }
  print('image to show in notification is $_image');

  try {
    print('bg user id ${await sl.get<AuthRepo>().getUserID()}');
    if (await sl.get<AuthRepo>().getUserID() != '') {
      await sl
          .get<NotificationDatabaseHelper>()
          .createItem(_title, await sl.get<AuthRepo>().getUserID(),
              additional: jsonEncode(message.data))
          .then((value) async {
        print('notification createItem to local db successfully!👏');
        sl.get<NotificationProvider>().notifications.add(await sl
            .get<NotificationDatabaseHelper>()
            .listenToSqlNotifications());
        print('notification added to local db successfully!👏');
      }).then((value) => sl.get<NotificationProvider>().getUnRead());
    } else {
      print('USER not logged in. So, adding notification to local db failed');
    }
  } catch (e) {
    print('adding notification to local db failed');
  }
}
// if (payload['topic'].toLowerCase() == 'survey') {
// WidgetsBinding.instance.addPostFrameCallback((_) {
// showSurvey(int.tryParse(payload['id']));
// });
// }

Future<void> showTextNotification(String title, String body, String payload,
    FlutterLocalNotificationsPlugin fln) async {
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
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await fln.show(0, title, body, platformChannelSpecifics, payload: payload);
}

Future<void> showBigTextNotification(String title, String body, String? payload,
    FlutterLocalNotificationsPlugin fln) async {
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
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await fln.show(0, title, body, platformChannelSpecifics, payload: payload);
}

Future<void> showBigPictureNotificationHiddenLargeIcon(
    String title,
    String body,
    String? payload,
    String image,
    FlutterLocalNotificationsPlugin fln) async {
// print('this is big picture notification');
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
  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await fln.show(0, title, body, platformChannelSpecifics, payload: payload);
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
  print("Handling a background message: ${message.messageId}");
  var title = parseHtmlString(message.data['title']);
  var body = parseHtmlString(message.data['body']);
  await FirebaseMessaging.instance.getInitialMessage();
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

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
    priority: Priority.high,
    playSound: true,
    // sound: RawResourceAndroidNotificationSound('notification'),
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  _showNotification(message, flutterLocalNotificationsPlugin, true);
  // await flutterLocalNotificationsPlugin
  //     .show(0, title, body, platformChannelSpecifics, payload: 'orderID');
}
