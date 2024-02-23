import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/utils/my_logger.dart';
import '/utils/text.dart';
import '../../../utils/toasts.dart';
import '../../model/response/base/error_response.dart';
import '/utils/default_logger.dart';

class ApiErrorHandler {
  static String tag = 'ApiErrorHandler';
  static dynamic getMessage(error, {String? endpoint, bool showToast = true}) {
    dynamic errorDescription = "";
    errorLog('getMessage :${error.runtimeType}', tag);
    if (error is DioException) {
      errorLog(
          'getMessage1 : $error   ${error.runtimeType}   ${error.type}', tag);
      try {
        if (error.response != null) {
          switch (error.response?.statusCode) {
            case 404:
              errorDescription = 'Request not found';
              break;
            case 500:
              errorDescription = 'Internal server error';
              break;
            case 503:
              errorDescription = error.response?.statusMessage;
              break;
            default:
              errorDescription = error.response?.data;
          }
          errorDescription = error.response?.data;
        } else if (DioExceptionType.values.contains(error.type)) {
          logger.e(error.type, tag: tag, error: error);
          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = "Request was cancelled";
              break;
            case DioExceptionType.connectionTimeout:
              errorDescription =
                  "Connection timeout, please check your internet connection";
              break;
            case DioExceptionType.unknown:
              errorDescription = "Connection failed due to internet connection";
              break;
            case DioExceptionType.receiveTimeout:
              errorDescription = "Receive timeout in connection";
              break;
            case DioExceptionType.badCertificate:
              errorDescription =
                  "Error caused by an incorrect certificate as configured by ValidateCertificate";
              break;
            case DioExceptionType.sendTimeout:
              errorDescription = "Send timeout in connection";
              break;
            case DioExceptionType.connectionError:
              errorDescription =
                  "Connection error or socket exception error in connection";
              break;
            case DioExceptionType.badResponse:
              switch (error.response?.statusCode) {
                case 404:
                  errorDescription = 'Request not found';
                  break;
                case 500:
                  errorDescription = 'Internal server error';
                  break;
                case 503:
                  errorDescription = error.response?.statusMessage;
                  break;
                default:
                  ErrorResponse errorResponse =
                      ErrorResponse.fromJson(error.response?.data);
                  if (errorResponse.errors.isNotEmpty) {
                    errorDescription = errorResponse;
                  } else {
                    errorDescription =
                        "Failed to load data - status code: ${error.response?.statusCode}";
                  }
              }
              break;
          }
        } else {
          errorDescription = "Unexpected error occurred";
        }
      } on FormatException catch (e) {
        logger.e(e.source.toString(), tag: tag, error: e);
        errorDescription = e.message;
      }
    } else {
      errorDescription = "Unexpected error occurred";
    }
    // try {
    if (showToast) {
      errorLog('getMessage last : $errorDescription', tag);
      Get.closeAllSnackbars();
      Get.snackbar(
        'Error',
        errorDescription.toString(),
        titleText: titleLargeText('Error', Get.context!, fontSize: 12),
        messageText: titleLargeText(errorDescription.toString(), Get.context!,
            fontSize: 10),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        maxWidth: Get.width * 0.8,
        margin: const EdgeInsets.all(10),
        shouldIconPulse: true,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        // snackPosition: SnackPosition.BOTTOM,
      );
    }
    // } catch (e) {
    // Get.snackbar('Error', errorDescription);
    // }
    return errorDescription;
  }
}
