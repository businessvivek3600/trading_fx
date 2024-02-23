import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';

class Toasts {
  static showSuccessNormalToast(String desc,
      {String? title,
      AnimationType animationType = AnimationType.fromTop}) async {
    CherryToast.success(
            title: Text(title ?? "Success",
                style: const TextStyle(color: Colors.green, fontSize: 12)),
            displayTitle: true,
            displayIcon: true,
            displayCloseButton: false,
            borderRadius: 10,
            description: Text(
              desc,
              style: const TextStyle(color: Colors.black, fontSize: 10)
            ),
            animationType: animationType,
            animationDuration: const Duration(milliseconds: 600),
            autoDismiss: true)
        .show(Get.context!);
  }

  static showErrorNormalToast(String desc, {String? title}) async {

    CherryToast.error(
            title: Text(
              title ?? "Error",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            displayTitle: true,
            displayIcon: true,
            displayCloseButton: false,
            borderRadius: 10,
            description: Text(desc,
                style: const TextStyle(color: Colors.black, fontSize: 10)),
            animationType: AnimationType.fromRight,
            animationDuration: const Duration(milliseconds: 900),
            autoDismiss: true)
        .show(Get.context!);
  }

  static showWarningNormalToast(String desc, {String? title}) async {
    CherryToast.warning(
            title: Text(title ?? "Ooops!",
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.justify),
            displayTitle: true,
            displayIcon: true,
            displayCloseButton: false,
            borderRadius: 10,
            description: Text(desc,
                style: const TextStyle(color: Colors.black, fontSize: 10)),
            animationType: AnimationType.fromRight,
            animationDuration: const Duration(milliseconds: 900),
            autoDismiss: true)
        .show(Get.context!);
  }

  static showNormalToast(String desc,
      {String? title, required bool error}) async {
    print('is error $error');
    CherryToast(
      title: Text(title ?? "Error",
          style: const TextStyle(color: Colors.red, fontSize: 12),
          textAlign: TextAlign.justify),
      displayTitle: true,
      displayIcon: true,
      displayCloseButton: false,
      borderRadius: 10,
      description:
          Text(desc, style: const TextStyle(color: Colors.black, fontSize: 10)),
      animationType: AnimationType.fromRight,
      animationDuration: const Duration(milliseconds: 900),
      autoDismiss: true,
      icon: error ? Icons.error : Icons.emoji_events_outlined,
      themeColor: error ? Colors.red : Colors.green,
    ).show(Get.context!);
  }

  static showFToast(BuildContext context, String text,
      {IconData? icon,
      Color? bgColor,
      bool showIcon = false,
      bool showImage = true}) async {
    FToast fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      toastDuration: const Duration(milliseconds: 2000),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: bgColor ?? appLogoColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon && !showImage)
                  Row(children: [
                    Icon(icon ?? Icons.face, color: Colors.white),
                    width10()
                  ]),
                if (showImage && !showIcon)
                  Row(
                    children: [
                      SizedBox(
                          height: 30,
                          width: 30,
                          child: assetImages(Assets.appLogo_S)),
                      width10(),
                    ],
                  ),
                Text(text,
                    style: const TextStyle(color: Colors.white, fontSize: 16.0))
              ],
            ),
          ),
        ),
      ),
      gravity: ToastGravity.BOTTOM,
    );
  }
}
