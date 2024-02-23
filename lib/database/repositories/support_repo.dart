import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class SupportRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  SupportRepo({required this.dioClient, required this.sharedPreferences});

  /// :support
  Future<ApiResponse> getSupport() async {
    try {
      Response response =
          await dioClient.post(AppConstants.support, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> newTicketSubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.newTicketSubmit,
          data: data, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getTicketDetails(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.ticketDetail,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> ticketReplySubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.ticketReplySubmit,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
