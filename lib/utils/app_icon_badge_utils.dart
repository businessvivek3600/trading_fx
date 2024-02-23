import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import '/utils/default_logger.dart';

Future<bool?> initPlatformState() async {
  String? appBadgeSupported;
  bool res = false;
  try {
    res = await FlutterAppBadger.isAppBadgeSupported();
    if (res) {
      appBadgeSupported = 'Supported';
    } else {
      appBadgeSupported = 'Not supported';
    }
  } on PlatformException {
    appBadgeSupported = 'Failed to get badge support.';
  }
  infoLog(appBadgeSupported,'FlutterAppBadger.isAppBadgeSupported');
  return res;
}
