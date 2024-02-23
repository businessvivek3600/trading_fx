import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '/screens/youtube_video_play_widget%20copy.dart';
import '/screens/dashboard/company_trade_ideas_page.dart';
import '/providers/web_view_provider.dart';
import '/screens/drawerPages/event_tickets/event_tickets_page.dart';
import '/screens/youtube_video_play_widget.dart';
import 'package:nested/nested.dart';
import 'package:video_player/video_player.dart';
import '/database/my_notification_setup.dart';
import '/providers/GalleryProvider.dart';
import '/providers/auth_provider.dart';
import '/providers/card_payment_provider.dart';
import '/providers/commission_wallet_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/event_tickets_provider.dart';
import '/providers/inbox_provider.dart';
import '/providers/notification_provider.dart';
import '/providers/subscription_provider.dart';
import '/providers/support_provider.dart';
import '/providers/team_view_provider.dart';
import '/providers/voucher_provider.dart';
import '/screens/Notification/notification_page.dart';
import '/screens/auth/forgot_password.dart';
import '/screens/auth/login_screen.dart';
import '/screens/dashboard/main_page.dart';
import '/screens/drawerPages/subscription/subscription_page.dart';
import '/screens/splash/splash_screen.dart';
import '/screens/update_app_page.dart';
import '/sl_container.dart';
import '/utils/default_logger.dart';
import '/utils/theme.dart';
import 'package:provider/provider.dart';
import 'providers/Cash_wallet_provider.dart';
import 'screens/drawerPages/inbox/inbox_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp(
      {Key? key, this.notificationAppLaunchDetails, required this.initialRoute})
      : super(key: key);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  static final navigatorKey = GlobalKey<NavigatorState>();
  final String initialRoute;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String tag = 'MyApp';
  getNotifiersList(List<ChangeNotifier> widgets) => widgets
      .map((e) => ChangeNotifierProvider(create: (context) => e))
      .toList();
  List<ChangeNotifier> notifiers = [
    sl.get<DashBoardProvider>(),
    sl.get<AuthProvider>(),
    sl.get<NotificationProvider>(),
    sl.get<TeamViewProvider>(),
    sl.get<VoucherProvider>(),
    sl.get<InboxProvider>(),
    sl.get<EventTicketsProvider>(),
    sl.get<SupportProvider>(),
    sl.get<SubscriptionProvider>(),
    sl.get<CashWalletProvider>(),
    sl.get<CommissionWalletProvider>(),
    sl.get<GalleryProvider>(),
    sl.get<CardPaymentProvider>(),
  ];

  @override
  void initState() {
    MyNotification.requestPermissions();
    MyNotification.configureDidReceiveLocalNotificationSubject();
    MyNotification.configureSelectNotificationSubject();
    super.initState();
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: MultiProvider(
        providers: initProviders,
        child: Builder(builder: (context) {
          return GetMaterialApp(
            navigatorKey: MyApp.navigatorKey,
            initialRoute: widget.initialRoute,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: lightTheme,
            //  locale: DevicePreview.of(context).device.p,
            // home: SplashScreen.routeName,
            // home: SignUpScreen(),
            onGenerateRoute: (settings) {
              warningLog('onGenerateRoute settings $settings', 'settings');
            },
            routes: <String, WidgetBuilder>{
              SplashScreen.routeName: (_) => const SplashScreen(),
              MainPage.routeName: (_) => MainPage(),
              LoginScreen.routeName: (_) => const LoginScreen(),
              InboxScreen.routeName: (_) => const InboxScreen(),
              EventTicketsPage.routeName: (_) => const EventTicketsPage(),
              ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
              // UpdateAppPage.routeName: (_) => const UpdateAppPage(),
              SubscriptionPage.routeName: (_) => const SubscriptionPage(),
              YoutubePlayerPage.routeName: (_) => const YoutubePlayerPage(),
              YoutubePlayerPageNew.routeName: (_) => const YoutubePlayerPageNew(),
              NotificationPage.routeName: (_) => NotificationPage(
                  notificationAppLaunchDetails:
                      widget.notificationAppLaunchDetails),
              CompanyTradeIdeasPage.routeName: (_) => const CompanyTradeIdeasPage(),
            },
            navigatorObservers: [routeObserver],
            enableLog: true,
          );
        }),
      ),
    );
  }

  List<SingleChildWidget> get initProviders {
    return [
      ChangeNotifierProvider(create: (context) => sl.get<DashBoardProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<AuthProvider>()),
      ChangeNotifierProvider(
          create: (context) => sl.get<NotificationProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<TeamViewProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<VoucherProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<InboxProvider>()),
      ChangeNotifierProvider(
          create: (context) => sl.get<EventTicketsProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<SupportProvider>()),
      ChangeNotifierProvider(
          create: (context) => sl.get<SubscriptionProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<CashWalletProvider>()),
      ChangeNotifierProvider(
          create: (context) => sl.get<CommissionWalletProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<GalleryProvider>()),
      ChangeNotifierProvider(
          create: (context) => sl.get<CardPaymentProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<PlayerProvider>()),
      ChangeNotifierProvider(create: (context) => sl.get<PlayerProviderNew>()),
      ChangeNotifierProvider(create: (context) => sl.get<WebViewProvider>()),
    ];
  }
}
