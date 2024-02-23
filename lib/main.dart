import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/utils/device_info.dart';
import '/utils/text.dart';
import '/utils/default_logger.dart';
import '/database/functions.dart';
import '/screens/splash/splash_screen.dart';
import '/sl_container.dart';
import '/utils/app_icon_badge_utils.dart';
import '/utils/network_info.dart';
import '/utils/notification_sqflite_helper.dart';

import 'database/app_update/upgrader.dart';
import 'database/my_notification_setup.dart';
import 'myapp.dart';
import 'providers/auth_provider.dart';
import 'utils/picture_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
ValueNotifier<UniqueKey> restartAppKey = ValueNotifier(UniqueKey());
Future<void> main() async {
  // timer;
  WidgetsFlutterBinding.ensureInitialized();
  await initRepos().then((value) async {
    await sl.get<NetworkInfo>().isConnected;
    await sl.get<NotificationDatabaseHelper>().db();
    await sl.get<DeviceInfoConfig>().initPlatformState();
  });
  await Upgrader.clearSavedSettings();
  await Firebase.initializeApp();
  await configureLocalTimeZone();
  TextInput.ensureInitialized();

  await initPlatformState();
  // Non-async exceptions

  //crashlytics
  _crashlystics();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  MyNotification().initialize();
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  errorLog(
      "notificationAppLaunchDetails : ${notificationAppLaunchDetails?.didNotificationLaunchApp} ${notificationAppLaunchDetails?.notificationResponse} ${notificationAppLaunchDetails?.notificationResponse?.payload}");
  String initialRoute = SplashScreen.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    errorLog(
        "didNotificationLaunchApp : push notification payload : ${notificationAppLaunchDetails?.notificationResponse?.payload ?? ''}");
    selectedNotificationPayload =
        notificationAppLaunchDetails?.notificationResponse?.payload;
    selectNotificationStream.add(selectedNotificationPayload);
  }

  runApp(ValueListenableBuilder(
      valueListenable: restartAppKey,
      builder: (BuildContext context, UniqueKey value, Widget? child) {
        return MyApp(
            key: value,
            initialRoute: initialRoute,
            notificationAppLaunchDetails: notificationAppLaunchDetails);
      }));
}

void setErrorBuilder() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return ErrorPage(errorDetails: errorDetails);
  };
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.errorDetails,
  });
  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context), fit: BoxFit.cover)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
                child: bodyLargeText(
              "Something went wrong. Please restart the app and try again.",
              context,
              textAlign: TextAlign.center,
            )),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     //restart App

      //     try {
      //       Navigator.pushAndRemoveUntil(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) =>
      //                   MyCarClub(initialRoute: SplashScreen.routeName)),
      //           (route) => false);
      //     } catch (e) {
      //       errorLog(e.toString());
      //     }
      //   },
      //   child: Icon(Icons.home),
      // ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}

Future<void> _crashlystics() async {
  try {
    const bool fatalError = true;

    // FirebaseCrashlytics.instance.setUserIdentifier("12345");
    // FirebaseCrashlytics.instance
    //     .setUserIdentifier(sl.get<DeviceInfoConfig>().deviceData.toString());
    FirebaseCrashlytics.instance.setUserIdentifier(
        '${sl.get<DeviceInfoConfig>().deviceData[Platform.isIOS ? 'systemName' : 'device']} *** user ${(await sl.get<AuthProvider>().getUser())?.username ?? ''}');

    FlutterError.onError = (errorDetails) {
      if (fatalError) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        // ignore: dead_code
      } else {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      }
    };
    // Async exceptions
    PlatformDispatcher.instance.onError = (error, stack) {
      if (fatalError) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        // ignore: dead_code
      } else {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
      return true;
    };
    //outside of runApp
    // Isolate.current.addErrorListener(RawReceivePort((pair) async {
    //   final List<dynamic> errorAndStacktrace = pair;
    //   await FirebaseCrashlytics.instance.recordError(
    //     errorAndStacktrace.first,
    //     errorAndStacktrace.last,
    //     fatal: true,
    //   );
    // }).sendPort);
  } catch (e) {
    errorLog('FirebaseCrashlytics.instance : $e', 'main');
  }
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   errorLog("FlutterError.onError : ${details.exception}");
  //   try {
  //     // Navigator.pushAndRemoveUntil(
  //     //     MyCarClub.navigatorKey.currentContext!,
  //     //     MaterialPageRoute(builder: (context) => MainPage()),
  //     //     (route) => false);
  //   } catch (e) {
  //     errorLog(e.toString());
  //   }
  // };
  // setErrorBuilder();
}
