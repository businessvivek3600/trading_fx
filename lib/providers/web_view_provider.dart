import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewProvider with ChangeNotifier {
  WebViewController? controller;
  final String tag = 'WebViewProvider';

  ///webview title
  String? _title;
  String? get title => _title;
  setTitle() async {
    _title = await controller?.getTitle();
    notifyListeners();
  }

  ///loading progress
  double _loadingProgress = 0;
  double get loadingProgress => _loadingProgress;
  setLoadinProgress(double val) {
    _loadingProgress = val;
    notifyListeners();
  }

  ///webview url
  String? _url;
  String? get url => _url;
  setUrl(String? val) {
    _url = val;
    setTextEditingController(val ?? '');
    notifyListeners();
  }

  ///webview  text controller
  late TextEditingController textEditingController;
  setTextEditingController(String val) {
    textEditingController.text = val;
    notifyListeners();
  }
}
