import 'package:firebase_messaging/firebase_messaging.dart';
import '/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMSubscriptionRepo {
  FCMSubscriptionRepo({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> subscribeToTopic(String topic) async {
    await messaging
        .subscribeToTopic(topic)
        .then((value) => setTopicValue(topic, true));
  }

  Future<void> unSubscribeToTopic(String topic) async {
    await messaging
        .unsubscribeFromTopic(topic)
        .then((value) => setTopicValue(topic, false));
  }

  void setTopicValue(String topic, bool val) async {
    await sharedPreferences.setBool(topic, val);
  }

  bool getTopicValue(String topic) {
    return sharedPreferences.getBool(topic) ?? false;
  }
}
