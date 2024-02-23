import 'dart:async';

import 'package:flutter/cupertino.dart';
import '/database/model/response/additional/fcm_notification_model.dart';
import '/sl_container.dart';
import '/utils/notification_sqflite_helper.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationDatabaseHelper notificationDatabaseHelper;
  NotificationProvider({required this.notificationDatabaseHelper});
  StreamController<List<Map<String, dynamic>>> notifications =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  var totalUnread = 0;
  Future<void> init() async {
    notifications.add(
        await sl.get<NotificationDatabaseHelper>().listenToSqlNotifications());
    // print('notification fetched from local db successfully!👏');
  }

  Future<void> markRead(int id) async {
    await sl
        .get<NotificationDatabaseHelper>()
        .updateItem(id, {'isRead': 1})
        .then((value) async => notifications.add(await sl
            .get<NotificationDatabaseHelper>()
            .listenToSqlNotifications()))
        .then((value) => getUnRead());
    // print('notification fetched from local db successfully!👏');
  }

  Future<int> getUnRead() async {
    totalUnread = (await sl.get<NotificationDatabaseHelper>().getItems())
        .where((msg) => msg['isRead'] == 0)
        .length;
    notifyListeners();
    return totalUnread;
  }

  clear() {
    notifications.add([]);
  }
}
