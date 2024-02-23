// import 'dart:async';
//
// import 'package:circular_progress_bar_with_lines/circular_progress_bar_with_lines.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
// import '/database/functions.dart';
// import '/providers/dashboard_provider.dart';
// import '/sl_container.dart';
// import '/utils/color.dart';
// import '/utils/no_internet_widget.dart';
// import '/utils/text.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
//
// class PdfPreviewPage extends StatelessWidget {
//   PdfPreviewPage({Key? key}) : super(key: key);
//   // final Completer<PDFViewController> _pdfViewController =
//   //     Completer<PDFViewController>();
//   final StreamController<String> _pageCountController =
//       StreamController<String>();
//   @override
//   Widget build(BuildContext context) {
//     print(isOnline);
//     return Scaffold(
//       backgroundColor: mainColor,
//       appBar: AppBar(title: Text('PDF')),
//       body: isOnline
//           ? SfPdfViewer.network(sl.get<DashBoardProvider>().pdfLink ?? '',
//               pageLayoutMode: PdfPageLayoutMode.continuous,
//               canShowScrollHead: false,
//               canShowScrollStatus: false)
//           // PDF(
//           //         enableSwipe: true,
//           //         swipeHorizontal: false,
//           //         autoSpacing: false,
//           //         pageFling: false,
//           //         onPageChanged: (int? current, int? total) =>
//           //             _pageCountController.add('${current! + 1} - $total'),
//           //         onViewCreated: (PDFViewController pdfViewController) async {
//           //           _pdfViewController.complete(pdfViewController);
//           //           final int currentPage =
//           //               await pdfViewController.getCurrentPage() ?? 0;
//           //           final int? pageCount = await pdfViewController.getPageCount();
//           //           _pageCountController.add('${currentPage + 1} - $pageCount');
//           //         },
//           //       ).cachedFromUrl(
//           //         sl.get<DashBoardProvider>().pdfLink ?? '',
//           //         placeholder: (progress) => Column(
//           //           mainAxisAlignment: MainAxisAlignment.center,
//           //           crossAxisAlignment: CrossAxisAlignment.center,
//           //           children: [
//           //             // Center(child: bodyLargeText('$progress %', context)),
//           //             Row(
//           //               mainAxisAlignment: MainAxisAlignment.center,
//           //               children: [
//           //                 CircularProgressBarWithLines(
//           //                   percent: progress,
//           //                   linesAmount: 30,
//           //                   linesLength: 15,
//           //                   radius: 20,
//           //                   linesColor: appLogoColor,
//           //                   centerWidgetBuilder: (context) =>
//           //                       bodyLargeText('${progress.round()}%', context),
//           //                 ),
//           //               ],
//           //             ),
//           //             // Padding(
//           //             //   padding: const EdgeInsets.symmetric(horizontal: 50.0),
//           //             //   child: CircularProgressIndicator(
//           //             //     value: progress,
//           //             //     color: appLogoColor,
//           //             //
//           //             //     valueColor: AlwaysStoppedAnimation(appLogoColor),
//           //             //   ),
//           //             // ),
//           //           ],
//           //         ),
//           //         errorWidget: (error) => Center(child: Text(error.toString())),
//           //       )
//           : NoInternetWidget(),
//     );
//   }
// }
