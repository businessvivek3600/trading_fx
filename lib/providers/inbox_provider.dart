import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/cupertino.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/inbox_model.dart';
import '/database/model/response/inbox_model.dart';
import '/utils/default_logger.dart';

import '../database/repositories/inbox_repo.dart';

class InboxProvider extends ChangeNotifier {
  final InboxRepo inboxRepo;
  InboxProvider({required this.inboxRepo});

  //payout by date
  int inboxPage = 0;
  int totalInbox = 0;
  bool loadingInbox = false;
  bool loadingMoreInbox = false;
  bool hasMoreInbox = true;
  List<InboxModel> inbox = [];

  Future<void> getMyInbox(bool loading, {bool? loadingMore}) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.myInbox);
    Map? map;
    loadingInbox = loading;
    //check for user hits load more
    if (loadingMore != null) {
      loadingMoreInbox = loadingMore;
    }
    notifyListeners();
    //if user is online
    if (isOnline) {
      //hit http post
      ApiResponse apiResponse =
          await inboxRepo.getMyInbox({'page': inboxPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        //check for status and logged in value
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            //logout and clear all data including cache
            logOut('myInbox');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.myInbox, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('myInbox online hit failed \n $e');
        }
      }
    }
    //if user is not online but data exist in cache
    else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.myInbox)).syncData;
      map = jsonDecode(cacheData);
    }
    // neither online nor cache exist
    else {
      print('myInbox not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          totalInbox = int.parse(map['total'] ?? '0');
        } catch (e) {}
        try {
          if (map["data"] != null &&
              map["data"] != false &&
              map["data"].isNotEmpty) {
            //if data is valid
            // increase inbox page by one
            inboxPage++;
            // if user is hitting post data for first time  clear existing payouts. this will also use on refresh data
            if (inboxPage <= 1) {
              inbox.clear();
            }
            warningLog(map["data"].length.toString());
            map["data"].forEach((e) {
              var payout = InboxModel.fromJson(e);
              inbox.add(payout);
            });
            inbox.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            hasMoreInbox = totalInbox > inbox.length;
            notifyListeners();
          }
        } catch (e) {
          print('create inbox list error $e');
        }
      }
    } catch (e) {}
    loadingInbox = false;
    loadingMoreInbox = false;

    notifyListeners();
  }

  clear() {
    inbox.clear();
    inboxPage = 0;
    totalInbox = 0;
    loadingInbox = false;
    loadingMoreInbox = false;
    hasMoreInbox = true;
  }
}
