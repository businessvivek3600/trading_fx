// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
//
// const kAndroidUserAgent =
//     'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
//
// // ignore: prefer_collection_literals
// final Set<JavascriptChannel> jsChannels = [
//   JavascriptChannel(
//       name: 'Print',
//       onMessageReceived: (JavascriptMessage message) {
//         print(message.message);
//       }),
// ].toSet();
// String selectedUrl =
//     'https://checkout.stripe.com/c/pay/cs_live_a1u2MqbFrZm51JFiYS9yUIqMUb2d2bFGAFclQAMGiS2wACQdp4ZNphdTij#fidkdWxOYHwnPyd1blppbHNgWjA0SHRHYFdHYG89Y1BzZ0RLV3VPZExrX3J0c2d1Zn1MdGd0QEFTU0lQQzBNXDRTVVZNVDRKdzE8YmRndDZXS3doR3w8TVU8SjBnN0IwMld2dFBGaDNESGdzNTVIQGd9PWddXycpJ2N3amhWYHdzYHcnP3F3cGApJ2lkfGpwcVF8dWAnPyd2bGtiaWBabHFgaCcpJ2BrZGdpYFVpZGZgbWppYWB3dic%2FcXdwYHgl';
// final flutterWebViewPlugin = FlutterWebviewPlugin();
//
// class MySecondaryAppWebView extends StatelessWidget {
//   MySecondaryAppWebView({this.url});
//   final flutterWebViewPlugin = FlutterWebviewPlugin();
//
//   String? url;
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter WebView Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       routes: {
//         '/': (_) => const MyHomePage(title: 'Flutter WebView Demo'),
//         '/widget': (_) {
//           return WillPopScope(
//             onWillPop: () async {
//               await flutterWebViewPlugin.close();
//               return true;
//             },
//             child: WebviewScaffold(
//               url: selectedUrl,
//               javascriptChannels: jsChannels,
//               mediaPlaybackRequiresUserGesture: false,
//               appBar: AppBar(title: const Text('Widget WebView')),
//               withZoom: true,
//               withLocalStorage: true,
//               hidden: true,
//               initialChild: Container(
//                 color: Colors.redAccent,
//                 child: const Center(
//                   child: Text('Waiting.....'),
//                 ),
//               ),
//               bottomNavigationBar: BottomAppBar(
//                 child: Row(
//                   children: <Widget>[
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back_ios),
//                       onPressed: () {
//                         flutterWebViewPlugin.goBack();
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.arrow_forward_ios),
//                       onPressed: () {
//                         flutterWebViewPlugin.goForward();
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.autorenew),
//                       onPressed: () {
//                         flutterWebViewPlugin.reload();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       },
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   // Instance of WebView plugin
//   final flutterWebViewPlugin = FlutterWebviewPlugin();
//
//   // On destroy stream
//   late StreamSubscription _onDestroy;
//
//   // On urlChanged stream
//   late StreamSubscription<String> _onUrlChanged;
//
//   // On urlChanged stream
//   late StreamSubscription<WebViewStateChanged> _onStateChanged;
//
//   late StreamSubscription<WebViewHttpError> _onHttpError;
//
//   late StreamSubscription<double> _onProgressChanged;
//
//   late StreamSubscription<double> _onScrollYChanged;
//
//   late StreamSubscription<double> _onScrollXChanged;
//
//   final _urlCtrl = TextEditingController(text: selectedUrl);
//
//   final _codeCtrl = TextEditingController(text: 'window.navigator.userAgent');
//
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   final _history = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     flutterWebViewPlugin.close();
//
//     _urlCtrl.addListener(() {
//       selectedUrl = _urlCtrl.text;
//     });
//
//     // Add a listener to on destroy WebView, so you can make came actions.
//     _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
//       if (mounted) {
//         // Actions like show a info toast.
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Webview Destroyed')));
//       }
//     });
//
//     // Add a listener to on url changed
//     _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
//       if (mounted) {
//         setState(() {
//           _history.add('onUrlChanged: $url');
//         });
//       }
//     });
//
//     _onProgressChanged =
//         flutterWebViewPlugin.onProgressChanged.listen((double progress) {
//       if (mounted) {
//         setState(() {
//           _history.add('onProgressChanged: $progress');
//         });
//       }
//     });
//
//     _onScrollYChanged =
//         flutterWebViewPlugin.onScrollYChanged.listen((double y) {
//       if (mounted) {
//         setState(() {
//           _history.add('Scroll in Y Direction: $y');
//         });
//       }
//     });
//
//     _onScrollXChanged =
//         flutterWebViewPlugin.onScrollXChanged.listen((double x) {
//       if (mounted) {
//         setState(() {
//           _history.add('Scroll in X Direction: $x');
//         });
//       }
//     });
//
//     _onStateChanged =
//         flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
//       if (mounted) {
//         setState(() {
//           _history.add('onStateChanged: ${state.type} ${state.url}');
//         });
//       }
//     });
//
//     _onHttpError =
//         flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
//       if (mounted) {
//         setState(() {
//           _history.add('onHttpError: ${error.code} ${error.url}');
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     // Every listener should be canceled, the same should be done with this stream.
//     _onDestroy.cancel();
//     _onUrlChanged.cancel();
//     _onStateChanged.cancel();
//     _onHttpError.cancel();
//     _onProgressChanged.cancel();
//     _onScrollXChanged.cancel();
//     _onScrollYChanged.cancel();
//
//     flutterWebViewPlugin.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await flutterWebViewPlugin.close();
//         return true;
//       },
//       child: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(title: const Text('Plugin example app')),
//         body: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                   padding: const EdgeInsets.all(24.0),
//                   child: TextField(controller: _urlCtrl)),
//               ElevatedButton(
//                 onPressed: () {
//                   flutterWebViewPlugin.launch(
//                     selectedUrl,
//                     rect: Rect.fromLTWH(
//                         0.0, 0.0, MediaQuery.of(context).size.width, 300.0),
//                     userAgent: kAndroidUserAgent,
//                     invalidUrlRegex:
//                         r'^(https).+(twitter)', // prevent redirecting to twitter when user click on its icon in flutter website
//                   );
//                 },
//                 child: const Text('Open Web view (rect)'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   flutterWebViewPlugin.launch(selectedUrl, hidden: true);
//                 },
//                 child: const Text('Open "hidden" Web view'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   flutterWebViewPlugin.launch(selectedUrl);
//                 },
//                 child: const Text('Open Fullscreen Web view'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pushNamed('/widget');
//                 },
//                 child: const Text('Open widget web-view'),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(24.0),
//                 child: TextField(controller: _codeCtrl),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   final future =
//                       flutterWebViewPlugin.evalJavascript(_codeCtrl.text);
//                   future.then((String? result) {
//                     setState(() {
//                       _history.add('eval: $result');
//                     });
//                   });
//                 },
//                 child: const Text('Eval some javascript'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   final future = flutterWebViewPlugin
//                       .evalJavascript('alert("Hello World");');
//                   future.then((String? result) {
//                     setState(() {
//                       _history.add('eval: $result');
//                     });
//                   });
//                 },
//                 child: const Text('Eval javascript alert()'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _history.clear();
//                   });
//                   flutterWebViewPlugin.close();
//                 },
//                 child: const Text('Close'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   flutterWebViewPlugin.getCookies().then((m) {
//                     setState(() {
//                       _history.add('cookies: $m');
//                     });
//                   });
//                 },
//                 child: const Text('Cookies'),
//               ),
//               Text(_history.join('\n'))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
