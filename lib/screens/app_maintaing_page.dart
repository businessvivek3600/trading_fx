import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/database/functions.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

class AppUnderMaintenancePage extends StatefulWidget {
  const AppUnderMaintenancePage({Key? key}) : super(key: key);
  static const String routeName = '/UpdateAppPage';
  @override
  State<AppUnderMaintenancePage> createState() =>
      _AppUnderMaintenancePageState();
}

class _AppUnderMaintenancePageState extends State<AppUnderMaintenancePage> {
  @override
  Widget build(BuildContext context) {
    Color? textColor = null;
    return Scaffold(
      backgroundColor: mainColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            height20(kToolbarHeight),
            Expanded(
              child: Stack(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Lottie.asset(
                                'assets/lottie/38319-shining-stars.zip'),
                            Lottie.asset(
                                'assets/lottie/38319-shining-stars.zip'),
                            Lottie.asset(
                                'assets/lottie/38319-shining-stars.zip'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    top: 0,
                    right: 0,
                    left: 0,
                    child: assetImages('ios_mobile.png'),
                  )
                ],
              ),
            ),
            // Spacer(),
            Column(
              children: [
                titleLargeText(
                    'We apologize for the inconvenience, but our app is currently disabled for maintenance. We are working diligently to improve your experience and bring you exciting updates.',
                    context,
                    color: Colors.white70,
                    maxLines: 10,
                    textAlign: TextAlign.left),
                height10(),
                capText(
                    'Thank you for your patience and understanding.Stay tuned for our upcoming enhancements and new features.',
                    context,
                    color: Colors.white54,
                    textAlign: TextAlign.center,
                    lineHeight: 1.2,
                ),
              ],
            ),
            // Spacer(),
            // Row(
            //   children: [
            //     Expanded(
            //         child: ElevatedButton(
            //             style: ElevatedButton.styleFrom(
            //                 shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(5))),
            //             onPressed: () => launchTheLink(
            //                 'https://play.google.com/store/apps/details?id=${AppConstants.appPlayStoreId}'),
            //             child: Text('Update Now')))
            //   ],
            // ),
            height10(),
            Row(
              children: [
                Expanded(
                    child: TextButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: appLogoColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () => exitTheApp(),
                        child:
                            bodyLargeText('Exit', context, color: textColor)))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
