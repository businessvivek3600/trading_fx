import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/screens/dashboard/main_page.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';

dashboardDialog({required String image, required BuildContext context}) {
  print(image);
  showDialog<void>(
    context: context,
    // barrierColor: Colors.black.withOpacity(0.4),
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (BuildContext dialogContext) {
      return ImageDialog(image);
    },
  );
}

class ImageDialog extends StatelessWidget {
  final String imageUrl;

  ImageDialog(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).pop();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: buildCachedNetworkImage(imageUrl,
                      fit: BoxFit.contain,
                      ph: Get.height / 2,
                      pw: Get.width * 0.9,
                      errorBgColor: Colors.white),
                ),
              ),
              height10(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      canShowNextDashPopUPBool.value = false;
                      Navigator.pop(Get.context!);
                    },
                    child: Icon(CupertinoIcons.clear_circled_solid,
                        color: Colors.white, size: Get.width * 0.13),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
