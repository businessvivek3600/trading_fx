import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';

import 'default_logger.dart';

enum AuthStatus {
  notDetermined,
  notAvailable,
  available,
  success,
  failed,
  canceled,
  error
}

class AppLockAuthentication {
  static final AppLockAuthentication _instance = AppLockAuthentication._();
  AppLockAuthentication._();
  factory AppLockAuthentication() => _instance;
  static AppLockAuthentication get instance => _instance;
  static const String tag = 'AppLockAuthentication';
  static final LocalAuthentication auth = LocalAuthentication();

  static Future<List<AuthStatus>> authenticate() async {
    var canCheckBiometrics = await checkBiometrics();
    if (canCheckBiometrics == AuthStatus.available) {
      var authStatus = await authenticateWithBiometrics();

      infoLog('authenticate: authStatus: $authStatus', tag);
      return [canCheckBiometrics, authStatus];
    } else {
      return [canCheckBiometrics, AuthStatus.notAvailable];
    }
  }

  static Future<AuthStatus> checkBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.isDeviceSupported();

      return canCheckBiometrics
          ? AuthStatus.available
          : AuthStatus.notAvailable;
    } on PlatformException catch (e) {
      errorLog(
          'PlatformException: ${e.message} s ${e}', tag, '_checkBiometrics');
      if (e.code == 'NotAvailable') {
        Fluttertoast.showToast(msg: 'Biometric not available');
        return AuthStatus.notAvailable;
      } else if (e.code == 'NotEnrolled') {
        Fluttertoast.showToast(msg: 'Biometric not enrolled');
        return AuthStatus.notAvailable;
      } else if (e.code == 'PasscodeNotSet') {
        Fluttertoast.showToast(msg: 'Passcode not set');
        return AuthStatus.notDetermined;
      } else if (e.code == 'OtherOperatingSystem') {
        Fluttertoast.showToast(msg: 'Other operating system');
        return AuthStatus.notAvailable;
      } else if (e.code == 'LockedOut') {
        Fluttertoast.showToast(msg: 'Locked out');
        return AuthStatus.notAvailable;
      } else if (e.code == 'PermanentlyLockedOut') {
        Fluttertoast.showToast(msg: 'Permanently locked out');
        return AuthStatus.failed;
      } else if (e.code == 'Other') {
        Fluttertoast.showToast(msg: 'Unknown error');
        return AuthStatus.error;
      }
      return AuthStatus.error;
    }
  }

  static Future<AuthStatus> authenticateWithBiometrics() async {
    AuthStatus status = AuthStatus.notDetermined;
    try {
      bool authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        // options:
        //     const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      infoLog(
          '_authenticateWithBiometrics: authenticated ? $authenticated', tag);
      // return AuthStatus.success;
      return authenticated ? AuthStatus.success : AuthStatus.failed;
    } on PlatformException catch (e) {
      errorLog('PlatformException: ${e.message} ${e.code} ${e}', tag,
          '_authenticateWithBiometrics');
      // await authenticateWithBiometrics();
      if (e.code == 'auth_in_progress') {
        await authenticateWithBiometrics();
      } else if (e.code == 'NotAvailable') {
        Fluttertoast.showToast(msg: 'Biometric not available');
        return AuthStatus.notAvailable;
      } else if (e.code == 'NotEnrolled') {
        Fluttertoast.showToast(msg: 'Biometric not enrolled');
        return AuthStatus.notAvailable;
      } else if (e.code == 'PasscodeNotSet') {
        Fluttertoast.showToast(msg: 'Passcode not set');
        return AuthStatus.notDetermined;
      } else if (e.code == 'OtherOperatingSystem') {
        Fluttertoast.showToast(msg: 'Other operating system');
        return AuthStatus.notAvailable;
      } else if (e.code == 'LockedOut') {
        Fluttertoast.showToast(msg: 'Locked out');
        return AuthStatus.notAvailable;
      } else if (e.code == 'PermanentlyLockedOut') {
        Fluttertoast.showToast(msg: 'Permanently locked out');
        return AuthStatus.failed;
      } else if (e.code == 'Other') {
        Fluttertoast.showToast(msg: 'Biometric failed');
        return AuthStatus.error;
      }
      return AuthStatus.error;
    }
  }
}
