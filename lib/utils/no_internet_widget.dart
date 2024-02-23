import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget(
      {super.key, this.bgColor, this.textColor, this.callback, this.btnText});
  final Color? bgColor;
  final Color? textColor;
  final String? btnText;
  final void Function()? callback;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/90478-disconnect.zip',
                width: Get.width * 0.7),
          ],
        ),
        titleLargeText('Ooops!', context, fontSize: 32, color: textColor),
        bodyLargeText('No Internet Connection found', context,
            color: textColor),
        bodyLargeText('Check your connection', context, color: textColor),
        height10(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.3),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: callback ?? () => Get.back(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: bodyLargeText(btnText ?? 'Go Back!', context,
                          textAlign: TextAlign.center),
                    )),
              ),
            ],
          ),
        )
      ],
    );
  }
}
