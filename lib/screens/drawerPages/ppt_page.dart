// import 'package:flutter/material.dart';
// import '/database/functions.dart';
// import '/providers/dashboard_provider.dart';
// import '/sl_container.dart';
// import '/utils/color.dart';
// import '/utils/no_internet_widget.dart';
// import '/utils/text.dart';
// import 'package:power_file_view/power_file_view.dart';
//
// class PPTPreviewPage extends StatelessWidget {
//   PPTPreviewPage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: mainColor,
//       appBar: AppBar(title: titleLargeText('PPT', context)),
//       body: isOnline
//           ? PowerFileViewWidget(
//               downloadUrl:
//                   // 'https://tradingfx.live/assets/customer-panel/download/ppt.pptx',
//                   sl.get<DashBoardProvider>().pptLink ?? '',
//               filePath: pPTDownloadFilePath,
//               loadingBuilder: (viewType, progress) {
//                 return Container(
//                   alignment: Alignment.center,
//                   child: bodyLargeText("Loading: $progress", context),
//                 );
//               },
//               errorBuilder: (viewType) {
//                 return Container(
//                   alignment: Alignment.center,
//                   child: bodyLargeText(
//                       "Something went wrong!!!! $viewType", context),
//                 );
//               },
//             )
//           : NoInternetWidget(),
//     );
//   }
// }
