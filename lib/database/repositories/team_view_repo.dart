import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class TeamViewRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  TeamViewRepo({required this.dioClient, required this.sharedPreferences});

  ///get down lines
  Future<ApiResponse> getDownLines(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.getDownLines,
          data: data, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///get team member
  Future<ApiResponse> getTeamMember(Map<String, String> map) async {
    try {
      Response response =
          await dioClient.post(AppConstants.myTeam, token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///get directMember
  Future<ApiResponse> directMember(Map<String, String> map) async {
    try {
      Response response = await dioClient.post(AppConstants.directMember,
          token: true, data: map);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///get team member
  Future<ApiResponse> sendInboxMessageToUser(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient
          .post(AppConstants.sendInboxMessageToUser, token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///get team member
  Future<ApiResponse> getGenerationAnalyzer(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient
          .post(AppConstants.getGenerationAnalyzer, token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///get matrixvAnalyzer
  Future<ApiResponse> liquidUser(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.liquidUser,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// liquidUserAutoPlace
  Future<ApiResponse> liquidUserAutoPlace(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.liquidUserAutoPlace,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///get matrixvAnalyzer
  Future<ApiResponse> matrixAnalyzer(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.matrixAnalyzer,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// team investmetnt
  Future<ApiResponse> teamInvestment(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.teamInvestment,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
