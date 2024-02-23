import 'dart:convert';
import 'dart:developer';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mycarclub/utils/my_logger.dart';
import '../database/repositories/subscription_repo.dart';
import '../sl_container.dart';
import '../utils/app_web_view_page.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/voucher_model.dart';
import '/database/model/response/voucher_package_model.dart';
import '/database/model/response/voucher_package_type.dart';
import '/database/repositories/voucher_repo.dart';
import '/utils/app_default_loading.dart';
import '/utils/default_logger.dart';
import '/utils/toasts.dart';
import 'Cash_wallet_provider.dart';

class VoucherProvider extends ChangeNotifier {
  final VoucherRepo voucherRepo;
  VoucherProvider({required this.voucherRepo});
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  CarouselController carouselController = CarouselController();
  late TabController tabController;

  int currentIndex = 0;
  VoucherPackageModel? currentPackage;

  String? tap_paymnet_return_url;
  String? stripe_paymnet_success_url;
  String? stripe_paymnet_cancel_url;
  void setCurrentIndex(int page) {
    currentIndex = page;
    currentPackage = packages[page];
    notifyListeners();
  }

  void jumpToPage(dynamic page) {
    controller.jumpTo(page);
    notifyListeners();
  }

  List<VoucherModel> history = [];
  List<VoucherPackageModel> packages = [];
  Map<String, dynamic> paymentTypes = {};

  List<VoucherPackageTypeModel> package1 = [];
  List<VoucherPackageTypeModel> package2 = [];
  Map<String, dynamic> packageTypes = {};
  Map<String, dynamic> admin_per = {};
  double walletBalance = 0.0;
  String? discount_note;

  bool loadingVoucher = false;
  int voucherPage = 0;
  int totalVouchers = 0;

  Future<void> getVoucherList(bool loading, [int? page]) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.voucherList);
    List<VoucherModel> _history = [];
    List<VoucherPackageModel> _packages = [];
    Map? map;
    if (page != null) {
      voucherPage = page;
    }
    loadingVoucher = loading;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse =
          await voucherRepo.getVoucherList({'page': voucherPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getVoucherList');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.voucherList, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCommissionWalletHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.voucherList))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCommissionWalletHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          totalVouchers = int.parse(map['total'] ?? '0');
          if (map['voucher_list'] != null &&
              map['voucher_list'] != false &&
              map['voucher_list'].isNotEmpty) {
            map['voucher_list']
                .forEach((e) => _history.add(VoucherModel.fromJson(e)));
            _history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            if (voucherPage == 0) {
              history.clear();
              history = _history;
            } else {
              history.addAll(_history);
            }
            logger.i('total: ${history.length}');

            notifyListeners();
            voucherPage++;
          }
        } catch (e) {
          print('voucher_list error $e');
        }
        try {
          discount_note = map['discount_note'];
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
          if (map['package'] != null &&
              map['package'] != false &&
              map['package'].isNotEmpty) {
            map['package']
                .forEach((e) => _packages.add(VoucherPackageModel.fromJson(e)));
            packages.clear();
            packages = _packages;
            packages.sort(
                (a, b) => (a.saleType ?? '').compareTo((b.saleType ?? '')));

            notifyListeners();
          }
        } catch (e) {
          print('voucher packages error $e');
        }
        try {
          if (map['wallet'] != null && map['wallet'].isNotEmpty) {
            paymentTypes.clear();
            map['wallet'].entries.forEach(
                (e) => paymentTypes.addEntries([MapEntry(e.key, e.value)]));
            notifyListeners();
          }
        } catch (e) {
          print('voucher payment_type error $e');
        }
      }
    } catch (e) {}
    loadingVoucher = false;
    notifyListeners();
  }

  bool loadingCreateVoucherSubmit = false;
  Future<void> createVoucherSubmit({
    required String payment_type,
    String package_id = '',
    String sale_type = '',
    int noOfPin = 1,
  }) async {
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        var data = {
          'wallet_type': payment_type,
          'package_id': package_id,
          // 'sale_type': sale_type,
          // 'coupon_code':
          //     couponVerified == true ? voucherCodeController.text : '',
          'no_of_pin': noOfPin.toString()
        };
        ApiResponse apiResponse = await voucherRepo.createVoucherSubmit(data);
        infoLog('create voucher submit ${apiResponse.response?.data}');
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirect_url;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('createVoucherSubmit');
            }
          } catch (e) {}
          try {
            message = map["message"] ?? '';
            redirect_url = map["redirect_url"] ?? '';
          } catch (e) {}

          if (status) {
            await getVoucherList(false, 0);
            Get.back();
            if (redirect_url != '') {
              var res = await Get.to(WebViewExample(
                url: redirect_url,
                allowBack: false,
                allowCopy: false,
                conditions: [
                  tap_paymnet_return_url ?? '',
                  stripe_paymnet_success_url ?? '',
                  stripe_paymnet_cancel_url ?? '',
                ],
                onResponse: (res) {
                  successLog(
                      'request url matched <res> $res', 'createVoucherSubmit');
                  Get.back();
                  hitPaymentResponse(() => voucherRepo.hitPaymentResponse(res),
                      () => getVoucherList(false, 0),
                      tag: 'createVoucherSubmit');
                },
              ));
              warningLog(
                  'redirect result from webview $res', 'createVoucherSubmit');
              // launchTheLink(redirect_url!);
            } else {
              Fluttertoast.showToast(
                  msg: message.split('.').first,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white);
            }
          } else {
            Fluttertoast.showToast(
                msg: message.split('.').first,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white);
            // Toasts.showErrorNormalToast(message.split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('createVoucherSubmit failed ${e}');
    }
  }

// verify coupon
  TextEditingController voucherCodeController = TextEditingController();
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
        var path = AppConstants.verifyCouponCode;
        var data = {
          "coupon_code": couponCode,
          'sale_type': packages.first.saleType ?? ''
        };
        ApiResponse apiResponse =
            await sl.get<SubscriptionRepo>().verifyCoupon(path, data);
        infoLog('verifyCoupon online hit  ${apiResponse.response?.data}');
        // Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          String message = '';
          bool status = false;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('verifyCoupon');
            }
          } catch (e) {}
          try {
            message = map["message"] ?? '';
          } catch (e) {}

          if (status) {
            couponVerified = true;
            Toasts.showSuccessNormalToast(message);
            Get.back();
          } else {
            Toasts.showErrorNormalToast(message);
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

  clear() {
    history.clear();
    package1.clear();
    package2.clear();
    packageTypes.clear();
    walletBalance = 0.0;
    loadingVoucher = false;
  }
}
