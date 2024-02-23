import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '/database/functions.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    ConnectivityResult _result = await connectivity.checkConnectivity();
    isOnline = _result != ConnectivityResult.none;
    print('NetworkInfo ---> isConnected $isOnline');
    return _result != ConnectivityResult.none;
  }

  void checkConnectivity(BuildContext context) {
    bool _firstTime = true;
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isOnline = result != ConnectivityResult.none;
      print('You are ${isOnline ? 'Online' : 'Offline'}');
      if (!_firstTime) {
        //bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        // bool isNotConnected;
        // if (result == ConnectivityResult.none) {
        //   isNotConnected = true;
        // } else {
        //   isNotConnected = !await _updateConnectivityStatus();
        // }
        // if (isNotConnected) {
        //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     backgroundColor: Colors.red,
        //     duration: Duration(seconds: 6000),
        //     content: Text(
        //       "You don't have internet connection",
        //       textAlign: TextAlign.center,
        //     ),
        //   ));
        // } else {
        //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     backgroundColor: Colors.green,
        //     duration: Duration(seconds: 3),
        //     content: Text(
        //       "You are connected",
        //       textAlign: TextAlign.center,
        //     ),
        //   ));
        // }
      }

      _firstTime = false;
    });
    print('NetworkInfo ---> checkConnectivity  $isOnline');
  }

  static Future<bool> _updateConnectivityStatus() async {
    bool _isConnected = false;
    try {
      final List<InternetAddress> _result =
          await InternetAddress.lookup('google.com');
      if (_result.isNotEmpty && _result[0].rawAddress.isNotEmpty) {
        _isConnected = true;
      }
    } catch (e) {
      _isConnected = false;
    }
    isOnline = _isConnected;
    return _isConnected;
  }
}
