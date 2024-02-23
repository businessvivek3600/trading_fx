import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/web_view_provider.dart';
import '../sl_container.dart';
import '../utils/default_logger.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../utils/picture_utils.dart';

class TawkChatPage extends StatelessWidget {
  TawkChatPage({super.key});
  final String title = 'Tawk.to Chat';
  final authProvider = sl.get<AuthProvider>();

  @override
  Widget build(BuildContext context) {
    return Consumer<WebViewProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: provider.controller != null
            ? const Color(0xFF03A84E)
            : Colors.transparent,
        appBar: AppBar(
          backgroundColor: provider.controller != null
              ? const Color(0xFF03A84E)
              : Colors.transparent,
          title: const Text('Tawk.to Chat'),
          leading: IconButton(
              onPressed: () async {
                if (provider.controller != null) {
                  if (await provider.controller!.canGoBack()) {
                    await provider.controller!.goBack();
                  } else {
                    Navigator.pop(context);
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(Platform.isIOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back_rounded)),
        ),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 1),
          ),
          child: Tawk(
            directChatLink:
                'https://tawk.to/chat/6517ec1410c0b257248722e1/1hbin4ceh',
            // https://embed.tawk.to/6517ec1410c0b257248722e1/1hbin4ceh
            visitor: TawkVisitor(
                name: authProvider.userData.customerName ?? '',
                email: authProvider.userData.customerEmail ?? '',
                tel: authProvider.userData.customerMobile ?? '',
                userId: authProvider.userData.username ?? ''),
            onLoad: () {
              print('Hello');
            },
            onLinkTap: (String url) {
              print('Link tapped: $url');
            },
            placeholder: const Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    });
  }
}

/// [Tawk] Widget.
class Tawk extends StatefulWidget {
  final String directChatLink;
  final TawkVisitor? visitor;
  final Function? onLoad;
  final Function(String)? onLinkTap;
  final Widget? placeholder;

  const Tawk({
    Key? key,
    required this.directChatLink,
    this.visitor,
    this.onLoad,
    this.onLinkTap,
    this.placeholder,
  }) : super(key: key);

  @override
  _TawkState createState() => _TawkState();
}

class _TawkState extends State<Tawk> {
  var provider = sl.get<WebViewProvider>();
  // double loadingProgress = 0;
  late final PlatformWebViewControllerCreationParams params;

  late WebViewController _controller;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => willPop(provider),
      child: Consumer<WebViewProvider>(builder: (context, provider, child) {
        return Stack(
          children: [
            if (provider.controller != null)
              WebViewWidget(controller: provider.controller!),
            _isLoading
                ? widget.placeholder ??
                    Center(
                        child: CircularProgressIndicator(
                            color: provider.controller != null
                                ? const Color(0xFF03A84E)
                                : Colors.white))
                : Container(),
          ],
        );
      }),
    );
  }

  Future<bool> willPop(WebViewProvider provider) async {
    bool willBack = false;
    var controller = provider.controller;
    if (controller == null) {
      willBack = true;
    } else {
      if (await controller.canGoBack()) {
        await controller.goBack();
      } else {
        willBack = true;
      }
    }
    errorLog('will back $willBack');
    return willBack;
  }

  void _setUser(TawkVisitor visitor) {
    final json = jsonEncode(visitor);
    String javascriptString;
    infoLog('setUser: $json');

    if (Platform.isIOS) {
      javascriptString = '''
        Tawk_API = Tawk_API || {};
        Tawk_API.setAttributes($json);
      ''';
    } else {
      javascriptString = '''
        Tawk_API = Tawk_API || {};
        Tawk_API.onLoad = function() {
          Tawk_API.setAttributes($json);
        };
      ''';
    }

    provider.controller!.runJavaScript(javascriptString);
  }

  initController() async {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{});
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          provider.setLoadinProgress(progress.toDouble());
          infoLog('loadingProgress : ${provider.loadingProgress}%)');
        },
        onPageStarted: (String url) {
          infoLog('Page started loading: $url');
        },
        onPageFinished: (url) {
          // controller.setBackgroundColor(Color(0xFF03A84E));
          if (widget.visitor != null) {
            _setUser(widget.visitor!);
          }

          if (widget.onLoad != null) {
            widget.onLoad!();
          }

          setState(() {
            _isLoading = false;
          });
          provider.setTitle();
          provider.setLoadinProgress(0);
          infoLog('Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          errorLog('''
                      Page resource error:
                      code: ${error.errorCode}
                      description: ${error.description}
                      errorType: ${error.errorType}
                      isForMainFrame: ${error.isForMainFrame}
          ''', 'onWebResourceError');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url == 'about:blank' || request.url.contains('tawk.to')) {
            return NavigationDecision.navigate;
          }

          if (widget.onLinkTap != null) {
            widget.onLinkTap!(request.url);
          }

          return NavigationDecision.prevent;
        },
        onUrlChange: (UrlChange change) async {
          provider.setUrl(change.url);
          infoLog('url change to ${change.url}');
        },
      ))
      ..addJavaScriptChannel('Toaster',
          onMessageReceived: (JavaScriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message.message,
                style: const TextStyle(color: Colors.red))));
      })
      ..loadRequest(Uri.parse(widget.directChatLink));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    provider.controller = controller;
    // provider.controller?.setBackgroundColor(Color(0xFF03A84E));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    provider.textEditingController = TextEditingController();
    initController();
  }

  @override
  void dispose() {
    provider.controller = null;
    provider.setUrl(null);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }
}

/// Use [TawkVisitor] to set the visitor name and email.
class TawkVisitor {
  /// Visitor's name.
  final String? name;

  /// Visitor's email.
  final String? email;

  /// [Secure mode](https://developer.tawk.to/jsapi/#SecureMode).
  final String? hash;

  /// Visitor's phone number.
  final String? tel;

  /// Visitor's user id.
  final String? userId;

  TawkVisitor({
    this.name,
    this.email,
    this.hash,
    this.tel,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) {
      data['name'] = name;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (hash != null) {
      data['hash'] = hash;
    }
    if (tel != null) {
      data['tel'] = tel;
    }
    if (userId != null) {
      data['user_id'] = userId;
    }

    return data;
  }
}
