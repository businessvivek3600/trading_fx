import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class VoucherRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  VoucherRepo({required this.dioClient, required this.sharedPreferences});

  /// :Subscription History
  Future<ApiResponse> getVoucherList(Map<String, dynamic> map) async {
    try {
      Response response = await dioClient.post(AppConstants.voucherList,
          token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getPackageType() async {
    try {
      Response response =
          await dioClient.post(AppConstants.createVoucher, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> createVoucherSubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.createVoucherSubmit,
          token: true, data: data);

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
