import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class CommissionWalletRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  CommissionWalletRepo(
      {required this.dioClient, required this.sharedPreferences});

  /// :Subscription History
  Future<ApiResponse> getCommissionWallet(Map<String, dynamic> map) async {
    try {
      Response response = await dioClient.post(AppConstants.commissionWallet,
          token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getCommissionWithdrawRequest() async {
    try {
      Response response = await dioClient
          .post(AppConstants.getCommissionWithdrawRequest, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> withdrawRequestHistory(Map<String, dynamic> map) async {
    try {
      Response response = await dioClient
          .post(AppConstants.withdrawRequestHistory, token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> commissionWithdrawRequestSubmit(
      Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(
          AppConstants.commissionWithdrawRequestSubmit,
          token: true,
          data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> transferToCashWallet(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(
          AppConstants.commissionTransferToCashWallet,
          token: true,
          data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for verify Email
  Future<ApiResponse> getWithdrawEmailToken() async {
    try {
      Response response =
          await dioClient.post(AppConstants.getWithdrawEmailToken, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
