import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class GalleryRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  GalleryRepo({required this.dioClient, required this.sharedPreferences});

// get gallery data
  Future<ApiResponse> getGalleryData() async {
    try {
      Response response =
          await dioClient.post(AppConstants.gallery, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getGalleryDetails(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.galleryDetail,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getImportantDownloads(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient
          .post(AppConstants.getImportantDownloads, token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

//
  Future<ApiResponse> galleryVideos(Map<String, String> map) async {
    try {
      Response response =
          await dioClient.post(AppConstants.getVideos, data: map, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
//

  Future<ApiResponse> getVimeoVideoCongig(String url,
      {bool getMethod = true, Options? options}) async {
    try {
      Response response = (getMethod
          ? await Dio().get(url, options: options)
          : await dioClient.post(url));
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
