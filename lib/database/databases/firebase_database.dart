import 'dart:io';

import '/utils/default_logger.dart';
import 'package:version/version.dart';

import 'database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabase implements MyDatabase {
  static const String TAG = 'FirebaseDatabase';
  final String collectionName;

  final String whatsNewCollection;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseDatabase({required String collection})
      : collectionName = collection,
        whatsNewCollection =
            '$collection/whats_new/whats_new_${Platform.isIOS ? 'ios' : 'android'}' {
    infoLog(
        'FirebaseDatabase constructor collection : $collection, whatsNewCollection : $whatsNewCollection',
        TAG);
  }

  void init() {
    print('FirebaseDatabase init');
  }

  //get all docs from  collection name collectionName/whats_new/whats_new
  Future<List<Map<String, dynamic>>> getAllDocs() async {
    List<Map<String, dynamic>> list = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection(whatsNewCollection).get();
      for (var doc in querySnapshot.docs) {
        list.add(doc.data());
      }
      infoLog('getAllDocs list : ${list.length}', TAG);
    } catch (e) {
      errorLog(e.toString(), TAG);
    }
    return list;
  }

  //listen all docs from             collection name collectionName/whats_new/whats_new
  Stream<List<Map<String, dynamic>>> listenAllDocs() {
    return _firestore.collection(whatsNewCollection).snapshots().map((event) {
      infoLog('listenAllDocs event : ${event.docs.length}', TAG);
      List<Map<String, dynamic>> list = [];
      for (var doc in event.docs) {
        list.add(doc.data());
      }
      infoLog('listenAllDocs list path:$whatsNewCollection : $list', TAG);
      return list;
    });
  }

// get whatsnew stream from listenall docs
  Stream<List<WhatsNewModel>> listenWhatsNew() async* {
    await for (var list in listenAllDocs()) {
      List<WhatsNewModel> whatsNewList = [];
      try {
        for (var element in list) {
          try {
            whatsNewList.add(WhatsNewModel.fromJson(element));
          } catch (e) {
            errorLog(e.toString(), TAG);
          }
        }
        whatsNewList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      } catch (e) {
        errorLog(e.toString(), TAG);
      }
      infoLog('listenWhatsNew whatsNewList : ${list.length}', TAG);
      yield whatsNewList;
    }
  }

// set new whats new model to collectionName/whats_new/whats_new
  Future<void> setWhatsNew(WhatsNewModel whatsNewModel) async {
    try {
      DocumentReference ref =
          _firestore.collection(whatsNewCollection).doc(whatsNewModel.id);
      if (!(await ref.get().then((value) => value.exists))) {
        whatsNewModel.setCreatedAt();
        await ref.set(whatsNewModel.toJson());
      } else {
        whatsNewModel.setUpdatedAt();
        await ref.update(whatsNewModel.toJson());
      }
      infoLog('setWhatsNew whatsNewModel : $whatsNewModel', TAG);
    } catch (e) {
      errorLog(e.toString(), TAG);
    }
  }
}

class WhatsNewModel {
  String id;
  Version version;
  String? title, description, link, imageUrl;
  DateTime? createdAt, updatedAt;
  int updates;

  WhatsNewModel({
    required this.id,
    required this.version,
    this.updates = 0,
    this.title,
    this.description,
    this.link,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  }) {
    updatedAt = DateTime.now();
  }

  void setVersion(String version) {
    this.version = Version.parse(version);
  }

  void setCreatedAt() {
    createdAt = DateTime.now();
  }

  void setUpdatedAt() {
    updatedAt = DateTime.now();
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setID() {
    id = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    if (title != null) {
      data['title'] = title;
    }
    data['version'] = version.toString();
    if (description != null) {
      data['description'] = description;
    }
    if (link != null) {
      data['link'] = link;
    }
    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }
    if (createdAt != null) {
      data['createdAt'] = dateTimeToTimeStamp(createdAt);
    }
    if (updatedAt != null) {
      data['updatedAt'] = dateTimeToTimeStamp(updatedAt);
    }
    return data;
  }

  factory WhatsNewModel.fromJson(Map<String, dynamic> json) {
    return WhatsNewModel(
      id: json['id'],
      version: Version.parse(json['version']),
      title: json['title'],
      description: json['description'],
      link: json['link'],
      imageUrl: json['imageUrl'],
      createdAt: timeStampToDateTime(json['createdAt']),
      updatedAt: timeStampToDateTime(json['updatedAt']),
    );
  }
}

DateTime? timeStampToDateTime(Timestamp? timestamp) {
  warningLog('timestamp : $timestamp ', 'FirebaseDatabase');
  if (timestamp == null) {
    return null;
  }
  return timestamp.toDate();
}

Timestamp? dateTimeToTimeStamp(DateTime? dateTime) {
  if (dateTime == null) {
    return null;
  }
  return Timestamp.fromDate(dateTime);
}
