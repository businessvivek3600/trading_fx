import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '/utils/default_logger.dart';
import '../utils/app_web_view_page.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/fund_request_model.dart';
import '/database/repositories/cash_wallet_repo.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/toasts.dart';

import '../database/model/response/cash_wallet_history_model.dart';

class CashWalletProvider extends ChangeNotifier {
  final CashWalletRepo cashWalletRepo;
  CashWalletProvider({required this.cashWalletRepo});
  List<CashWalletHistory> history = [];
  Map<String, dynamic> paymentTypes = {};
  double walletBalance = 0.0;
  double minimum_transfer = 0.0;
  double minimum_transferNG = 0.0;
  double transaction_per = 0.0;
  bool loadingWallet = false;
  bool btn_fund_coinpayment = false;
  bool btn_fund_card = false;
  bool btn_fund_cash_wallet = false;

  int cashWalletPage = 0;
  bool loadingCashWallet = false;
  int totalCashWallet = 0;

  Future<void> getCashWallet([bool showLoading = false]) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.cashWallet);
    List<CashWalletHistory> _history = [];
    Map? map;
    loadingWallet = showLoading;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse = await cashWalletRepo
          .getCashWallet({'page': cashWalletPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getCashWalletHistory');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.cashWallet, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCashWalletHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.cashWallet))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCashWalletHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['wallet_balance'] != null && map['wallet_balance'] != '') {
            walletBalance = double.parse(map['wallet_balance'] ?? '0');
            minimum_transfer = double.parse(map['minimum_transfer'] ?? '0.0');
            notifyListeners();
          }
        } catch (e) {
          print('getCashWalletHistory Error in balance $e');
        }

        try {
          if (map['btn_fund_coinpayment'] != null) {
            btn_fund_coinpayment = map['btn_fund_coinpayment'] == 1;
            notifyListeners();
          }
          if (map['btn_fund_card'] != null) {
            btn_fund_card = map['btn_fund_card'] == 1;
            notifyListeners();
          }
          if (map['btn_fund_cash_wallet'] != null) {
            btn_fund_cash_wallet = map['btn_fund_cash_wallet'] == 1;
            notifyListeners();
          }
        } catch (e) {}
        try {
          if (map['totalRows'] != null && map['totalRows'] != '') {
            totalCashWallet = int.parse(map['totalRows']);
            notifyListeners();
          }
          if (map['wallet_history'] != null &&
              map['wallet_history'].isNotEmpty) {
            map['wallet_history']
                .forEach((e) => _history.add(CashWalletHistory.fromJson(e)));
            if (cashWalletPage == 0) {
              history.clear();
              history = _history;
            } else {
              history.addAll(_history);
            }
            cashWalletPage++;
            history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {}
    loadingWallet = false;
    notifyListeners();
  }

  ///cashWallet selection
  TextEditingController amountController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  ///coin payment
  bool loadingFundRequestData = false;
  List<FundRequestModel> coinfundRequests = [];
  int coinPaymentPage = 0;
  int totalCoinPayment = 0;
  Future<void> getCoinPaymentFundRequest([bool loading = false]) async {
    loadingFundRequestData = loading;
    notifyListeners();
    bool cacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.getCoinPaymentFundRequest);
    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await cashWalletRepo
          .getCoinPaymentFundRequest({'page': coinPaymentPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getCoinPaymentFundRequest');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.getCoinPaymentFundRequest,
                  syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCashWalletHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData = (await APICacheManager()
              .getCacheData(AppConstants.getCoinPaymentFundRequest))
          .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCashWalletFundRequestHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['wallet_balance'] != null && map['wallet_balance'] != '') {
            walletBalance = double.parse(map['wallet_balance']);
            notifyListeners();
          }
        } catch (e) {}
        try {
          sl.get<AuthProvider>().updateUser(map["userData"]);
        } catch (e) {}

        try {
          if (map['totalRows'] != null && map['totalRows'] != '') {
            totalCoinPayment = int.parse(map['totalRows']);
            notifyListeners();
          }
          if (map['request_history'] != null &&
              map['request_history'].isNotEmpty) {
            List<FundRequestModel> _coinfundRequests = [];
            map['request_history'].forEach(
                (e) => _coinfundRequests.add(FundRequestModel.fromJson(e)));
            if (coinPaymentPage == 0) {
              coinfundRequests.clear();
              coinfundRequests = _coinfundRequests;
            } else {
              coinfundRequests.addAll(_coinfundRequests);
            }
            coinPaymentPage++;
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
          print('getCashWalletFundRequestHistory payment types error === $e');
        }
      }
    } catch (e) {
      print('getCashWalletFundRequestHistory failed ${e}');
    }
    loadingFundRequestData = false;
    notifyListeners();
  }

  bool loadingCoinPaymentSubmit = false;
  Future<void> coinPaymentSubmit(String paymentType) async {
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        ApiResponse apiResponse = await cashWalletRepo.coinPaymentSubmit({
          'payment_type': paymentType,
          'amount': amountController.text,
        });
        Get.back();
        infoLog('coinPaymentSubmit ${apiResponse.response!.data}');
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String? redirectUrl;
          try {
            status = map["status"];
            redirectUrl = map["redirect_url"];
            if (map['is_logged_in'] == 0) {
              logOut('coinPaymentSubmit');
            }
          } catch (e) {}

          if (status) {
            Get.back();
            getCoinPaymentFundRequest(false);
            redirectUrl != null
                ? launchTheLink(redirectUrl)
                : Toasts.showErrorNormalToast('Something went wrong!');
            amountController.clear();
          } else {
            Toasts.showErrorNormalToast(map['message'].split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('coinPaymentSubmit failed ${e}');
    }
  }

  bool loadingTransferCashToOther = false;
  Future<void> transferCashToOther(String user, String amount) async {
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        ApiResponse apiResponse = await cashWalletRepo
            .transferCashToOther({'username': user, 'amount': amount});
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('transferCashToOther');
            }
          } catch (e) {}

          if (status) {
            await getCashWallet();
            Get.back();
            Toasts.showSuccessNormalToast(map['message'].split('.').first);
            amountController.clear();
          } else {
            Toasts.showErrorNormalToast(map['message'].split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      Get.back();
      print('transferCashToOther failed ${e}');
    }
  }

  ///card payment
  bool loadingCardRequestData = false;
  List<FundRequestModel> cardRequests = [];
  int cardPaymentPage = 0;
  int totalCardPayment = 0;
  String? tap_paymnet_return_url;
  String? stripe_paymnet_success_url;
  String? stripe_paymnet_cancel_url;
  Future<void> getCardPaymentFundRequest(
      [bool loading = false, int? page]) async {
    loadingCardRequestData = loading;
    notifyListeners();
    bool cacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.getCardPaymentFundRequest);
    if (page != null) cardPaymentPage = page;
    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await cashWalletRepo
          .getCardPaymentFundRequest({'page': cardPaymentPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getCardPaymentFundRequest');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.getCardPaymentFundRequest,
                  syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCardPaymentFundRequest online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData = (await APICacheManager()
              .getCacheData(AppConstants.getCardPaymentFundRequest))
          .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCashWalletFundRequestHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['wallet_balance'] != null && map['wallet_balance'] != '') {
            walletBalance = double.parse(map['wallet_balance']);
            notifyListeners();
          }
        } catch (e) {}
        try {
          sl.get<AuthProvider>().updateUser(map["userData"]);
        } catch (e) {}

        try {
          if (map['request_history'] != null &&
              map['request_history'].isNotEmpty) {
            List<FundRequestModel> _cardRequests = [];
            map['request_history'].forEach(
                (e) => _cardRequests.add(FundRequestModel.fromJson(e)));
            if (cardPaymentPage == 0) {
              cardRequests.clear();
              cardRequests = _cardRequests;
            } else {
              cardRequests.addAll(_cardRequests);
            }
            cardPaymentPage++;
            totalCardPayment = int.parse(map['totalRows'] ?? '0');
            notifyListeners();
          }
        } catch (e) {}
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
            //     'getCardPaymentFundRequest');
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
          print('getCashWalletFundRequestHistory payment types error === $e');
        }
      }
    } catch (e) {
      print('getCardPaymentFundRequest failed ${e}');
    }
    loadingCardRequestData = false;
    notifyListeners();
  }

  //Todo: submit card payment
  bool loadingNGCashWalletData = false;
  Future<void> getNGCashWalletData() async {
    loadingNGCashWalletData = true;
    notifyListeners();
    try {
      if (isOnline) {
        ApiResponse apiResponse = await cashWalletRepo.getNGCashWalletData();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';

          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('getNGCashWalletData');
            }
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}

          if (status) {
            walletBalance = double.parse(map['wallet_balance'] ?? '0');
            minimum_transferNG = double.parse(map['minimum_transfer'] ?? '0');
            transaction_per = double.parse(map['transaction_per'] ?? '0');
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('getNGCashWalletData failed ${e}');
    }
    loadingNGCashWalletData = false;
    notifyListeners();
  }

  bool loadingCardPaymentOrderId = false;
  Future<void> getCardPaymentOrderId(double amount, String paymentType,
      [int? page]) async {
    if (page != null) cardPaymentPage = page;
    loadingCardPaymentOrderId = true;
    notifyListeners();
    try {
      if (isOnline) {
        showLoading();

        ApiResponse apiResponse = await cashWalletRepo.getCardPaymentOrderId(
            {'amount': amount.toString(), 'payment_type': paymentType});
        Get.back();
        infoLog('getCardPaymentOrderId ${apiResponse.response!.data}');
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? orderId;
          String? currency;

          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('getCardPaymentOrderId');
            }
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}

          if (status) {
            try {
              orderId = map["order_id"];
              currency = map["currency"];
              var redirectUrl = map["redirect_url"];
              if (redirectUrl != '') {
                Get.back();
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
                    print('request url matched <res> $res');
                    Get.back();
                    hitPaymentResponse(
                      () => cashWalletRepo.hitPaymentResponse(res),
                      () => getCardPaymentFundRequest(true, 0),
                      tag: 'cardPaymentOrderId',
                    );

                    // getVoucherList(false);
                  },
                ));
                warningLog('redirect result from webview $res');
                // launchTheLink(redirectUrl!);
              }
              // if (currency != null && orderId != null) {
              //   Get.back();
              //   amountController.clear();
              //   Get.to(CardFormWidget(
              //       orderId: orderId, currency: currency, amount: amount));
              // }
            } catch (e) {}
          } else {
            Toasts.showErrorNormalToast(message.split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('getCardPaymentOrderId failed ${e}');
    }
    loadingCardPaymentOrderId = false;
    notifyListeners();
  }

  bool loadingAddFundFromNGCashWallet = false;
  Future<void> addFundFromNGCashWallet(String amount) async {
    try {
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse =
            await cashWalletRepo.addFundFromNGCashWallet({'amount': amount});
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirectUrl;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('addFundFromNGCashWallet');
            }
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}
          try {
            sl.get<AuthProvider>().updateUser(map["userData"]);
          } catch (e) {}
          if (status) {
            await getCashWallet();
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
      print('withdrawSubmit failed ${e}');
    }
    // loadingTransferToCashWallet = false;
    // notifyListeners();
  }

  clear() {
    history.clear();
    paymentTypes.clear();
    coinfundRequests.clear();
    amountController.clear();
    emailController.clear();
    walletBalance = 0.0;
    minimum_transfer = 0.0;
    transaction_per = 0.0;
    loadingWallet = false;
    btn_fund_coinpayment = false;
    btn_fund_card = false;
    btn_fund_cash_wallet = false;
  }
}

Future<void> hitPaymentResponse(
    Future<ApiResponse> Function() request, Future<void> Function() onSuccess,
    {String? tag}) async {
  try {
    if (isOnline) {
      showLoading(dismissable: true);
      ApiResponse apiResponse = await request();
      infoLog('hitPaymentResponse: ${apiResponse.response?.data}', tag);
      Get.back();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        Map map = apiResponse.response!.data;
        bool status = false;
        String message = '';
        try {
          status = map["status"] ?? false;
          if (map['is_logged_in'] == 0) {
            logOut('hitPaymentResponse');
          }
        } catch (e) {}
        try {
          message = map["message"] ?? '';
        } catch (e) {}

        if (status) {
          Toasts.showSuccessNormalToast(message);
          infoLog('onSuccess method called #${onSuccess}', tag);
          await onSuccess();
        } else {
          if (message.isNotEmpty) Toasts.showErrorNormalToast(message);
        }
      }
    } else {
      Toasts.showWarningNormalToast('You are offline');
    }
  } catch (e) {
    errorLog('hitPaymentResponse failed ${e}', tag);
  }
}
