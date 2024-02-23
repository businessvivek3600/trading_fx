import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class DashboardRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  DashboardRepo({required this.dioClient, required this.sharedPreferences});

  ///:getCustomerDashboard
  Future<ApiResponse> getCustomerDashboard() async {
    try {
      Response response =
          await dioClient.post(AppConstants.customerDashboard, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:tradeIdeas
  Future<ApiResponse> tradeIdeas(Map<String, String> map) async {
    try {
      Response response =
          await dioClient.post(AppConstants.tradeIdeas, token: true, data: map);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:tradeIdeasDetails
  Future<ApiResponse> tradeIdeasDetails(Map<String, String> map) async {
    try {
      Response response = await dioClient.post(AppConstants.tradeIdeasDetails,
          token: true, data: map);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:Registration
  Future<ApiResponse> getDownloadsData() async {
    try {
      Response response =
          await dioClient.post(AppConstants.downloads, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:Registration
  Future<ApiResponse> changePlacement(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.changePlacement,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///card-details
  Future<ApiResponse> getCardDetails(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.cardDetails,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///card-details
  Future<ApiResponse> cardDetailsSubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.cardDetailsSubmit,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///income activity
  Future<ApiResponse> myIncomeActivity(String path,Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(path,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///loginLogs activity
  Future<ApiResponse> loginLogs(Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(AppConstants.loginLogs, token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  String getPDFLink() => sharedPreferences.getString(SPConstants.pdfLink) ?? "";

  String getPPTLink() => sharedPreferences.getString(SPConstants.pptLink) ?? "";

  String getPromoVideoLink() =>
      sharedPreferences.getString(SPConstants.promoVideoLink) ?? "";
  String getIntroVideoLink() =>
      sharedPreferences.getString(SPConstants.introVideoLink) ?? "";

  void setPDFLink(String id) async =>
      await sharedPreferences.setString(SPConstants.pdfLink, id);

  void setPPTLink(String id) async =>
      await sharedPreferences.setString(SPConstants.pptLink, id);

  void setPromotionalVideoLink(String id) async =>
      await sharedPreferences.setString(SPConstants.promoVideoLink, id);

  void setIntroVideoLink(String id) async =>
      await sharedPreferences.setString(SPConstants.introVideoLink, id);

  Future<bool> clearSharedData() async {
    sharedPreferences.remove(SPConstants.userToken);
    sharedPreferences.remove(SPConstants.user);
    return true;
  }
}
