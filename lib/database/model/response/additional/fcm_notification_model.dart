import 'dart:convert';

import '/utils/default_logger.dart';

class FCMNotification {
  String? to;
  NotificationWithTitleBody? notification;
  FCMNotificationData? data;

  FCMNotification({this.to, this.notification, this.data});

  FCMNotification.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    notification = json['notification'] != null
        ? new NotificationWithTitleBody.fromJson(json['notification'])
        : null;
    data = json['data'] != null
        ? new FCMNotificationData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['to'] = this.to;
    if (this.notification != null) {
      data['notification'] = this.notification!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class NotificationWithTitleBody {
  String? body;
  String? title;
  String? titleLocKey;

  NotificationWithTitleBody({this.body, this.title, this.titleLocKey});

  NotificationWithTitleBody.fromJson(Map<String, dynamic> json) {
    body = json['body'];
    title = json['title'];
    titleLocKey = json['titleLocKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['body'] = this.body;
    data['title'] = this.title;
    data['titleLocKey'] = this.titleLocKey;
    return data;
  }
}

class FCMNotificationData {
  String? body;
  String? title;
  String? messageId;
  String? timestamp;
  String? image;
  List<Map<String, dynamic>>? actions;

  FCMNotificationData(
      {this.body, this.title, this.messageId, this.image, this.actions});

  FCMNotificationData.fromJson(Map<String, dynamic> json) {
    body = json['body'];
    title = json['title'];
    messageId = json['message_id'];
    timestamp = json['timestamp'];
    image = json['image'];
    List<Map<String, dynamic>> _actions = [];
    try {
      json['actions'] is String
          ? jsonDecode(json['actions']).entries.forEach((e) {
              // print(e);
              _actions.add({e.key: e.value});
            })
          : json['actions'];
    } catch (e) {
      errorLog(e.toString() + json['actions'].toString(),
          'FCMNotificationData.fromJson');
    }
    actions = _actions;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['body'] = this.body;
    data['title'] = this.title;
    data['message_id'] = this.messageId;
    data['timestamp'] = this.timestamp;
    data['image'] = this.image;
    data['actions'] = this.actions;
    return data;
  }
}
