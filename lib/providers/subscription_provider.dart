import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '/utils/my_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/app_web_view_page.dart';
import '/utils/default_logger.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/subscription_history_model.dart';
import '/database/model/response/subscription_package_model.dart';
import '/database/model/response/subscription_request_history_model.dart';
import '/database/repositories/subscription_repo.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/toasts.dart';
import 'Cash_wallet_provider.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepo subscriptionRepo;
  SubscriptionProvider({required this.subscriptionRepo});
  List<SubscriptionHistory> history = [];
  List<SubscriptionPackage> packages = [];
  List<SubscriptionRequestHistory> requestHistory = [];
  Map<String, dynamic> paymentTypes = {};
  double commissionMBal = 0.0;
  double amgenBal = 0.0;
  double commissionNBal = 0.0;
  double cashNBal = 0.0;
  bool customerRenewal = false;
  String? joiningPriceId;
  String? discount_note;
  String? tap_paymnet_return_url;
  String? stripe_paymnet_success_url;
  String? stripe_paymnet_cancel_url;

  ///subscription history
  bool loadingSub = false;
  int subPage = 0;
  int totalSubscriptions = 0;

  Future<void> mySubscriptions([bool? loading, int? page]) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.mySubscription);
    List<SubscriptionHistory> _history = [];
    List<SubscriptionPackage> _packages = [];
    List<SubscriptionRequestHistory> _requestHistory = [];
    Map<String, dynamic> _paymentTypes = {};
    Map? map;
    if (page != null) {
      subPage = page;
    }
    loadingSub = loading ?? true;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse =
          await subscriptionRepo.getSubscription({"page": subPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getSubscription');
          }
        } catch (e) {}

        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.mySubscription, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
            try {
              if (map?['userData'] != null) {
                sl.get<AuthProvider>().updateUser(map?['userData']);
              }
            } catch (e) {}
          }
        } catch (e) {
          print('getSubscriptionHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.mySubscription))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getSubscriptionHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['totalRows'] != null && map['totalRows'] != '') {
            totalSubscriptions = int.parse(map['totalRows'] ?? '0');
          }
          if (map['my_trades'] != null && map['my_trades'].isNotEmpty) {
            map['my_trades'].forEach((e) {
              if (!Platform.isAndroid) {
                if (e['status'] != null &&
                    !e['status'].toString().contains('6')) {
                  _history.add(SubscriptionHistory.fromJson(e));
                }
              } else {
                _history.add(SubscriptionHistory.fromJson(e));
              }
            });
            _history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            if (subPage == 0) {
              history.clear();
              history = _history;
            } else {
              history.addAll(_history);
            }
            subPage++;
            notifyListeners();
          }
        } catch (e) {}
        try {
          discount_note = map['discount_note'];
          if (map['packages'] != null && map['packages'].isNotEmpty) {
            map['packages']
                .forEach((e) => _packages.add(SubscriptionPackage.fromJson(e)));
            packages.clear();
            packages = _packages;
            notifyListeners();
          }
        } catch (e) {
          print('SubscriptionPackage error $e');
        }
        try {
          if (map['payment_return_url'] != null) {
            tap_paymnet_return_url =
                map['payment_return_url']?['tap']?['return'] ?? '';
            stripe_paymnet_success_url =
                map['payment_return_url']?['stripe']?['success'] ?? '';
            stripe_paymnet_cancel_url =
                map['payment_return_url']?['stripe']?['cancel'] ?? '';
            // successLog(
            //     'tap_paymnet_return_url tap_paymnet_return_url: $tap_paymnet_return_url  stripe_paymnet_success_url: $stripe_paymnet_success_url  stripe_paymnet_cancel_url: $stripe_paymnet_cancel_url',
            //     'getSubscription');
          }
        } catch (e) {}
        try {
          if (map['payment_type'] != null) {
            map['payment_type'].entries.toList().forEach(
                (e) => _paymentTypes.addEntries([MapEntry(e.key, e.value)]));
            paymentTypes.clear();
            paymentTypes = _paymentTypes;
            notifyListeners();
          }
        } catch (e) {
          print('payment types error === $e');
        }
      }
    } catch (e) {}
    loadingSub = false;
    notifyListeners();
  }

  ///subscription Request history
  bool loadingReqSub = false;
  int subReqPage = 0;
  int totalReqSubscriptions = 0;

  Future<void> getSubscriptionRequestHistory([bool? loading]) async {
    bool cacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.subscriptionRequestHistory);
    List<SubscriptionRequestHistory> _requestHistory = [];
    Map? map;
    loadingReqSub = loading ?? true;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse = await subscriptionRepo
          .subscriptionRequestHistory({"page": subReqPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('subscriptionRequestHistory');
          }
        } catch (e) {}

        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.subscriptionRequestHistory,
                  syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('subscriptionRequestHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData = (await APICacheManager()
              .getCacheData(AppConstants.subscriptionRequestHistory))
          .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getSubscriptionHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['totalRows'] != null && map['totalRows'] != '') {
            totalReqSubscriptions =
                int.parse(map['total_subscriptions'] ?? '0');
          }
          if (map['package_request'] != null &&
              map['package_request'].isNotEmpty) {
            map['package_request'].forEach((e) =>
                _requestHistory.add(SubscriptionRequestHistory.fromJson(e)));
            _requestHistory
                .sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            if (subReqPage == 0) {
              requestHistory.clear();
              requestHistory = _requestHistory;
            } else {
              requestHistory.addAll(_requestHistory);
            }
            subReqPage++;
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {}
    loadingReqSub = false;
    notifyListeners();
  }

  ///subscription selection
  TextEditingController typeController = TextEditingController();
  TextEditingController voucherCodeController = TextEditingController();
  SubscriptionPackage? selectedPackage;
  String? selectedPaymentTypeKey;
  setSelectedTypeKey(val) {
    selectedPaymentTypeKey = val;
    couponVerified = null;
    notifyListeners();
  }

  ///buy trade
  Future<void> buyTrade(String epin) async {
    try {
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse =
            await subscriptionRepo.buySubscription({'epin': epin});
        infoLog('buySubscription online hit  ${apiResponse.response?.data}');
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirectUrl;
          String? orderId;
          try {
            status = map["status"];
            redirectUrl = map["redirect_url"];
            message = map["message"];
            orderId = map["order_id"];
            if (map['is_logged_in'] == 0) {
              logOut('buySubscription');
            }
          } catch (e) {}

          try {
            if (status) {
              if (orderId == null) {
                await mySubscriptions(false);
              }
              if (redirectUrl != null && redirectUrl != '') {
                // errorLog('redirect url $redirectUrl', 'buySubscription');
                var res = await Get.to(WebViewExample(
                  url: redirectUrl,
                  allowBack: false,
                  allowCopy: false,
                  conditions: [
                    tap_paymnet_return_url ?? '',
                    stripe_paymnet_success_url ?? '',
                    stripe_paymnet_cancel_url ?? '',
                  ],
                  onResponse: (res) {
                    successLog(
                        'request url matched <res> $res', 'buySubscription');
                    Get.back();
                    hitPaymentResponse(
                        () => subscriptionRepo.hitPaymentResponse(res),
                        () => mySubscriptions(false, 0),
                        tag: 'buySubscription');
                    // getVoucherList(false);
                  },
                ));
                warningLog(
                    'redirect result from webview $res', 'buySubscription');
                // launchTheLink(redirectUrl!);
              }
              //else if (orderId != null) {
              //   Get.to(CardFormWidget(
              //       subscriptionPackage: package, orderId: orderId));
              // }
              else {
                Fluttertoast.showToast(
                  msg: message.split('.').first,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.green,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: message.split('.').first,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red,
              );
            }
            Fluttertoast.showToast(
              msg: message.split('.').first,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
            );
            // status==false
            //     ? Toasts.showSuccessNormalToast(message.split('.').first)
            //     : Toasts.showErrorNormalToast(message.split('.').first);
          } catch (e) {
            print('buySubscription online hit failed \n $e');
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1),
            () => Toasts.showWarningNormalToast('You are offline'));
      }
    } catch (e) {
      print('buySubscription failed ${e}');
    }
  }

  ///cancel trade
  Future<void> cancelTrade(String id) async {
    try {
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse =
            await subscriptionRepo.cancelSubscription({'order_id': id});
        infoLog('cancelSubscription online hit  ${apiResponse.response?.data}');
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          try {
            status = map["status"];
            message = map["message"];
            if (map['is_logged_in'] == 0) {
              logOut('cancelSubscription');
            }
          } catch (e) {}

          try {
            if (status) {
              await mySubscriptions(false, 0);
              Fluttertoast.showToast(
                msg: message.split('.').first,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
              );
            } else {
              Fluttertoast.showToast(
                msg: message.split('.').first,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red,
              );
            }
            Fluttertoast.showToast(
              msg: message.split('.').first,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
            );
            // status==false
            //     ? Toasts.showSuccessNormalToast(message.split('.').first)
            //     : Toasts.showErrorNormalToast(message.split('.').first);
          } catch (e) {
            print('cancelSubscription online hit failed \n $e');
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1),
            () => Toasts.showWarningNormalToast('You are offline'));
      }
    } catch (e) {
      print('cancelSubscription failed ${e}');
    }
  }

  Future<void> buySubscription(SubscriptionPackage package) async {
    try {
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse = await subscriptionRepo.buySubscription({
          "package": selectedPackage?.packageId ?? ' ',
          "payment_type": selectedPaymentTypeKey ?? '',
          "epin_code": selectedPaymentTypeKey == 'E-Pin'
              ? voucherCodeController.text
              : '',
          'coupon_code': selectedPaymentTypeKey != 'E-Pin'
              ? voucherCodeController.text
              : '',
        });
        infoLog('buySubscription online hit  ${apiResponse.response?.data}');
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirectUrl;
          String? orderId;
          try {
            status = map["status"];
            redirectUrl = map["redirect_url"];
            message = map["message"];
            orderId = map["order_id"];
            if (map['is_logged_in'] == 0) {
              logOut('buySubscription');
            }
          } catch (e) {}

          try {
            if (status) {
              if (orderId == null) {
                await mySubscriptions(false);
              }
              Get.back();
              if (redirectUrl != null && redirectUrl != '') {
                // errorLog('redirect url $redirectUrl', 'buySubscription');
                var res = await Get.to(WebViewExample(
                  url: redirectUrl,
                  allowBack: false,
                  allowCopy: false,
                  conditions: [
                    tap_paymnet_return_url ?? '',
                    stripe_paymnet_success_url ?? '',
                    stripe_paymnet_cancel_url ?? '',
                  ],
                  onResponse: (res) {
                    successLog(
                        'request url matched <res> $res', 'buySubscription');
                    Get.back();
                    hitPaymentResponse(
                        () => subscriptionRepo.hitPaymentResponse(res),
                        () => mySubscriptions(false, 0),
                        tag: 'buySubscription');
                    // getVoucherList(false);
                  },
                ));
                warningLog(
                    'redirect result from webview $res', 'buySubscription');
                // launchTheLink(redirectUrl!);
              }
              //else if (orderId != null) {
              //   Get.to(CardFormWidget(
              //       subscriptionPackage: package, orderId: orderId));
              // }
              else {
                Fluttertoast.showToast(
                    msg: message.split('.').first,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green);
              }
            } else {
              Fluttertoast.showToast(
                  msg: message.split('.').first,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.red);
            }
            Fluttertoast.showToast(
                msg: message.split('.').first,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red);
            // status==false
            //     ? Toasts.showSuccessNormalToast(message.split('.').first)
            //     : Toasts.showErrorNormalToast(message.split('.').first);
          } catch (e) {
            print('buySubscription online hit failed \n $e');
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1),
            () => Toasts.showWarningNormalToast('You are offline'));
      }
    } catch (e) {
      print('buySubscription failed ${e}');
    }
  }

  ///apple payment

  final List<PurchaseDetails> purchases = [];
  final List<ProductDetails> pendingPurchases = [];
  bool cancelingPendingPurchase = false;

  setPendingPurchase(ProductDetails val, {bool remove = false}) {
    if (remove) {
      pendingPurchases.remove(val);
    } else {
      pendingPurchases.add(val);
    }
    notifyListeners();
  }

  setPurchases(PurchaseDetails val, {bool remove = false}) {
    if (remove) {
      purchases.remove(val);
    } else {
      purchases.add(val);
    }
    notifyListeners();
  }

  setCancelingPendingPurchase(bool val) {
    cancelingPendingPurchase = val;
    notifyListeners();
  }

  ///api hit for joining package submisstion
  Future<void> submitJoinigPackageIosPurchase(Map<String, dynamic> data) async {
    try {
      ApiResponse apiResponse = await subscriptionRepo
          .submitJoinigPackageIosPurchase(AppConstants.applePayJoining, data);
      infoLog(
          'submitJoinigPackageIosPurchase online hit  ${apiResponse.response?.data}');
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        Map map = apiResponse.response!.data;
        bool status = false;
        String message = '';
        try {
          status = map["status"];
          if (map['is_logged_in'] == 0) {
            logOut('submitJoinigPackageIosPurchase');
          }
        } catch (e) {}
        try {
          message = map["message"];
        } catch (e) {}
        try {
          if (status) {
            Toasts.showSuccessNormalToast(message);
            await mySubscriptions(false, 0);
            Get.back();
          } else {
            Toasts.showErrorNormalToast(message);
          }
        } catch (e) {
          errorLog('submitJoinigPackageIosPurchase online hit failed \n $e');
        }
      }
    } catch (e) {
      logger.e('submitJoinigPackageIosPurchase failed ', error: e);
    }
  }

  ///api hit for subscription package submisstion
  Future<void> submitSubscriptionPackageIosPurchase(
      Map<String, dynamic> data) async {
    try {
      ApiResponse apiResponse =
          await subscriptionRepo.submitJoinigPackageIosPurchase(
              AppConstants.applePaySubscription, data);
      infoLog(
          'submitSubscriptionPackageIosPurchase online hit  ${apiResponse.response?.data}');
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        Map map = apiResponse.response!.data;
        bool status = false;
        String message = '';
        try {
          status = map["status"];
          if (map['is_logged_in'] == 0) {
            logOut('submitSubscriptionPackageIosPurchase');
          }
        } catch (e) {}
        try {
          message = map["message"];
        } catch (e) {}
        try {
          if (status) {
            Fluttertoast.showToast(
                msg: message,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green);
            await mySubscriptions(false, 0);
            // Get.back();
          } else {
            Fluttertoast.showToast(
                msg: message,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red);
          }
        } catch (e) {
          errorLog(
              'submitSubscriptionPackageIosPurchase online hit failed \n $e');
        }
      }
    } catch (e) {
      logger.e('submitSubscriptionPackageIosPurchase failed ', error: e);
    }
  }

// verify coupon
  bool loadingVerifyCoupon = false;
  bool? couponVerified;
  Future<void> verifyCoupon(String couponCode) async {
    couponVerified = null;
    try {
      if (isOnline) {
        loadingVerifyCoupon = true;
        notifyListeners();
        // await Future.delayed(Duration(seconds: 3));
        // couponVerified = true;
        // showLoading(dismissable: true);
        var path = selectedPaymentTypeKey == 'E-Pin'
            ? AppConstants.verifyVoucherCode
            : AppConstants.verifyCouponCode;
        var data = selectedPaymentTypeKey == 'E-Pin'
            ? {
                "voucher_code": couponCode,
                "sale_type": packages.first.sale_type ?? ''
              }
            : {"coupon_code": couponCode};
        ApiResponse apiResponse =
            await subscriptionRepo.verifyCoupon(path, data);
        infoLog('verifyCoupon online hit  ${apiResponse.response?.data}');
        // Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          String message = '';
          bool status = false;
          try {
            status = map["status"];
            message = map["message"] ?? '';

            if (map['is_logged_in'] == 0) {
              logOut('verifyCoupon');
            }
          } catch (e) {}

          if (status == true) {
            couponVerified = true;
            // Toasts.showSuccessNormalToast(message);
            Fluttertoast.showToast(
                msg: message,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green);
            Get.back();
          } else {
            couponVerified = false;

            Fluttertoast.showToast(
                msg: message,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red);
            // Toasts.showErrorNormalToast(message);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('verifyCoupon failed ${e}');
    }
    loadingVerifyCoupon = false;
    notifyListeners();
  }

  // Future<void> hitPaymentResponses(url) async {
  //   try {
  //     if (isOnline) {
  //       showLoading(dismissable: true);
  //       ApiResponse apiResponse =
  //           await subscriptionRepo.hitPaymentResponse(url);
  //       infoLog(
  //           'create subscription hitPaymentResponse: ${apiResponse.response?.data}');
  //       Get.back();
  //       if (apiResponse.response != null &&
  //           apiResponse.response!.statusCode == 200) {
  //         Map map = apiResponse.response!.data;
  //         bool status = false;
  //         String message = '';
  //         try {
  //           status = map["status"];
  //           if (map['is_logged_in'] == 0) {
  //             logOut('hitPaymentResponse');
  //           }
  //         } catch (e) {}
  //         try {
  //           message = map["message"] ?? '';
  //         } catch (e) {}

  //         if (status) {
  //           await getSubscription(false);
  //           Get.back();
  //         } else {
  //           Toasts.showErrorNormalToast(message);
  //         }
  //       }
  //     } else {
  //       Toasts.showWarningNormalToast('You are offline');
  //     }
  //   } catch (e) {
  //     print('createVoucherSubmit failed ${e}');
  //   }
  // }

  ///TODO: Stripe Payment

  clear() {
    history = [];
    packages = [];
    requestHistory = [];
    subPage = 0;
    totalSubscriptions = 0;
    subReqPage = 0;
    totalReqSubscriptions = 0;

    paymentTypes = {};
    commissionMBal = 0.0;
    amgenBal = 0.0;
    commissionNBal = 0.0;
    cashNBal = 0.0;
    loadingSub = false;
    typeController = TextEditingController();
    voucherCodeController = TextEditingController();
    selectedPackage = null;
    selectedPaymentTypeKey = null;
  }
}

/// save pending purchase to local db
Future<void> savePendingPurchase(PurchaseDetails purchaseDetails) async {
  var prefs = await SharedPreferences.getInstance();
  // print(
  // 'savePendingPurchase pendingPurchases ${prefs.getStringList('pendingPurchases') ?? []} ${purchaseDetailsToJson(purchaseDetails)}');
  try {
    var pendingPurchases = await getPendingPurchases();

    if (pendingPurchases
        .any((element) => element.productID == purchaseDetails.productID)) {
      updatePendingPurchase(purchaseDetails);
      return;
    } else {
      pendingPurchases.add(purchaseDetails);
      prefs.setStringList(
          'pendingPurchases',
          pendingPurchases
              .map((e) => jsonEncode(purchaseDetailsToJson(e)))
              .toList());
    }
    logger.w(
        'savePendingPurchase pendingPurchases ${pendingPurchases.map((e) => e.productID).toList()}');
  } catch (e) {
    logger.e('savePendingPurchase failed ', error: e);
  }
}

///get pending purchase from local db
Future<List<PurchaseDetails>> getPendingPurchases() async {
  var prefs = await SharedPreferences.getInstance();
  List<PurchaseDetails> pendingPurchases = [];
  try {
    var pendingPurchasesJson = prefs.getStringList('pendingPurchases') ?? [];
    for (var element in pendingPurchasesJson) {
      pendingPurchases.add(purchaseDetailsFromJson(jsonDecode(element)));
    }
    logger.w(
        'getPendingPurchases pendingPurchases ${pendingPurchases.map((e) => e.productID).toList()}');
  } catch (e) {
    logger.e('getPendingPurchases failed ', error: e);
  }
  return pendingPurchases;
}

///remove pending purchase from local db
Future<void> removePendingPurchase(PurchaseDetails purchaseDetails) async {
  var prefs = await SharedPreferences.getInstance();
  try {
    var pendingPurchases = prefs.getStringList('pendingPurchases') ?? [];
    pendingPurchases.removeWhere((element) =>
        purchaseDetailsFromJson(jsonDecode(element)).productID ==
        purchaseDetails.productID);
    prefs.setStringList('pendingPurchases', pendingPurchases);
    logger.w(
        'removePendingPurchase pendingPurchases ${purchaseDetails.productID}');
  } catch (e) {
    logger.e('removePendingPurchase failed ', error: e);
  }
}

///update existing purchase from local db
Future<void> updatePendingPurchase(PurchaseDetails purchaseDetails) async {
  var prefs = await SharedPreferences.getInstance();
  try {
    var pendingPurchases = prefs.getStringList('pendingPurchases') ?? [];
    pendingPurchases.removeWhere((element) =>
        purchaseDetailsFromJson(jsonDecode(element)).productID ==
        purchaseDetails.productID);
    pendingPurchases.add(jsonEncode(purchaseDetailsToJson(purchaseDetails)));
    prefs.setStringList('pendingPurchases', pendingPurchases);
  } catch (e) {
    logger.e('updatePendingPurchase failed ', error: e);
  }
}

/// purchase detail to json
Map<String, dynamic> purchaseDetailsToJson(PurchaseDetails purchaseDetails) {
  return {
    'productID': purchaseDetails.productID,
    'transactionDate': purchaseDetails.transactionDate,
    'purchaseID': purchaseDetails.purchaseID,
    'verificationData':
        purchaseVerificationDataToJson(purchaseDetails.verificationData),
    'status': purchaseDetails.status.name,
    'pendingCompletePurchase': purchaseDetails.pendingCompletePurchase,
    'hashCode': purchaseDetails.hashCode,
  };
}

/// json to purchase detail
PurchaseDetails purchaseDetailsFromJson(Map<String, dynamic> json) {
  return PurchaseDetails(
    productID: json['productID'],
    transactionDate: json['transactionDate'],
    purchaseID: json['purchaseID'],
    verificationData:
        purchaseVerificationDataFromJson(json['verificationData']),
    status: PurchaseStatus.values.firstWhere((e) => e.name == json['status'],
        orElse: () => PurchaseStatus.error),
  );
}

/// PurchaseVerificationData to json
Map<String, dynamic> purchaseVerificationDataToJson(
    PurchaseVerificationData purchaseVerificationData) {
  return {
    'localVerificationData': purchaseVerificationData.localVerificationData,
    'serverVerificationData': purchaseVerificationData.serverVerificationData,
    'source': purchaseVerificationData.source,
  };
}

/// PurchaseVerificationData from json
PurchaseVerificationData purchaseVerificationDataFromJson(
    Map<String, dynamic> json) {
  return PurchaseVerificationData(
    localVerificationData: json['localVerificationData'],
    serverVerificationData: json['serverVerificationData'],
    source: json['source'],
  );
}
