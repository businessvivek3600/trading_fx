import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class CashWalletRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  CashWalletRepo({required this.dioClient, required this.sharedPreferences});

  /// :Subscription History
  Future<ApiResponse> getCashWallet(Map<String, dynamic> map) async {
    try {
      Response response =
          await dioClient.post(AppConstants.cashWallet, token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///coin payment
  Future<ApiResponse> getCoinPaymentFundRequest(
      Map<String, dynamic> map) async {
    try {
      Response response = await dioClient
          .post(AppConstants.getCoinPaymentFundRequest, token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> coinPaymentSubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.coinPaymentSubmit,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> transferCashToOther(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.transferCashToOther,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///card payment
  Future<ApiResponse> getCardPaymentFundRequest(
      Map<String, dynamic> map) async {
    try {
      Response response = await dioClient
          .post(AppConstants.getCardPaymentFundRequest, token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getCardPaymentOrderId(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(
          AppConstants.cashWalletCardPaymentFundRequestSubmit,
          token: true,
          data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getNGCashWalletData() async {
    try {
      Response response = await dioClient
          .post(AppConstants.getNGCashWalletFundRequest, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> addFundFromNGCashWallet(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(
          AppConstants.addFundFromNGCashWalletFundSubmit,
          token: true,
          data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> hitPaymentResponse(String url) async {
    try {
      Response response = await dioClient.get(url);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
