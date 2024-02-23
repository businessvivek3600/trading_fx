import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:flutter_upgrade_version/models/app_update_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '/utils/my_logger.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/database/repositories/settings_repo.dart';
import '/utils/color.dart';
import '/database/model/response/base/user_model.dart';
import '/database/model/response/company_info_model.dart';
import '/database/repositories/auth_repo.dart';
import '/myapp.dart';
import '/providers/Cash_wallet_provider.dart';
import '/providers/GalleryProvider.dart';
import '/providers/auth_provider.dart';
import '/providers/commission_wallet_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/event_tickets_provider.dart';
import '/providers/subscription_provider.dart';
import '/providers/team_view_provider.dart';
import '/providers/voucher_provider.dart';
import '/screens/auth/login_screen.dart';
import '/sl_container.dart';
import '/utils/check_app_update.dart';
import '/utils/toasts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:power_file_view/power_file_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:html/parser.dart';

import '../constants/app_constants.dart';
import '../providers/support_provider.dart';
import '../utils/default_logger.dart';
import 'app_update/src/upgrader.dart';

bool isOnline = false;
String appVersion = '';

String pPTDownloadFilePath = '';

void launchPlayStore() async {
  const playStoreUrl =
      "https://play.google.com/store/apps/details?id=${AppConstants.packageID}";

  if (await canLaunch(playStoreUrl)) {
    await launch(playStoreUrl);
  } else {
    throw 'Could not launch Play Store';
  }
}

void launchAppStore() async {
  const appStoreUrl =
      // "https://itunes.apple.com/app/your-app-name/id${AppConstants.appAppleStoreId}?mt=8";
      "https://apps.apple.com/in/app/my-wealth-club/id${AppConstants.appAppleStoreId}";

  if (await canLaunch(appStoreUrl)) {
    await launch(appStoreUrl);
  } else {
    throw 'Could not launch App Store';
  }
}

Future<void> sendWhatsapp({String? number, String? text}) async {
  var whatsappUrl =
      "https://api.whatsapp.com/send?${text != null ? '&text=$text' : ''}";
  await canLaunchUrl(Uri.parse(whatsappUrl))
      ? launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication)
      : print(
          "open WhatsApp app link or do a snack-bar with notification that there is no WhatsApp installed");
}

Future<void> sendTelegram({String? text}) async {
  var telegramUrl = "https://telegram.me/share/url?url=<$text>";
  await canLaunchUrl(Uri.parse(telegramUrl))
      ? launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication)
      : print(
          "open WhatsApp app link or do a snack-bar with notification that there is no Telegram installed");
}

Future<void> launchTheLink(String text) async {
  await canLaunchUrl(Uri.parse(text))
      ? launchUrl(Uri.parse(text), mode: LaunchMode.externalApplication)
      : () {
          Toasts.showErrorNormalToast('Some thing went wrong!');
        };
}

Future<String?> downloadAndSaveFile(String url, String filename) async {
  final ext = url.split('.').last;
  final _directory = await getTemporaryDirectory();
  final downloadFilePath = "${_directory.path}/fileview/$filename.$ext";
  try {
    var response = await Dio().download(url, downloadFilePath,
        onReceiveProgress: (received, total) {
      if (total != -1) {
        print("${(received / total * 100).toStringAsFixed(0)}%");
      }
    });
    print("File is saved to $downloadFilePath");
  } on DioException catch (e) {
    print('File download failed ${e.message}');
  }
  return downloadFilePath;
}

Future<void> getPPTDownloadFilePath(String filename) async {
  final _directory = await getTemporaryDirectory();
  pPTDownloadFilePath = "${_directory.path}/fileview/$filename.pdf";
}

Future<void> configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

Future<String?> getDeviceToken({String? username}) async {
  String? _deviceToken;
  _deviceToken = await FirebaseMessaging.instance.getToken();
  // await FirebaseFirestore.instance
  //     .collection('mycarclub')
  //     .doc('tokens')
  //     .collection('allusers')
  //     .doc((username ?? 'unknown ${DateTime.now()}').trim().toLowerCase())
  //     .set({'username': username, 'fcm_token': _deviceToken});
  // if (Platform.isIOS) {
  //   _deviceToken = await FirebaseMessaging.instance.getAPNSToken();
  // } else {
  // }
  warningLog('--------Device Token---------- $_deviceToken');

  return _deviceToken;
}

Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

exitTheApp() async {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else if (Platform.isIOS) {
    exit(0);
  } else {
    print('App exit failed!');
  }
}

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString =
      parse(document.body?.text).documentElement?.text ?? '';

  return parsedString;
}

Future<void> logOut(
  dynamic reason, {
  bool showD = true,
  title = 'Session expired',
  content = 'Your session has expired.\nPlease wait..',
}) async {
  warningLog('logOut called  due to ${reason.toString()}');
  // show loding dialog for sesion expire
  if (showD) {
    showDialog(
        context: MyApp.navigatorKey.currentContext!,
        barrierDismissible: true,
        barrierColor: Colors.white.withOpacity(0.1),
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            backgroundColor: bColor(1),
            title: titleLargeText(
              title,
              context,
              useGradient: true,
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                bodyLargeText(
                  content,
                  context,
                  useGradient: false,
                  color: Colors.white70,
                  textAlign: TextAlign.center,
                ),
                height20(),
                SizedBox.fromSize(
                    size: const Size.square(70),
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.white))),
              ],
            ),
          );
        });
  }
  await Future.delayed(Duration(milliseconds: showD ? 2000 : 0), () async {
    await sl.get<AuthProvider>().clearSharedData();
    await sl.get<AuthProvider>().clear();
    sl.get<AuthProvider>().userData = UserData();
    await sl.get<CashWalletProvider>().clear();
    await sl.get<VoucherProvider>().clear();
    await sl.get<EventTicketsProvider>().clear();
    await sl.get<CommissionWalletProvider>().clear();
    await sl.get<DashBoardProvider>().clear();
    await sl.get<SubscriptionProvider>().clear();
    await sl.get<SupportProvider>().clear();
    await sl.get<TeamViewProvider>().clear();
    await sl.get<GalleryProvider>().clear();
    await APICacheManager().emptyCache();
    sl.get<SettingsRepo>().setBiometric(false);
  }).then((value) {
    Navigator.pop(MyApp.navigatorKey.currentContext!);
  });

  MyApp.navigatorKey.currentState
      ?.pushNamedAndRemoveUntil(LoginScreen.routeName, (r) => false);
}

Stream<bool> checkFBForAppUpdate() async* {
  var hasUpdate = sl.get<AuthRepo>().getAppCanUpdate();
  var canRunApp = sl.get<AuthRepo>().getCanRunApp();
  var dp = sl.get<DashBoardProvider>();
  await checkVersion().then((value) async {
    /*  var versionKey = (Platform.isIOS? AppConstants.testMode    ? AppConstants.testIosVersionKey    : AppConstants.iosVersionKey: AppConstants.testMode    ? AppConstants.testAndroidVersionKey    : AppConstants.androidVersionKey);*/
    // if (isOnline) {
    // FirebaseFirestore firestore = FirebaseFirestore.instance;
    //can run
/*      var runKey =  AppConstants.testMode ? AppConstants.testCanRun : AppConstants.canRun;
      await firestore  .collection('mycarclub')  .doc('runApp')  .snapshots()  .listen((event) {if (event.data() != null) {  if ((event.data())!.entries.isNotEmpty) {    canRunApp = (event.data())!        .entries        .firstWhere((element) => element.key == runKey)        .value;  }}
      });*/

/*    await firestore.collection('mycarclub').doc('version').snapshots().listen((event) {
      if (event.data() != null) {if ((event.data())!.entries.isNotEmpty) {  var versionValue = (event.data())!      .entries      .firstWhere((element) => element.key == versionKey)      .value;  print(      'compare in old app-version is $appVersion  and new-version is $versionValue  ,  version key is $versionKey    result is ${(versionValue.toString().compareTo(appVersion))}');  hasUpdate = versionValue.toString().compareTo(appVersion) == 1;}
      }
    });*/
    // }
  });

  /// set value on api data basis
  //has update
  // if (dp.companyInfo != null) {
  //   String versionValue = (Platform.isIOS
  //       ? AppConstants.testMode
  //           ? dp.companyInfo!.test_ios ?? ''
  //           : dp.companyInfo!.ios_version ?? ''
  //       : AppConstants.testMode
  //           ? dp.companyInfo!.test_android ?? ''
  //           : dp.companyInfo!.android_version ?? '');
  //   if (versionValue != '') {
  //     hasUpdate = versionValue.toString().compareTo(appVersion) == 1;
  //   }
  //   print(
  //       'compare in old app-version is $appVersion  and new-version is $versionValue, result is ${(versionValue.toString().compareTo(appVersion))}');
  // }
  // //can run
  // if (sl.get<DashBoardProvider>().companyInfo != null) {
  //   canRunApp =
  //       (sl.get<DashBoardProvider>().companyInfo!.mobileAppDisabled ?? 0)
  //               .toString() ==
  //           '0';
  // }
  // sl.get<AuthRepo>().setCanRunApp(canRunApp);
  // sl.get<AuthRepo>().setAppCanUpdate(hasUpdate);
  // print('app checkFBForAppUpdate has new update === $hasUpdate');
  // print('app checkFBForAppUpdate can run === $canRunApp');
  yield hasUpdate;
}

final _checker = AppVersionChecker();
Future<bool> checkVersion() async {
  bool canUpdate = false;
  try {
    // if (isOnline) {
    /*checkAppUpdate(  context,  appName: '${AppConstants.appName}',  iosAppId: '123456789',  androidAppBundleId: AppConstants.appPlayStoreId,  isDismissible: true,  customDialog: true,  customAndroidDialog: AlertDialog(    title: const Text('Update Available'),    content: const Text('Please update the app to continue'),    actions: [      TextButton(        onPressed: () {          Navigator.pop(context);        },        child: const Text('Cancel'),      ),      TextButton(        onPressed: () {          OpenStore.instance.open(            androidAppBundleId: AppConstants.appPlayStoreId,          );          Navigator.pop(context);        },        child: const Text('Update'),      ),    ],  ),  customIOSDialog: CupertinoAlertDialog(    title: const Text('Update Available'),    content: const Text('Please update the app to continue'),    actions: [      CupertinoDialogAction(        onPressed: () {          Navigator.pop(context);        },        child: const Text('Cancel'),      ),      CupertinoDialogAction(        onPressed: () {          OpenStore.instance.open(            appName: '${AppConstants.appName}',            appStoreId: '123456789',          );          Navigator.pop(context);        },        child: const Text('Update'),      ),    ],  ),);
*/
    await _checker.checkUpdate().then((value) {
      appVersion = value.currentVersion;
      print(value.currentVersion); //return current app version
      print(value.newVersion); //return the new app version
      print(value.appURL); //return the app url
      print(value.errorMessage);
      print('***************** checkUpdate  completed *******************');
    });
    // }else{
    //   appVersion = value.currentVersion;
    // }
  } catch (e) {
    print('***************** checkUpdate failed $e *******************');
  }
  return canUpdate;
}

/// Find [Time Difference] in between today and the given date-time
String getTimeDifference(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    final years = difference.inDays ~/ 365;
    return '$years year${years > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 30) {
    final months = difference.inDays ~/ 30;
    return '$months month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 7) {
    final weeks = difference.inDays ~/ 7;
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 1) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return 'Yesterday';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else if (difference.inSeconds > 0) {
    return '${difference.inSeconds} second${difference.inSeconds > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}

String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    // If the date matches today, return the time in "jm" format
    return formatDate(dateTime, "jm");
  } else if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day - 1) {
    // If the date matches yesterday, return "Yesterday"
    return "Yesterday";
  } else {
    // For other dates, return the date in "dd/MM/yyyy" format
    return formatDate(dateTime, "dd/MM/yyyy");
  }
}

String formatDate(DateTime dateTime, String format) {
  // Use intl package for date formatting
  final formatter = DateFormat(format);
  return formatter.format(dateTime);
}

Future<bool> setupAppRating(int hours) async {
  bool showRating = false;
  var dt = DateTime.now();
  var prefs = await SharedPreferences.getInstance();
  String? scheduledDate = prefs.getString(SPConstants.ratingScheduleDate);
  if (scheduledDate == null) {
    showRating = false;
    await prefs.setString(SPConstants.ratingScheduleDate,
        dt.add(Duration(hours: hours)).toIso8601String());
    print(
        'user was not scheduled to rate  ${scheduledDate} show rating $showRating');
  } else if (DateTime.parse(scheduledDate).isBefore(dt)) {
    showRating = true;
    await prefs.setString(SPConstants.ratingScheduleDate,
        dt.add(Duration(hours: hours)).toIso8601String());
    print(
        'user is now mature to rate the app ${scheduledDate} show rating $showRating');
  } else {
    showRating = false;
    print(
        'user is not mature to rate the app ${scheduledDate} show rating $showRating');
  }
  return showRating;
}

void checkServiceEnableORDisable(String serviceKey, VoidCallback callback) {
  CompanyInfoModel? company = sl.get<DashBoardProvider>().companyInfo;
  bool perForm = false;
  String? alert;
  String? key;
  blackLog('checkServiceEnableORDisable key: $serviceKey');
  if (company != null) {
    key = serviceKey;
    switch (serviceKey) {
      // case 'mobile_is_subscription':
      //   perForm = company.mobileIsSubscription != null &&
      //       company.mobileIsSubscription == "1";
      //   alert = "Subscription is temporary disabled.";
      //   break;
      // case 'mobile_is_cash_wallet':
      //   perForm = company.mobileIsCashWallet != null &&
      //       company.mobileIsCashWallet == "1";
      //   alert = "Cash wallet is temporary disabled.";
      //   break;
      // case 'mobile_is_commission_wallet':
      //   perForm = company.mobileIsCommissionWallet != null &&
      //       company.mobileIsCommissionWallet == "1";
      //   alert = "Commission wallet is temporary disabled.";
      //   break;
      // case 'is_buy_pack':
      //   perForm =
      //       company.mobileIsVoucher != null && company.mobileIsVoucher == "1";
      //   alert = "Vouchers are temporary disabled.";
      //   break;
      // case 'mobile_is_event':
      //   perForm = company.mobileIsEvent != null && company.mobileIsEvent == "1";
      //   alert = "Events are temporary disabled.";
      //   break;
      // case 'mobile_chat_disabled':
      //   perForm = company.mobileChatDisabled != null &&
      //       company.mobileChatDisabled != "0";
      //   alert = "New Chat is temporary disabled.";
      //   break;
      // default:
      //   perForm = true;
      //   alert = 'Service is temporary disabled.';
      //   break;
      default:
        perForm = true;
        break;
    }
  }
  warningLog(
      'checkServiceEnableORDisable key: $key perform: $perForm alert: $alert',
      'checkServiceEnableORDisable');
  if (!perForm) {
    Fluttertoast.showToast(msg: alert ?? '');
    return;
  }
  callback();
}

String createDeepLink({String? sponsor, String? placement}) {
  Uri url = Uri.parse(
      'https://4owag.app.link/signup/?${sponsor != null ? 'sponsor=$sponsor' : ''}${placement != null ? '&' : ''}${placement != null ? 'placement=$placement' : ''}');
  var msg =
      'Hi 👋 ,\nStarting your ${AppConstants.appName} membership can be a fun and exciting endeavour.\ntradingfx.live is a tight-knit community of car enthusiasts who come together to share their love for anything on wheels.\nYou get to meet gearheads, wizards, experts, professionals, and fans of the automotive industry.\n\n Click the below link to join \n${(url.toString())}';
  return msg;
}

// bool isPageInStack(String pageName) {
//   final List<Route> routes = Navigator.of(Get.context!).widget.pages.first.name;
//   for (final Route route in routes) {
//     if (route.settings.name == pageName) {
//       return true;
//     }
//   }
//   return false;
// }

List<T> getFirstFourElements<T>(List<T> list) {
  if (list.length >= 4) {
    return list.sublist(0, 4);
  } else {
    return list;
  }
}

Future<dynamic> future(int ms,
    [FutureOr<dynamic> Function()? computation]) async {
  return await Future.delayed(Duration(milliseconds: ms));
}

void copyToClipboard(String text, [String? message]) {
  Clipboard.setData(ClipboardData(text: text));
  // AdvanceToasts.showNormalElegant(context, 'Link copied successfully!',
  Fluttertoast.showToast(msg: message ?? 'Copied to clipboard');
}

// working update
checkForUpdate(BuildContext context) async {
  Upgrader appcast = Upgrader(
    debugLogging: true,
    showIgnore: false,
    showLater: false,
    debugDisplayAlways: false,
    // shouldPopScope: () => false,
    dialogStyle: Platform.isIOS
        ? UpgradeDialogStyle.cupertino
        : UpgradeDialogStyle.material,
    willDisplayUpgrade: (
        {String? appStoreVersion,
        required bool display,
        String? installedVersion,
        String? minAppVersion}) async {
      print(
          'appcast.willDisplayUpgrade $appStoreVersion $display $installedVersion $minAppVersion');
    },
    backgroundColor: bColor(),
    borderRadius: 10,
    textColor: Platform.isIOS ? Colors.black : Colors.white,
  );
  try {
    await appcast
        .initialize()
        .then((value) => appcast.checkVersion(context: context));
  } catch (e) {
    errorLog('appcast.initialize() error $e');
  }
}

/// update android app
void updateAndroidApp({BuildContext? context}) async {
  // Locale myLocale = Localizations.localeOf(context);
  // print('LOCALE: ${myLocale.languageCode} || ${myLocale.countryCode}');

  InAppUpdateManager manager = InAppUpdateManager();
  var packageInfo = await PackageManager.getPackageInfo();
  log(packageInfo.toJson().toString());
  if (Platform.isAndroid) {
    AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
    log('appupdate info ${appUpdateInfo?.toJson()}');
    if (appUpdateInfo == null) return;

    // appUpdateInfo.updateAvailability =
    //     UpdateAvailability.developerTriggeredUpdateInProgress;
    log('appupdate info ${appUpdateInfo.toJson()}');

    /// Update developerTriggeredUpdateInProgress
    if (appUpdateInfo.updateAvailability ==
        UpdateAvailability.developerTriggeredUpdateInProgress) {
      //If an in-app update is already running, resume the update.

      String? message =
          await manager.startAnUpdate(type: AppUpdateType.flexible);
      log('updateApp developerTriggeredUpdateInProgress => $message');
    }

    /// Update available
    else if (appUpdateInfo.updateAvailability ==
        UpdateAvailability.updateAvailable) {
      ///immediate allowed
      if (appUpdateInfo.immediateAllowed) {
        String? message =
            await manager.startAnUpdate(type: AppUpdateType.immediate);
        log('updateApp immediateAllowed => $message');
      }

      /// flexible allowed
      else if (appUpdateInfo.flexibleAllowed) {
        String? message =
            await manager.startAnUpdate(type: AppUpdateType.flexible);
        log('updateApp flexibleAllowed => $message');
      }

      /// immediate & flexible not allowed
      else {
        log('Update app available. Immediate & Flexible Update Flow not allow ${appUpdateInfo.toJson()}');
      }
    }
    restartAppKey.value = UniqueKey();
    // if (context != null) RestartAppWidget.init(context);
  }
}

//get device info
Future<Map<String, dynamic>> getDeviceInfo() async {
  Map<String, dynamic> deviceInfo = {};
  try {
    if (Platform.isAndroid) {
      var deviceInfoAndroid = await DeviceInfoPlugin().androidInfo;
      deviceInfo = {
        'device': 'android',
        'device_id': deviceInfoAndroid.id,
        'device_name': deviceInfoAndroid.model,
        'device_version': deviceInfoAndroid.version.release,
        'device_brand': deviceInfoAndroid.brand,
        'device_manufacturer': deviceInfoAndroid.manufacturer,
        'device_fingerprint': deviceInfoAndroid.fingerprint,
        'device_bootloader': deviceInfoAndroid.bootloader,
        'device_board': deviceInfoAndroid.board,
        'device_display': deviceInfoAndroid.display,
        'device_hardware': deviceInfoAndroid.hardware,
        'device_host': deviceInfoAndroid.host,
        'device_product': deviceInfoAndroid.product,
        'device_tags': deviceInfoAndroid.tags,
        'device_type': deviceInfoAndroid.type,
        'device_codename': deviceInfoAndroid.version.codename,
        'device_incremental': deviceInfoAndroid.version.incremental,
        'device_sdk': deviceInfoAndroid.version.sdkInt,
        'device_release': deviceInfoAndroid.version.release,
        'device_base_os': deviceInfoAndroid.version.baseOS,
        'device_security_patch': deviceInfoAndroid.version.securityPatch,
        'device_supported_abis': deviceInfoAndroid.supportedAbis,
        'device_supported_32_bit_abis': deviceInfoAndroid.supported32BitAbis,
        'device_supported_64_bit_abis': deviceInfoAndroid.supported64BitAbis,
        'device_system_available_features': deviceInfoAndroid.systemFeatures,
        'device_is_physical_device': deviceInfoAndroid.isPhysicalDevice,
        'device_is_emulator': deviceInfoAndroid.isPhysicalDevice,
        'device_is_maybe_emulator': deviceInfoAndroid.isPhysicalDevice,
        'device_is_maybe_physical_device': deviceInfoAndroid.isPhysicalDevice,
        'device_is_maybe_virtual': deviceInfoAndroid.isPhysicalDevice,
        'device_is_maybe_real_device': deviceInfoAndroid.isPhysicalDevice
      };
    } else if (Platform.isIOS) {
      var deviceInfoIOS = await DeviceInfoPlugin().iosInfo;
      deviceInfo = {
        'device': 'ios',
        'device_id': deviceInfoIOS.identifierForVendor,
        'device_name': deviceInfoIOS.name,
        'device_system_name': deviceInfoIOS.systemName,
        'device_system_version': deviceInfoIOS.systemVersion,
        'device_model': deviceInfoIOS.model,
        'device_localized_model': deviceInfoIOS.localizedModel,
        'device_is_physical_device': deviceInfoIOS.isPhysicalDevice,
        'device_is_simulator': deviceInfoIOS.isPhysicalDevice,
        'device_is_maybe_emulator': deviceInfoIOS.isPhysicalDevice,
        'device_is_maybe_physical_device': deviceInfoIOS.isPhysicalDevice,
        'device_is_maybe_virtual': deviceInfoIOS.isPhysicalDevice,
        'device_is_maybe_real_device': deviceInfoIOS.isPhysicalDevice,
      };
    }
  } catch (e) {
    errorLog('getDeviceInfo error $e');
  }
  logger.t('deviceInfo $deviceInfo');
  return deviceInfo;
}

Future<String> getDeviceName() async {
  var deviceInfo = await getDeviceInfo();
  return '${(deviceInfo['device'] ?? '').toString().capitalize!} (${(deviceInfo['device_name'] ?? '')})';
}

Future<File?> getImageFromContext(BuildContext context) async {
  File? image;
  try {} catch (e) {
    errorLog('getImageFromContext error $e');
  }
  return image;
}

Future<File?> captureAndSave({
  required GlobalKey globalKey,
  String? fileName,
}) async {
  RenderRepaintBoundary boundary =
      globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 1.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List? pngBytes = byteData?.buffer.asUint8List();

  // Save the image or use it as needed
  // Example: save to file
  // File('example.png').writeAsBytes(pngBytes);

  // Example: show the image in a dialog
  if (pngBytes != null) {
    final filePath =
        await createFilePath(fileName: '${fileName ?? 'captured'}.png');
    if (filePath != null) {
      File(filePath).writeAsBytes(pngBytes);
      return File(filePath);
    }
  }
  return null;
}

Future<String?> createFilePath({
  required String fileName,
  String? dirName,
}) async {
  final directory = await getTemporaryDirectory();
  return "${directory.path}/${dirName ?? ''}${dirName != null ? '/' : ''}$fileName";
}
