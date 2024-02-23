import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '/utils/app_lock_authentication.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/repositories/settings_repo.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/utils/toasts.dart';
import '/widgets/app_rating_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var repo = sl.get<SettingsRepo>();
  bool biometric = false;
  bool newFeatureNotification = false;
  bool settingNewFeatureNotification = false;
  @override
  void initState() {
    setState(() {
      biometric = repo.getBiometric();
      newFeatureNotification = repo.getNewFeaturesValue;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('new feature loading $newFeatureNotification');
    // List<Route<dynamic>> history = NavigatorState..history;

    // Print the list of route names in the history
    // history.forEach((route) {
    print('Route name: ${Navigator.of(context).context}');
    // });
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(title: titleLargeText('App Settings', context)),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: userAppBgImageProvider(context),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(10),
          physics: const BouncingScrollPhysics(),
          children: [
            // buildAppLockTile(context),
            // height10(),
            // buildNewFeatureTile(context),
            // height5(),
            // const Divider(color: Colors.white10),
            // height5(),
            bodyLargeText('Account', context, color: Colors.white),
            height10(),
            ListTile(
              onTap: () => AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      title: 'Delete Account',
                      desc:
                          'Your account will be permanently deleted and your data could not be restored.\nDo you really want to delete your account?',
                      titleTextStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      btnCancelText: 'Cancel',
                      btnCancelOnPress: () {},
                      btnCancelColor: Colors.grey,
                      btnCancelIcon: Icons.cancel,
                      btnOkText: 'Delete',
                      btnOkColor: Colors.red,
                      btnOkIcon: Icons.delete_rounded,
                      // isDense: true,
                      reverseBtnOrder: true,
                      btnOkOnPress: deleteAccount)
                  .show(),
              tileColor: Colors.white10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Row(
                children: [
                  assetSvg(Assets.delete, color: Colors.white),
                  width20(),
                  Expanded(
                      child: bodyLargeText('Delete Account', context,
                          color: Colors.red))
                ],
              ),
              // trailing: assetSvg(Assets.arrowForwardIos,
              //     color: Colors.white, width: 13),
            ),
            height50(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () => rateApp(),
                    child: titleLargeText('Rate Us', context,
                        decoration: TextDecoration.underline,
                        color: CupertinoColors.link)),
              ],
            ),
            height10(),
          ],
        ),
      ),
    );
  }

  CheckboxListTile buildNewFeatureTile(BuildContext context) {
    return CheckboxListTile(
      value: newFeatureNotification,
      enabled: !settingNewFeatureNotification,
      tileColor:
          !settingNewFeatureNotification ? Colors.white10 : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      checkColor: appLogoColor,
      activeColor: Colors.white,
      title: Row(
        children: [
          assetSvg(Assets.notification, color: Colors.white),
          width20(),
          Expanded(
            child: bodyLargeText('Get notifications for new features ', context,
                color: Colors.white),
          ),
        ],
      ),
      onChanged: (val) {
        if (!settingNewFeatureNotification) setNewFeatureNotification(val!);
      },
      side: const BorderSide(color: Colors.white),
    );
  }

  SwitchListTile buildAppLockTile(BuildContext context) {
    return SwitchListTile(
      value: biometric,
      tileColor: Colors.white12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      activeTrackColor: Colors.grey,
      activeColor: Colors.white,
      title: Row(
        children: [
          assetSvg(Assets.lock, color: Colors.white),
          width20(),
          bodyLargeText('App Lock', context, color: Colors.white),
        ],
      ),
      onChanged: (val) => setAppLock(),
    );
  }

  void setNewFeatureNotification(bool val) async {
    setState(() {
      settingNewFeatureNotification = true;
    });
    if (isOnline) {
      if (!val) {
        await repo.disableNewFeatures();
      } else {
        await repo.enableNewFeatures();
      }
    } else {
      Fluttertoast.showToast(msg: 'No internet connection');
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      settingNewFeatureNotification = false;
      newFeatureNotification = repo.getNewFeaturesValue;
    });
  }

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  void setAppLock() async {
    AppLockAuthentication.authenticate().then((value) {
      if (value[0] == AuthStatus.available) {
        if (value[1] == AuthStatus.success) {
          setState(() {
            biometric = !biometric;
            repo.setBiometric(biometric);
          });
        }
      }
    });
  }

  void deleteAccount() async {
    AppLockAuthentication.authenticate().then((value) async {
      if (value[0] == AuthStatus.available) {
        if (value[1] == AuthStatus.success) {
          showLoading();
          await Future.delayed(const Duration(seconds: 3));
          Get.back();
          logOut('deleteAccount').then((value) =>
              Toasts.showSuccessNormalToast('Your account has been deleted'));
        }
      } else {
        showLoading();
        await Future.delayed(const Duration(seconds: 3));
        Get.back();
        logOut('deleteAccount').then((value) =>
            Toasts.showSuccessNormalToast('Your account has been deleted'));
      }
    });
  }
}
