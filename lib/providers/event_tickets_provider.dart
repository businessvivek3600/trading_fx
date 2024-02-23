import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/event_tickets_model.dart';
import '/database/model/response/event_tickets_request_model.dart';
import '/utils/app_default_loading.dart';
import '/utils/toasts.dart';

import '../database/repositories/event_tickets_repo.dart';

class EventTicketsProvider extends ChangeNotifier {
  final EventTicketRepo eventTicketRepo;
  EventTicketsProvider({required this.eventTicketRepo});
  List<EventTickets> eventsList = [];
  List<EventTicketsRequests> ticketRequests = [];
  List<Map<String, dynamic>> packages = [];
  Map<String, dynamic> paymentTypes = {};
  double walletBalance = 0.0;
  bool loadingMyTickets = false;
  int eventTicketsPage = 0;
  int totalRequests = 0;
  double fileSize = 0.0;

  Future<void> getEventTickets(bool loading, [int? page]) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.myEventTickets);
    List<EventTickets> _events = [];
    List<EventTicketsRequests> _ticketRequests = [];
    Map? map;
    loadingMyTickets = loading;
    if (page != null) {
      eventTicketsPage = page;
    }
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse = await eventTicketRepo
          .getEventTickets({'page': eventTicketsPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getEventTickets');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.myEventTickets, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getEventTickets online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.myEventTickets))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getEventTickets not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['package'] != null &&
              map['package'] != false &&
              map['package'].isNotEmpty) {
            packages.clear();
            map['package'].forEach((e) => packages.add(e));
            notifyListeners();
          }
        } catch (e) {
          print('payment_type error === $e');
        }
        try {
          // walletBalance = double.parse(map['wallet_balance'] ?? '0');
          fileSize = double.tryParse(map['file_size'] ?? '0') ?? 0.0;
          print('fileSize === $fileSize');
        } catch (e) {}
        try {
          if (map['request_list'] != null &&
              map['request_list'] != false &&
              map['request_list'].isNotEmpty) {
            map['request_list'].forEach(
                (e) => _ticketRequests.add(EventTicketsRequests.fromJson(e)));
            _ticketRequests
                .sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            if (eventTicketsPage == 0) {
              ticketRequests.clear();
              ticketRequests = _ticketRequests;
            } else {
              ticketRequests.addAll(_ticketRequests);
            }
            totalRequests = int.parse(map['total'] ?? '0');
            eventTicketsPage++;
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {}
    loadingMyTickets = false;
    notifyListeners();
  }

  ///buy pin from multipart
  bool loadingBuyPin = false;
  Future<void> buyPinRequest(
      Map<String, dynamic> data, Map<String, dynamic> filePath) async {
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        ApiResponse apiResponse =
            await eventTicketRepo.buyPinRequest(data, filePath);
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('buyPinRequest');
            }
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}

          if (status) {
            await getEventTickets(true, 0).then((value) {
              Get.back();
            });
          }
          message = message.split('.').first;
          status
              ? Fluttertoast.showToast(
                  msg: message,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0)
              : Fluttertoast.showToast(
                  msg: message,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      Toasts.showErrorNormalToast('Something went wrong');
      print('buyPinRequest failed ${e}');
    }
  }

  ///myEventTickets selection
  TextEditingController amountController = TextEditingController();
  EventTickets? selectedTicket;
  bool loadingBuyEventTickets = false;
  Future<void> buyEventTicketsRequest(id) async {
    Map? map;
    loadingBuyEventTickets = true;
    notifyListeners();

    if (isOnline) {
      ApiResponse apiResponse =
          await eventTicketRepo.buyEventTickets({'event_id': id});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('buyEventTicketsRequest');
          }
        } catch (e) {}
        if (status && map != null) {
          try {
            selectedTicket = EventTickets.fromJson(map['event']);
            notifyListeners();
          } catch (e) {}
          try {
            if (map['wallet_balance'] != null && map['wallet_balance'] != '') {
              walletBalance = double.parse(map['wallet_balance']);
              notifyListeners();
            }
          } catch (e) {}
          try {
            if (map['payment_type'] != null) {
              paymentTypes.clear();
              map['payment_type'].entries.toList().forEach(
                  (e) => paymentTypes.addEntries([MapEntry(e.key, e.value)]));
              notifyListeners();
            }
          } catch (e) {
            print('payment_type error === $e');
          }
        }
      }
    } else {
      Toasts.showWarningNormalToast('You are offline');
    }
    loadingBuyEventTickets = false;
    notifyListeners();
  }

  bool loadingBuyEventTicketSubmit = false;
  Future<void> buyTicketSubmit(
      {required String payment_type,
      required String amount,
      required int member,
      required String event_id}) async {
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        ApiResponse apiResponse = await eventTicketRepo.buyTicketSubmit({
          'event_id': event_id,
          'amount': amount,
          'member': member.toString(),
          'payment_type': payment_type,
        });
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('buyTicketSubmit');
            }
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}

          if (status) {
            await getEventTickets(false);
            Get.back();
          }

          status
              ? Toasts.showSuccessNormalToast(message.split('.').first)
              : Toasts.showErrorNormalToast(message.split('.').first);
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      Toasts.showErrorNormalToast('Something went wrong');
      print('buyTicketSubmit failed ${e}');
    }
  }

  clear() {
    eventsList.clear();
    ticketRequests.clear();
    paymentTypes.clear();
    amountController.clear();
    walletBalance = 0.0;
    loadingMyTickets = false;
    selectedTicket = null;
  }
}
