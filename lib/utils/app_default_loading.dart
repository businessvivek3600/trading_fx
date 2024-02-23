import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/utils/picture_utils.dart';

showLoading(
    {BuildContext? context,
    bool? useRootNavigator,
    bool dismissable = false,
    double width = 150}) async {
  showDialog(
    context: context ?? Get.context!,
    useRootNavigator: useRootNavigator ?? true,
    barrierDismissible: dismissable,
    builder: (context) => _DefaultLoadingWidget(width: width),
  );
}

class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget({super.key, required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(
          horizontal: Get.width * 0.2, vertical: Get.height * 0.3),
      child: Center(
          child: Container(
              // color: redDark,
              width: width,
              height: width,
              child: Stack(
                children: [
                  assetLottie(Assets.loading_mwc),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Center(
                          child: assetImages(Assets.appLogo_S,
                              width: width * 0.2))),
                ],
              ))),
    );
  }
}

hideLoading({required BuildContext context}) {
  Navigator.of(context).pop();
}

appDefaultPlainLoading({double? height, double? width}) => Container(
    color: Colors.transparent,
    height: height ?? Get.width * 0.5,
    width: width ?? Get.height * 0.5,
    child: Center(child: assetRive(Assets.appDefaultLoading)));

appLoadingDots({double? height, double? width}) => Container(
    color: Colors.transparent,
    height: height ?? Get.width * 0.3,
    width: width ?? Get.height * 0.3,
    child: Center(child: assetRive(Assets.loadingDots)));
