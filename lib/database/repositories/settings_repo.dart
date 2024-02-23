// import 'package:firebase_messaging/firebase_messaging.dart';
import '/database/repositories/fcm_subscription_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';

class SettingsRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  final FCMSubscriptionRepo fcmSubscriptionRepo;
  SettingsRepo(
      {required this.fcmSubscriptionRepo,
      required this.dioClient,
      required this.sharedPreferences});

  /// :Biometric
  void setBiometric(bool val) async {
    await sharedPreferences.setBool(SPConstants.biometric, val);
  }

  bool getBiometric() {
    return sharedPreferences.getBool(SPConstants.biometric) ?? false;
  }

  //new features notification
  Future<void> enableNewFeatures() async =>
      await fcmSubscriptionRepo.subscribeToTopic(SPConstants.topic_testing);
  Future<void> disableNewFeatures() async =>
      await fcmSubscriptionRepo.unSubscribeToTopic(SPConstants.topic_testing);
  bool get getNewFeaturesValue =>
      fcmSubscriptionRepo.getTopicValue(SPConstants.topic_testing);
}
