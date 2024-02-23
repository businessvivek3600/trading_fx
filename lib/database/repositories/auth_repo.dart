import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '/database/functions.dart';
import '/database/model/response/base/user_model.dart';
import '/database/my_notification_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../sl_container.dart';
import '../../utils/default_logger.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/body/login_model.dart';
import '../model/body/register_model.dart';
import '../model/response/base/api_response.dart';
import 'fcm_subscription_repo.dart';

class AuthRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.dioClient, required this.sharedPreferences});

  static const String tag = 'AuthRepo';

  ///:Registration
  Future<ApiResponse> getSignUpInitialData() async {
    try {
      print('getting getSignUpInitialData0');
      Response response = await dioClient.get(AppConstants.config);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> registration(RegisterModel register) async {
    try {
      var fcmToken = await getDeviceToken(username: register.fName);
      register.device_id = fcmToken;
      register.device_name = await getDeviceName();
      Response response =
          await dioClient.post(AppConstants.signup, data: register.toJson());
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.updateProfile,
          data: data, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getStates(Map<String, dynamic> data) async {
    try {
      Response response =
          await dioClient.post(AppConstants.getStates, data: data, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:Login
  Future<ApiResponse> login(LoginModel loginBody) async {
    try {
      var fcmToken = await getDeviceToken(username: loginBody.username);
      loginBody.device_id = fcmToken;
      loginBody.device_name = await getDeviceName();
      warningLog('loginBody. device token : ${loginBody.device_id}', tag);
      Response response = await dioClient.post(AppConstants.LOGIN_URI,
          data: loginBody.toJson());
      // infoLog(response.data.toString());
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> userInfo() async {
    try {
      Response response = await dioClient.post(
        AppConstants.USER_INFO,
        data: {'login_token': getUserToken()},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> commissionWithdrawal({String? type}) async {
    try {
      Response response = await dioClient.post(
        type == 'kyc' ? AppConstants.kycDetails : AppConstants.paymentMethod,
        data: {'login_token': getUserToken()},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> paymentMethodSubmit(Map<String, dynamic> data,
      {String? type}) async {
    try {
      Response response = await dioClient.post(
          type == 'kyc'
              ? AppConstants.kycDetailsSubmit
              : AppConstants.paymentMethodSubmit,
          data: data,
          token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:updateToken
  Future<ApiResponse> updateToken() async {
    try {
      // String? _deviceToken = await getDeviceToken();
      // FirebaseMessaging.instance.subscribeToTopic(AppConstants.TOPIC);

      Response response = await dioClient.post(
        AppConstants.authorizationToken,
        data: {"_method": "put", "cm_firebase_token": '_deviceToken'},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for  user token
  Future<void> saveUser(UserData userData) async {
    handleSubscription(userData);
    try {
      await sharedPreferences.setString(
          SPConstants.user, jsonEncode(userData.toJson()));
    } catch (e) {
      rethrow;
    }
  }

  Future<UserData?> getUser() async {
    UserData? userData;
    try {
      var data = sharedPreferences.getString(SPConstants.user);
      if (data != null) {
        userData = UserData.fromJson(jsonDecode(data));
      }
    } catch (e) {
      rethrow;
    }
    return userData;
  }

  Future<String> getUserID() async {
    UserData? userData;
    String id = '';
    try {
      var data = sharedPreferences.getString(SPConstants.user) ?? '';
      if (data != '') {
        userData = UserData.fromJson(jsonDecode(data));
        id = userData.username ?? '';
      }
    } catch (e) {
      rethrow;
    }
    return id;
  }

  Future<void> saveUserToken(String token) async {
    dioClient.updateUserToken(token);
    try {
      await sharedPreferences.setString(SPConstants.userToken, token);
    } catch (e) {
      rethrow;
    }
  }

  String getUserToken() {
    return sharedPreferences.getString(SPConstants.userToken) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(SPConstants.userToken);
  }

  void setAppCanUpdate(bool val) async {
    await sharedPreferences.setBool(SPConstants.canUpdate, val);
  }

  bool getAppCanUpdate() {
    return sharedPreferences.getBool(SPConstants.canUpdate) ?? false;
  }

  void setCanRunApp(bool val) async {
    await sharedPreferences.setBool(SPConstants.canRunApp, val);
  }

  bool getCanRunApp() {
    return sharedPreferences.getBool(SPConstants.canRunApp) ?? true;
  }

  Future<bool> clearSharedData() async {
    //sharedPreferences.remove(AppConstants.CART_LIST);
    sharedPreferences.remove(SPConstants.userToken);
    sharedPreferences.remove(SPConstants.user);
    // FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.TOPIC);
    return true;
  }

  // send forgot-pass Email
  Future<ApiResponse> getForgotPassEmailOtp(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.forgetPassword,
          token: false, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // send forgot-pass Email
  Future<ApiResponse> forgetPasswordSubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient
          .post(AppConstants.forgetPasswordSubmit, token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for send- commission withdrawal-Email
  Future<ApiResponse> getCommissionWithdrawalsEmailOtp() async {
    try {
      Response response = await dioClient
          .post(AppConstants.getOtpCommissionWithdrawal, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<void> handleSubscription(UserData user, {bool logout = false}) async {
    FCMSubscriptionRepo repo = sl.get<FCMSubscriptionRepo>();
    try {
      int status = int.parse(user.status ?? '0');
      infoLog('handleSubscription status is : $status ', tag);
      if (!logout) {
        if (status == 0) {
          await repo.subscribeToTopic(topics.nonActive.name);
          await repo.unSubscribeToTopic(topics.platinum.name);
          await repo.unSubscribeToTopic(topics.monthly.name);
          await repo.unSubscribeToTopic(topics.deActive.name);
          return;
        }
        if (status == 2) {
          await repo.subscribeToTopic(topics.deActive.name);
          await repo.unSubscribeToTopic(topics.platinum.name);
          await repo.unSubscribeToTopic(topics.monthly.name);
          await repo.unSubscribeToTopic(topics.nonActive.name);
          return;
        }
        if (status == 1) {
          bool platinumMember = user.anualMembership == 1;
          infoLog(
              'handleSubscription platinumMember : $platinumMember   ${user.anualMembership}',
              tag);
          if (platinumMember) {
            await repo.subscribeToTopic(topics.platinum.name);
            await repo.unSubscribeToTopic(topics.monthly.name);
          } else {
            await repo.subscribeToTopic(topics.monthly.name);
            await repo.unSubscribeToTopic(topics.platinum.name);
          }
          await repo.unSubscribeToTopic(topics.deActive.name);
          await repo.unSubscribeToTopic(topics.nonActive.name);
          return;
        }
      } else {
        await repo.unSubscribeToTopic(topics.platinum.name);
        await repo.unSubscribeToTopic(topics.monthly.name);
        await repo.unSubscribeToTopic(topics.deActive.name);
        await repo.unSubscribeToTopic(topics.nonActive.name);
      }
    } catch (e) {
      errorLog('handleSubscription $e', tag);
    }
  }

  // send verify Email
  Future<ApiResponse> verifyEmail(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.verifyEmail,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///change password
  Future<ApiResponse> changePassword(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.changePassword,
          token: true, data: data);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

// Future<ApiResponse> verifyEmail(String email, String token, String tempToken) async {
  //   try {
  //     Response response = await dioClient.post(AppConstants.VERIFY_EMAIL_URI, data: {"email": email, "token": token, 'temporary_token': tempToken});
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }

  //verify phone number

  // Future<ApiResponse> checkPhone(String phone, String temporaryToken) async {
  //   try {
  //     Response response = await dioClient.post(
  //         AppConstants.CHECK_PHONE_URI, data: {"phone": phone, "temporary_token" :temporaryToken});
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }
  //
  // Future<ApiResponse> verifyPhone(String phone, String token,String otp) async {
  //   try {
  //     Response response = await dioClient.post(
  //         AppConstants.VERIFY_PHONE_URI, data: {"phone": phone.trim(), "temporary_token": token,"otp": otp});
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }
  // Future<ApiResponse> verifyOtp(String identity, String otp) async {
  //   try {
  //     Response response = await dioClient.post(
  //         AppConstants.VERIFY_OTP_URI, data: {"identity": identity.trim(), "otp": otp});
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }
  //
  // Future<ApiResponse> resetPassword(String identity, String otp ,String password, String confirmPassword) async {
  //   print('======Password====>$password');
  //   try {
  //     Response response = await dioClient.post(
  //         AppConstants.RESET_PASSWORD_URI, data: {"_method" : "put", "identity": identity.trim(), "otp": otp,"password": password, "confirm_password":confirmPassword});
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }
  //
  //
  //
  // // for  Remember Email
  // Future<void> saveUserEmailAndPassword(String email, String password) async {
  //   try {
  //     await sharedPreferences.setString(AppConstants.USER_PASSWORD, password);
  //     await sharedPreferences.setString(AppConstants.USER_EMAIL, email);
  //   } catch (e) {
  //     throw e;
  //   }
  // }
  //
  // String getUserEmail() {
  //   return sharedPreferences.getString(AppConstants.USER_EMAIL) ?? "";
  // }
  //
  // String getUserPassword() {
  //   return sharedPreferences.getString(AppConstants.USER_PASSWORD) ?? "";
  // }
  //
  // Future<bool> clearUserEmailAndPassword() async {
  //   await sharedPreferences.remove(AppConstants.USER_PASSWORD);
  //   return await sharedPreferences.remove(AppConstants.USER_EMAIL);
  // }
  //
  // Future<ApiResponse> forgetPassword(String identity) async {
  //   try {
  //     Response response = await dioClient.post(AppConstants.FORGET_PASSWORD_URI, data: {"identity": identity});
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }
}
