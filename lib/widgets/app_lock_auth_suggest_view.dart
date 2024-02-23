import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/database/repositories/settings_repo.dart';
import '/sl_container.dart';
import '/utils/app_lock_authentication.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/assets_constants.dart';

class AppLockAuthSuggestionWidget extends StatefulWidget {
  AppLockAuthSuggestionWidget(
      {super.key,
      required this.showSuggestion,
      this.textColor = Colors.white,
      this.margin,
      this.backgroundColor});
  final bool showSuggestion;
  final Color textColor;
  final EdgeInsetsDirectional? margin;
  final Color? backgroundColor;

  @override
  State<AppLockAuthSuggestionWidget> createState() =>
      _AppLockAuthSuggestionWidgetState();
}

class _AppLockAuthSuggestionWidgetState
    extends State<AppLockAuthSuggestionWidget> {
  final sharedPref = SharedPreferences.getInstance();

  bool canTryNow = false;

  bool canLater = false;

  bool dontShowAgain = false;

  bool bioMetricAvailable = false;

  setCanTryNow(bool value) async => await sharedPref.then((sharedPreferences) {
        warningLog('setCanTryNow $value', 'AppLockAuthSuggestionWidget',
            'setCanTryNow');
        if (value) {
          var dt = DateTime.now();
          var dt2 = dt.add(Duration(minutes: 1));
          sharedPreferences.setString('canTryNow', dt2.toString());
        }
        canTryNow = false;
      });

  setCanLater(bool value) async =>
      await sharedPref.then((sharedPreferences) async =>
          await sharedPreferences.setBool('canLater', value));

  setDontShowAgain(bool value) async =>
      await sharedPref.then((sharedPreferences) async =>
          await sharedPreferences.setBool('dontShowAgain', value));

  getCanTryNow() async =>
      await sharedPref.then((sharedPreferences) => setState(() {
            var dt = DateTime.now();
            var res = sharedPreferences.getString('canTryNow');
            if (res != null) {
              var dt2 = DateTime.parse(res);
              if (dt2.isBefore(dt)) {
                canTryNow = true;
              } else {
                canTryNow = false;
              }
            } else {
              canTryNow = true;
            }
          }));
  getCanLater() async => await sharedPref.then((sharedPreferences) => setState(
      () => canLater = sharedPreferences.getBool('canLater') ?? false));
  getDontShowAgain() async =>
      await sharedPref.then((sharedPreferences) => setState(() =>
          dontShowAgain = sharedPreferences.getBool('dontShowAgain') ?? false));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.showSuggestion) {
        setDontShowAgain(false);
      }
      getCanTryNow();
      getCanLater();
      getDontShowAgain();
      AppLockAuthentication.checkBiometrics().then((value) {
        setState(() => bioMetricAvailable = value == AuthStatus.available);
      });
      infoLog(
          'bioMetricAvailable = $bioMetricAvailable  canTryNow = $canTryNow canLater = $canLater  dontShowAgain = $dontShowAgain',
          'AppLockAuthSuggestionWidget',
          'initState');
    });
  }

  tryNow() {
    AppLockAuthentication.authenticate().then((value) {
      if (value[0] == AuthStatus.available) {
        if (value[1] == AuthStatus.success) {
          setCanTryNow(false);
          setCanLater(false);
          setDontShowAgain(true);
          sl.get<SettingsRepo>().setBiometric(true);
        }
      } else if (value[1] == AuthStatus.notDetermined ||
          value[1] == AuthStatus.failed) {
        setCanTryNow(true);
        setCanLater(true);
        setDontShowAgain(false);
      } else if (value[1] == AuthStatus.notAvailable) {
        setCanTryNow(false);
        setCanLater(true);
        setDontShowAgain(false);
      }
    });
    getCanTryNow();
    getCanLater();
    getDontShowAgain();
    setState(() {});
  }

  later() {
    setCanTryNow(true);
    setCanLater(true);
    setDontShowAgain(false);
    getCanTryNow();
    getCanLater();
    getDontShowAgain();
    setState(() {});
  }

  notShowAgain() {
    setCanTryNow(true);
    setCanLater(true);
    setDontShowAgain(true);
    getCanTryNow();
    getCanLater();
    getDontShowAgain();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    infoLog(
        'widget.showSuggestion = ${widget.showSuggestion} bioMetricAvailable = $bioMetricAvailable  canTryNow = $canTryNow canLater = $canLater  dontShowAgain = $dontShowAgain',
        'AppLockAuthSuggestionWidget',
        'initState');
    return !widget.showSuggestion || dontShowAgain || !bioMetricAvailable
        ? Container()
        : canTryNow
            ? buildView()
            : Container();
  }

  Container buildView() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.backgroundColor),
      margin: widget.margin,
      child: Column(
        children: [
          Row(
            children: [
              assetImages(Assets.appLogo_S, width: 30),
              width10(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Lock',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor),
                  ),
                  Text(
                    'Secure your app with app lock',
                    style: TextStyle(fontSize: 12, color: widget.textColor),
                  ),
                ],
              ),
            ],
          ),
          height10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _commonButtonWidget(
                  text: 'Try Now', onPressed: tryNow, color: appLogoColor),
              _commonButtonWidget(
                  text: 'Later', onPressed: later, color: Colors.grey),
              _commonButtonWidget(
                  text: 'Don\'t show again',
                  onPressed: notShowAgain,
                  color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  // create common button widget to use for try now, later, and don't show again
  Widget _commonButtonWidget(
      {required String text,
      required VoidCallback onPressed,
      required Color color}) {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(text),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          side: BorderSide(color: Colors.transparent),
          foregroundColor: color,
        ),
      ),
    );
  }
}
