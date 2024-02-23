import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mj_image_slider/mj_image_slider.dart';
import 'package:mj_image_slider/mj_options.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/dashboard_alert_model.dart';
import '/myapp.dart';
import '/utils/color.dart';
import '/utils/my_logger.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '../../sl_container.dart';
import '../../utils/app_web_view_page.dart';
import '../../utils/default_logger.dart';
import '../tawk_chat_page.dart';
import 'profile/profile_screen.dart';
import '/providers/dashboard_provider.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class MainPageAlertsSlider extends StatefulWidget {
  const MainPageAlertsSlider({Key? key}) : super(key: key);

  @override
  State<MainPageAlertsSlider> createState() => _MainPageAlertsSliderState();
}

class _MainPageAlertsSliderState extends State<MainPageAlertsSlider> {
  static const String tag = 'MainPageAlertsSlider';
  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, provider, child) {
        return MJImageSlider(
          options: MjOptions(
              onPageChanged: (i) {},
              scrollDirection: Axis.vertical,
              height: 70,
              viewportFraction: 1),
          widgets: [
            ...provider.alerts
                .where((element) => element.status == 1)
                .toList()
                .map(
                  (alert) => Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: capText(alert.info ?? '', context)),
                        width5(),
                        ElevatedButton(
                            onPressed: () => _handleAlertAction(alert, context),
                            child: capText(
                                (alert.action ?? '').capitalize!, context)),
                      ],
                    ),
                  ),
                )
                .toList()
          ],
        );
      },
    );
  }

  _handleAlertAction(DashboardAlert alert, BuildContext context) {
    if (alert.type == 'email_verify') {
      Get.to(const ProfileScreen());
    }
    if (alert.type == 'yoti_sign') {
      _handleYotiSign(alert, context);
    }
  }

  void _handleYotiSign(DashboardAlert alert, BuildContext context) {
    //show failed message
    if (alert.url == null) {
//scaffold messanger with message and a text contact us with rich tex and ontap
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     // shape: RoundedRectangleBorder(
      //     //     borderRadius: BorderRadius.circular(10),
      //     //     side: const BorderSide(color: Colors.red)),
      //     // showCloseIcon: true,
      //     content: RichText(
      //         text: TextSpan(text: 'Document Verification Failed', children: [
      //       TextSpan(
      //           text: 'Contact Us',
      //           style: const TextStyle(
      //               color: Colors.blueAccent,
      //               fontFamily: 'Montserrat',
      //               fontWeight: FontWeight.bold),
      //           recognizer: TapGestureRecognizer()
      //             ..onTap = () => Get.to(TawkChatPage()))
      //     ])),
      //   ));
      //   return;
      // }
      Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: bColor(1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.white),
            width10(),
            RichText(
                text: TextSpan(
                    text: 'Document Verification Failed!\n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                  TextSpan(
                      text: 'Contact Us',
                      style: const TextStyle(
                          color: Colors.blueAccent,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.to(TawkChatPage()))
                ]))
          ],
        ),
      );
      var fToast = FToast()..init(context);
      fToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    Get.to(WebViewExample(
      url: alert.url!,
      showAppBar: '1',
      showToast: '0',
      allowCopy: false,
      conditions: const ['https://mywealthclub.com/verify_document_responce'],
      onResponse: (res) async {
        successLog('request url matched <res> $res', tag);
        Get.back();
        var queryParameters = Uri.parse(res).queryParameters;
        warningLog(
            'queryParameters is $queryParameters  ${queryParameters['success'].runtimeType}',
            tag);
        bool success = queryParameters['success'] == '1';
        if (success) {
          sl<DashBoardProvider>().getCustomerDashboard();
          showDialog(
              context: context,
              builder: (context) => const YotiSignSuccessDialog());
          //show success message
          // AwesomeDialog(
          //   context: context,
          //   dialogType: DialogType.success,
          //   animType: AnimType.bottomSlide,
          //   title: 'Success',
          //   desc: 'Document Verified Successfully',
          //   dismissOnTouchOutside: true,
          //   dismissOnBackKeyPress: true,
          //   // autoHide: const Duration(seconds: 2),
          //   btnOkOnPress: () {
          //     bool? canPop = MyWealthClub.navigatorKey.currentState?.canPop();
          //     logger.e('canPop is $canPop', tag: tag);
          //     if (canPop == true) {
          //       MyWealthClub.navigatorKey.currentState?.pop();
          //     } else {
          //       Get.offAllNamed('/home');
          //     }
          //   },
          // ).show();
        }
      },
    ));
  }
}

class YotiSignSuccessDialog extends StatefulWidget {
  const YotiSignSuccessDialog({Key? key}) : super(key: key);

  @override
  State<YotiSignSuccessDialog> createState() => _YotiSignSuccessDialogState();
}

class _YotiSignSuccessDialogState extends State<YotiSignSuccessDialog> {
  final String tag = 'YotiSignSuccessDialog';
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      bool? canPop = MyApp.navigatorKey.currentState?.canPop();
      logger.e('canPop is $canPop', tag: tag);
      if (canPop == true) {
        MyApp.navigatorKey.currentState?.pop();
      } else {
        Get.offAllNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double animHeight = 70;
    double headerPadding = 10;
    Color headerColor = bColor(1);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(10),
        // color: Colors.redAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: animHeight * 0.5),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: bColor(1),
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              height10(animHeight * 0.5),
                              capText('Success', context),
                              height10(),
                              capText(
                                  'Document Verified Successfully', context),
                              height10(),
                              if (1 == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: FilledButton(
                                          style: FilledButton.styleFrom(
                                              backgroundColor: appLogoColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () {
                                            bool? canPop = MyApp
                                                .navigatorKey.currentState
                                                ?.canPop();
                                            logger.e('canPop is $canPop',
                                                tag: tag);
                                            if (canPop == true) {
                                              MyApp
                                                  .navigatorKey.currentState
                                                  ?.pop();
                                            } else {
                                              Get.offAllNamed('/home');
                                            }
                                          },
                                          child: capText('Go Back', context)),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //anim header
                _buildHeader(animHeight, headerPadding, headerColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Positioned _buildHeader(
      double animHeight, double headerPadding, Color headerColor) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: animHeight,
            width: animHeight,
            decoration:
                BoxDecoration(color: headerColor, shape: BoxShape.circle),
            child: Center(child: assetRive(Assets.succesRive)),
          ),
        ],
      ),
    );
  }
}
