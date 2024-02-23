import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:mycarclub/constants/assets_constants.dart';
import 'package:mycarclub/utils/picture_utils.dart';
import '/database/my_notification_setup.dart';
import '../../utils/my_logger.dart';
import '/utils/app_lock_authentication.dart';
import '/database/repositories/settings_repo.dart';
import '/providers/auth_provider.dart';
import '/screens/auth/login_screen.dart';
import '/screens/auth/sign_up_screen.dart';
import '/screens/dashboard/main_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/network_info.dart';
import 'package:video_player/video_player.dart';
import '../../database/functions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, this.controller}) : super(key: key);
  static const String routeName = '/SplashScreen';
  final VideoPlayerController? controller;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String tag = 'Splash Screen';
  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  int duration = 0;
  int position = 0;
  late VideoPlayerController _controller;

  bool authorizedRoutes(String path) {
    List<String> authorizedRoutes = [
      '/dashboard',
      '/subscription',
      '/eventTickets',
      '/notification',
      '/inbox',
      '/support',
      '/teamView',
      '/commissionWallet',
      '/voucher',
      '/cardPayment',
      '/gallery',
      '/cashWallet',
      '/companyTradeIdeas',
      '/forgotPassword',
      '/updateApp',
      '/ytLive'
    ];
    return authorizedRoutes.contains(path);
  }

  @override
  void initState() {
    super.initState();
    sl.get<NetworkInfo>().checkConnectivity(context);
    sl.get<AuthProvider>().getSignUpInitialData();
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      checkLogin2();
    });
    // initController();
  }

  void initController() {
    _controller = VideoPlayerController.asset('assets/videos/1_1.mp4')
      ..initialize().then((_) {
        _controller.play();
        duration = _controller.value.duration.inMilliseconds;
      });
    _controller.addListener(_listner);
  }

  void _listner() {
    setState(() {});
    if (_controller.value.hasError) {
      errorLog('video error: ${_controller.value.errorDescription}', tag,
          'initState');
    }
    if (_controller.value.isInitialized) {
      duration = _controller.value.duration.inMilliseconds;
      if (_controller.value.position.inMilliseconds >= 2960) {
        checkLogin2();
      }
    }
  }

  checkLogin2() async {
    var authProvider = sl.get<AuthProvider>();
    bool isLogin = authProvider.isLoggedIn();
    if (!isLogin) {
      Get.offAll(const LoginScreen());
    } else {
      var user = await authProvider.getUser();
      if (user != null) {
        authProvider.userData = user;
        authProvider.authRepo
            .saveUserToken(authProvider.authRepo.getUserToken());
        bool isBiometric = sl.get<SettingsRepo>().getBiometric();
        if (isBiometric) {
          AppLockAuthentication.authenticate().then((value) {
            infoLog('authenticate: authStatus: $value', tag, 'checkLogin');
            if (value[0] == AuthStatus.available) {
              if (value[1] == AuthStatus.success) {
                Get.offAll(MainPage());
              } else {
                exitTheApp();
              }
            } else {
              Get.offAll(MainPage());
            }
          });
        } else {
          Get.offAll(MainPage());
        }
      } else {
        logOut(tag);
        Get.offAll(const LoginScreen());
      }
    }
    listenDynamicLinks();
  }

  @override
  void dispose() {
    // _controller.dispose();
    // _controller.removeListener(_listner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody2(),
      // body: buildBody(),
    );
  }

  Widget buildBody2() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: mainColor,
      child: Center(
          child: assetImages(
        Assets.appLogo_S,
        width: 200,
        height: 200,
      )),
    );
  }

  Stack buildBody() {
    return Stack(
      children: [
        Container(
          height: double.maxFinite,
          width: double.maxFinite,
          color: mainColor,
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller))
              : Container(),
        ),
      ],
    );
  }

  Future<void> listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) async {
      var authProvider = sl.get<AuthProvider>();
      bool isLogin = authProvider.isLoggedIn();
      var user = await authProvider.getUser();
      try {
        // logger.d('listenDynamicLinks - DeepLink Data: $data');
        // logger.f(
        //     'referring link is --> ${(data['~referring_link'] ?? '')}  \n  non_branch_link is --> ${(data['+non_branch_link'] ?? "")}');
        if (data['~referring_link'] != null ||
            data['+non_branch_link'] != null) {
          Uri uri =
              Uri.parse(data['~referring_link'] ?? data['+non_branch_link']);
          logger.w('uri: $uri',
              tag: '$tag listenDynamicLinks',
              error:
                  'path:${uri.path}\n queryParameters:${uri.queryParameters}\n query:${uri.query}\n fragment:${uri.fragment} \n host:${uri.host} \n origin:${uri.origin} \n port:${uri.port} \n scheme:${uri.scheme} \n userInfo:${uri.userInfo} ');
          var queryParams = uri.queryParameters;

          // if (uri.path == '/refCode'|| '/signup) => signUpScreen
          if ((uri.path == SignUpScreen.routeName || uri.path == '/refCode') &&
              !isLogin) {
            String? sponsor;
            String? placement;
            if (queryParams.entries.isNotEmpty) {
              sponsor = queryParams['sponsor'];
              placement = queryParams['placement'];
            }
            Get.to(SignUpScreen(sponsor: sponsor, placement: placement));
          }
          //athorizedRoutes => mainPage
          else if (authorizedRoutes(uri.path) && isLogin) {
            logger.t('authorizedRoutes => splashScreen',
                tag: '$tag listenDynamicLinks', error: queryParams);
            selectNotificationStream.add(jsonEncode(queryParams));
          }
        }
      } catch (e) {
        logger.e('listenDynamicLinks - error: ',
            error: e, tag: '$tag listenDynamicLinks');
      }
    }, onError: (error) {
      logger.e('listenDynamicLinks - error: ',
          error: error, tag: '$tag listenDynamicLinks');
    });
  }
}
