import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class EventTicketRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  EventTicketRepo({required this.dioClient, required this.sharedPreferences});

  /// :Subscription History
  Future<ApiResponse> getEventTickets(Map<String, String> map) async {
    try {
      Response response = await dioClient.post(AppConstants.myEventTickets,
          token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> buyEventTickets(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.buyEventTickets,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> buyPinRequest(
      Map<String, dynamic> data, Map<String, dynamic> filePath) async {
    try {
      Response response = await dioClient.post(AppConstants.buyEventTickets,
          token: true, data: data, files: filePath);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> buyTicketSubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient
          .post(AppConstants.buyEventTicketsSubmit, token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
