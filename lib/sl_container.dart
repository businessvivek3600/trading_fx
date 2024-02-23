import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '/screens/youtube_video_play_widget.dart';
import '/constants/app_constants.dart';
import '/database/dio/dio/dio_client.dart';
import '/database/repositories/auth_repo.dart';
import '/database/repositories/cash_wallet_repo.dart';
import '/database/repositories/commission_wallet_repo.dart';
import '/database/repositories/dashboard_repo.dart';
import '/database/repositories/event_tickets_repo.dart';
import '/database/repositories/fcm_subscription_repo.dart';
import '/database/repositories/gallery_video_repo.dart';
import '/database/repositories/inbox_repo.dart';
import '/database/repositories/settings_repo.dart';
import '/database/repositories/subscription_repo.dart';
import '/database/repositories/team_view_repo.dart';
import '/database/repositories/voucher_repo.dart';
import '/providers/Cash_wallet_provider.dart';
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
import '/utils/network_info.dart';
import '/utils/notification_sqflite_helper.dart';
import '/utils/sp_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/databases/firebase_database.dart';
import 'database/dio/dio/logging_interceptor.dart';
import 'database/repositories/support_repo.dart';
import 'providers/web_view_provider.dart';
import 'screens/youtube_video_play_widget copy.dart';
import 'utils/device_info.dart';

final sl = GetIt.I;
Future<void> initRepos() async {
  // Core
  if (!sl.isRegistered<DeviceInfoConfig>()) {
    sl.registerLazySingleton(() => DeviceInfoConfig());
  }
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton(() => NetworkInfo(sl()));
  }
  if (!sl.isRegistered<NotificationDatabaseHelper>()) {
    sl.registerLazySingleton(() => NotificationDatabaseHelper());
  }
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton(() => DioClient(AppConstants.baseUrl, sl(),
        loggingInterceptor: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<SettingsRepo>()) {
    sl.registerLazySingleton(() => SettingsRepo(
        sharedPreferences: sl(), dioClient: sl(), fcmSubscriptionRepo: sl()));
  }
  if (!sl.isRegistered<SpUtil>()) {
    sl.registerLazySingleton(() => SpUtil(sharedPreferences: sl()));
  }
  if (!sl.isRegistered<FirebaseDatabase>()) {
    sl.registerLazySingleton(() =>
        FirebaseDatabase(collection: AppConstants.firebaseCollectionName));
  }

  //Repositories
  if (!sl.isRegistered<AuthRepo>()) {
    sl.registerLazySingleton(
        () => AuthRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<DashboardRepo>()) {
    sl.registerLazySingleton(
        () => DashboardRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<TeamViewRepo>()) {
    sl.registerLazySingleton(
        () => TeamViewRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<InboxRepo>()) {
    sl.registerLazySingleton(
        () => InboxRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<VoucherRepo>()) {
    sl.registerLazySingleton(
        () => VoucherRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<EventTicketRepo>()) {
    sl.registerLazySingleton(
        () => EventTicketRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<SupportRepo>()) {
    sl.registerLazySingleton(
        () => SupportRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<SubscriptionRepo>()) {
    sl.registerLazySingleton(
        () => SubscriptionRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<CashWalletRepo>()) {
    sl.registerLazySingleton(
        () => CashWalletRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<CommissionWalletRepo>()) {
    sl.registerLazySingleton(
        () => CommissionWalletRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<GalleryRepo>()) {
    sl.registerLazySingleton(
        () => GalleryRepo(dioClient: sl(), sharedPreferences: sl()));
  }
  if (!sl.isRegistered<FCMSubscriptionRepo>()) {
    sl.registerLazySingleton(
        () => FCMSubscriptionRepo(sharedPreferences: sl()));
  }

  //Providers
  if (!sl.isRegistered<AuthProvider>()) {
    sl.registerLazySingleton(
        () => AuthProvider(authRepo: sl(), fcmSubscriptionRepo: sl()));
  }
  if (!sl.isRegistered<DashBoardProvider>()) {
    sl.registerLazySingleton(() => DashBoardProvider(dashBoardRepo: sl()));
  }
  if (!sl.isRegistered<NotificationProvider>()) {
    sl.registerLazySingleton(
        () => NotificationProvider(notificationDatabaseHelper: sl()));
  }
  if (!sl.isRegistered<InboxProvider>()) {
    sl.registerLazySingleton(() => InboxProvider(inboxRepo: sl()));
  }
  if (!sl.isRegistered<TeamViewProvider>()) {
    sl.registerLazySingleton(() => TeamViewProvider(teamViewRepo: sl()));
  }
  if (!sl.isRegistered<VoucherProvider>()) {
    sl.registerLazySingleton(() => VoucherProvider(voucherRepo: sl()));
  }
  if (!sl.isRegistered<EventTicketsProvider>()) {
    sl.registerLazySingleton(() => EventTicketsProvider(eventTicketRepo: sl()));
  }
  if (!sl.isRegistered<SupportProvider>()) {
    sl.registerLazySingleton(() => SupportProvider(supportRepo: sl()));
  }
  if (!sl.isRegistered<SubscriptionProvider>()) {
    sl.registerLazySingleton(
        () => SubscriptionProvider(subscriptionRepo: sl()));
  }
  if (!sl.isRegistered<CashWalletProvider>()) {
    sl.registerLazySingleton(() => CashWalletProvider(cashWalletRepo: sl()));
  }
  if (!sl.isRegistered<CommissionWalletProvider>()) {
    sl.registerLazySingleton(
        () => CommissionWalletProvider(commissionWalletRepo: sl()));
  }
  if (!sl.isRegistered<GalleryProvider>()) {
    sl.registerLazySingleton(() => GalleryProvider(galleryRepo: sl()));
  }
  if (!sl.isRegistered<CardPaymentProvider>()) {
    sl.registerLazySingleton(() => CardPaymentProvider(subscriptionRepo: sl()));
  }
  if (!sl.isRegistered<PlayerProvider>()) {
    sl.registerLazySingleton(() => PlayerProvider());
  }
  if (!sl.isRegistered<PlayerProviderNew>()) {
    sl.registerLazySingleton(() => PlayerProviderNew());
  }
  if (!sl.isRegistered<WebViewProvider>()) {
    sl.registerLazySingleton(() => WebViewProvider());
  }

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerLazySingleton(() => sharedPreferences);
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton(() => Dio());
  }
  if (!sl.isRegistered<LoggingInterceptor>()) {
    sl.registerLazySingleton(() => LoggingInterceptor());
  }
  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton(() => Connectivity());
  }
}
