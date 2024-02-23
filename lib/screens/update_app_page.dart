// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '/constants/assets_constants.dart';
// import '/database/functions.dart';
// import '/utils/color.dart';
// import '/utils/picture_utils.dart';
// import '/utils/sizedbox_utils.dart';
// import '/utils/text.dart';

// import '../utils/default_logger.dart';

// class UpdateAppPage extends StatefulWidget {
//   const UpdateAppPage({Key? key}) : super(key: key);
//   static const String routeName = '/UpdateAppPage';
//   @override
//   State<UpdateAppPage> createState() => _UpdateAppPageState();
// }

// class _UpdateAppPageState extends State<UpdateAppPage> {
//   @override
//   Widget build(BuildContext context) {
//     Color? textColor = null;
//     return Scaffold(
//       backgroundColor: mainColor,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             height20(kToolbarHeight),
//             Stack(
//               children: [
//                 Row(
//                   children: [
//                     Column(
//                       children: [
//                         assetLottie(Assets.shiningStars),
//                         assetLottie(Assets.shiningStars),
//                         assetLottie(Assets.shiningStars),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   top: 0,
//                   right: 0,
//                   left: 0,
//                   child: Container(
//                     child: assetImages(Assets.iosMobilePhone),
//                     // color: Colors.red,
//                   ),
//                 )
//               ],
//             ),
//             Spacer(),
//             Column(
//               children: [
//                 titleLargeText('Update Required', context,
//                     color: textColor, fontSize: 28),
//                 height10(),
//                 capText(
//                     'We are thrilled to announce that our app has undergone a remarkable transformation with our latest update. Please update your app for an improved experience!',
//                     context,
//                     color: textColor,
//                     textAlign: TextAlign.center,
//                     lineHeight: 1.5,
//                     maxLines: 10,
//                     fontSize: 16),
//               ],
//             ),
//             Spacer(),
//             Row(
//               children: [
//                 Expanded(
//                     child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5))),
//                         onPressed: () => launchStore(),
//                         // onPressed: () => updateApp(),
//                         child: Text('Update Now')))
//               ],
//             ),
//             Row(
//               children: [
//                 Expanded(
//                     child: TextButton(
//                         style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5))),
//                         onPressed: () => exitTheApp(),
//                         child: bodyLargeText('Not Now', context,
//                             color: textColor)))
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   update() async {
//     infoLog('performing immediateUpdateAllowed ');
//     // Get.to(UpdatePage());
//     InAppUpdate.performImmediateUpdate()
//         .then((value) => errorLog(value.toString()))
//         .catchError((e) {
//       Fluttertoast.showToast(msg: e.toString());
//       return AppUpdateResult.inAppUpdateFailed;
//     }).then((value) => warningLog('done'));
//   }

//   launchStore() {
//     Platform.isAndroid ? launchPlayStore() : launchAppStore();
//   }
// }

// class UpdatePage extends StatefulWidget {
//   const UpdatePage({super.key, required this.required});
//   final bool required;
//   @override
//   State<UpdatePage> createState() => _UpdatePageState();
// }

// class _UpdatePageState extends State<UpdatePage> {
//   bool willPop = false;
//   @override
//   void initState() {
//     super.initState();
//     willPop = !widget.required;
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       if (Platform.isAndroid) {
//         // InAppUpdate.performImmediateUpdate().then((value) {
//         //   errorLog(value.toString() + ' ${value}', 'UpdatePage');
//         //   if (value == AppUpdateResult.userDeniedUpdate) {
//         //     exitTheApp();
//         //   }
//       //   }).catchError((e) {
//       //     errorLog(e.toString(), 'UpdatePage');
//       //     Fluttertoast.showToast(msg: e.toString());
//       //     future(3, () => exitTheApp());
//       //   }).then((value) => warningLog('done'));
//       // }
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color? textColor = null;
//     return WillPopScope(
//       onWillPop: () async {
//         errorLog('running will pop scope : ', 'UpdatePage');
//         if (widget.required) {
//           exitTheApp();
//           return false;
//         } else {
//           return true;
//         }
//       },
//       child: Scaffold(
//         backgroundColor: mainColor,
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               height20(kToolbarHeight),
//               Stack(
//                 children: [
//                   Row(
//                     children: [
//                       Column(
//                         children: [
//                           assetLottie(Assets.shiningStars),
//                           assetLottie(Assets.shiningStars),
//                           assetLottie(Assets.shiningStars),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     top: 0,
//                     right: 0,
//                     left: 0,
//                     child: Container(
//                       child: assetImages(Assets.iosMobilePhone),
//                       // color: Colors.red,
//                     ),
//                   )
//                 ],
//               ),
//               Spacer(),
//               Column(
//                 children: [
//                   titleLargeText('Update Required', context,
//                       color: textColor, fontSize: 28),
//                   height10(),
//                   capText(
//                       'We are thrilled to announce that our app has undergone a remarkable transformation with our latest update. Please update your app for an improved experience!',
//                       context,
//                       color: textColor,
//                       textAlign: TextAlign.center,
//                       lineHeight: 1.5,
//                       maxLines: 10,
//                       fontSize: 16),
//                 ],
//               ),
//               Spacer(),
//               Row(
//                 children: [
//                   Expanded(
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(5))),
//                           onPressed: () => launchStore(),
//                           // onPressed: () => updateApp(),
//                           child: Text('Update Now')))
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                       child: TextButton(
//                           style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(5))),
//                           onPressed: () => exitTheApp(),
//                           child: bodyLargeText('Not Now', context,
//                               color: textColor)))
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   launchStore() {
//     Platform.isAndroid ? launchPlayStore() : launchAppStore();
//   }
// }
