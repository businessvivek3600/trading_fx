import 'package:flutter/material.dart';
import '/constants/app_constants.dart';
import '/database/my_notification_setup.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import '../database/repositories/auth_repo.dart';

class NotificationDatabaseHelper {
  var dbName = AppConstants.notificationLocalDBName;
  var tableName = 'notifications';
  late Database database;
  Future<void> db() async {
    try {
      database = await sql.openDatabase('$dbName.db', version: 1,
          onCreate: (sql.Database database, int version) async {
        await createTables(database).then((value) => print(
            '😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍 Notification DatabaseHelper created 😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍😍'));
      });
    } catch (e) {
      print(
          '**************************** Notification DatabaseHelper could not created ***************************');
    }
  }

  Future<sql.Database> ffiDb() async {
    return sql.openDatabase('$dbName.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  Future<void> createTables(sql.Database database) async {
    await database.execute(
        """CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        userId TEXT,
        isRead INTEGER,
        data TEXT,
        createdAt TEXT,
        updatedAt TEXT)""");
  }

  //create new item
  Future<int> createItem(String? title, String? userId,
      {dynamic additional}) async {
    final data = {
      'title': title,
      'userId': userId,
      'isRead': 0,
      'data': additional,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String()
    };
    final id = await database.insert(tableName, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print('notification created in db with id $id');
    return id;
  }

  //read all table Name
  Future<List<Map<String, dynamic>>> getItems() async {
    bool isLoggedIn = sl.get<AuthProvider>().isLoggedIn();
    return (await database.query(
      tableName,
      orderBy: "id ASC",
      where: 'userId IN(?,?,?,?)',
      whereArgs: isLoggedIn
          ? [
              '${(await sl.get<AuthRepo>().getUserID()).toLowerCase()}',
              'none',
              '${topics.subscribe_to_all.name}',
              '${topics.subscribe_to_testing.name}'
            ]
          : [
              'none',
              '${topics.subscribe_to_all.name}',
              '${topics.subscribe_to_testing.name}',
              '${topics.platinum.name}',
            ],
    ))
        .reversed
        .toList();
  }

  //Get a single item by id
  //we don't use this method, it is for you if you want it
  Future<List<Map<String, dynamic>>> getItem(int id) async {
    return await database.query(tableName,
        where: "id=?", whereArgs: [id], limit: 1);
  }

  //update a single item by id
  Future<int> updateItem(int id, Map<String, dynamic> dataToUpdate) async {
    Map<String, dynamic> data = {
      ...dataToUpdate,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    final result =
        await database.update(tableName, data, where: "id= ?", whereArgs: [id]);
    return result;
  }

  //Delete
  Future<void> deleteItem(int id) async {
    try {
      await database.delete(tableName, where: "id = ?", whereArgs: [id]);
    } catch (e) {
      debugPrint('Something went wrong when deleting an item: $e');
    }
  }

  //Stream on getItems
  Future<List<Map<String, dynamic>>> listenToSqlNotifications() async {
    // await getItems().then((value) => value.forEach((element) {
    //       deleteItem(element['id']);
    //     }));
    ///: get only current user notifications
    // await database.delete(tableName);
    getItems().asStream().listen((event) {
      print('this is get items steam , ${event.length}');
      // event.map((e) async => await deleteItem(e['id']));
    });
    return getItems();
  }
}
