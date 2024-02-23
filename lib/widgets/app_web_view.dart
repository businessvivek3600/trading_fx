// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '/utils/color.dart';
// import '/utils/text.dart';
// // import 'package:webview_flutter_plus/webview_flutter_plus.dart';
//
// class AppWebView extends StatefulWidget {
//   const AppWebView({required this.url, Key? key}) : super(key: key);
//   final String url;
//   @override
//   State<AppWebView> createState() => _AppWebViewState();
// }
//
// class _AppWebViewState extends State<AppWebView> {
//   bool loading = true;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: mainColor,
//       appBar: AppBar(
//         title: bodyLargeText(widget.url, context, maxLines: 1),
//         actions: [
//           IconButton(
//               onPressed: () => Clipboard.setData(
//                       ClipboardData(text: widget.url))
//                   .then((value) =>
//                       Fluttertoast.showToast(msg: 'Link copied successfully!')),
//               icon: Icon(Icons.copy_rounded))
//         ],
//       ),
//       body: Stack(
//         children: [
//           WebViewPlus(
//             serverPort: 5353,
//             javascriptChannels: null,
//             initialUrl: widget.url,
//             onWebViewCreated: (controller) {
//               // _controller = controller;
//             },
//             onPageFinished: (url) {
//               // _controller?.getHeight().then((double height) {
//               //   debugPrint("Height: " + height.toString());
//               setState(() {
//                 loading = false;
//               });
//               // });
//             },
//             javascriptMode: JavascriptMode.unrestricted,
//           ),
//           loading ? LinearProgressIndicator(color: Colors.white) : Stack(),
//         ],
//       ),
//     );
//   }
// }
