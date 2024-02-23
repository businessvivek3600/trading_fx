// ignore_for_file: empty_catches

import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database/model/response/login_logs_model.dart';
import '../database/model/response/memberSaleData_model.dart';
import '/database/model/response/income_activity_model.dart';
import '/database/model/response/trade_idea_model.dart';
import '/database/model/response/yt_video_model.dart';
import '/database/model/response/CardDetailsPurchasedHistoryModel.dart';
import '/database/model/response/achieved_reward_model.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/base/error_response.dart';
import '/database/model/response/card_feature_detail_model.dart';
import '/database/model/response/company_info_model.dart';
import '/database/model/response/cusomer_rewards_model.dart';
import '/database/model/response/dashboard_alert_model.dart';
import '/database/model/response/dashboard_wallet_activity_model.dart';
import '/database/model/response/ddashboard_subscription_pack_model.dart';
import '/database/model/response/get_active_log_model.dart';
import '/database/repositories/dashboard_repo.dart';
import '/providers/auth_provider.dart';
import '/screens/dashboard/CardFeature/Main_Page_Card_History.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/default_logger.dart';
import '/utils/toasts.dart';

import '../constants/app_constants.dart';
import '../database/functions.dart';

class DashBoardProvider extends ChangeNotifier {
  final DashboardRepo dashBoardRepo;
  DashBoardProvider({required this.dashBoardRepo});
  GlobalKey<ScaffoldState> dashScaffoldKey = GlobalKey();
  GlobalKey<DrawerControllerState> dashDrawerKey = GlobalKey();

  void openDrawer() => dashScaffoldKey.currentState?.openDrawer();
  void closeDrawer() => dashScaffoldKey.currentState?.closeDrawer();

  TextEditingController placementIdController = TextEditingController();

  //drawer
  String selectedDrawerTile = '';

  setDrawerTile(String val) {
    selectedDrawerTile = val;
    notifyListeners();
  }

  /// download
  String? pdfLink;
  String? pptLink;
  String? promotionalVideoLink;
  String? introVideoLink;

  Future<void> getDownloadsData() async {
    String? pdf_link;
    String? ppt_link;
    String? promotional_video_link;
    String? intro_video_link;
    if (isOnline) {
      ApiResponse apiResponse = await dashBoardRepo.getDownloadsData();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        Map map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map["status"];
        } catch (e) {}

        try {
          if (status) {
            try {
              pdf_link = map["pdf_link"];
              ppt_link = map["ppt_link"];
              promotional_video_link = map["promotion_video_link"];
              intro_video_link = map["intro_video_link"];
              dashBoardRepo.setPDFLink(pdf_link ?? '');
              dashBoardRepo.setPPTLink(ppt_link ?? '');
              dashBoardRepo
                  .setPromotionalVideoLink(promotional_video_link ?? '');
              dashBoardRepo.setIntroVideoLink(intro_video_link ?? '');
            } catch (e) {}
          }
        } catch (e) {
          errorLog('getDownloadsData could not be generated \n $e');
        }
        notifyListeners();
      } else {
        String errorMessage = "";
        if (apiResponse.error is String) {
          errorMessage = apiResponse.error.toString();
        } else {
          ErrorResponse errorResponse = apiResponse.error;

          errorMessage = errorResponse.errors[0].message;
        }
        errorLog('error message from getDownloadsData $errorMessage');
        notifyListeners();
      }
    } else {
      try {
        pdf_link = dashBoardRepo.getPDFLink();
        ppt_link = dashBoardRepo.getPPTLink();
        promotional_video_link = dashBoardRepo.getPromoVideoLink();
        intro_video_link = dashBoardRepo.getIntroVideoLink();
      } catch (e) {
        errorLog('getDownloadsData cache hit failed!');
      }
    }
    pdfLink = pdf_link;
    pptLink = ppt_link;
    promotionalVideoLink = promotional_video_link;
    introVideoLink = intro_video_link;
    notifyListeners();
  }

  String? logoUrl;
  String? platinumMemberImage;
  String? appLogoFilePath;
  String? kycUrl;
  String teamBuildingUrl = '';
  String promotionString = '';
  // String getActiveMember = '0';
  bool subscriptionVal = false;
  String subscriptionMsg = '';
  int sub_expire_days = 0;
  int subs_per = 0;
  int get_active_member1 = 0;
  int get_active_member2 = 0;
  int get_active_member3 = 0;
  MemberSaleData memberSaleData = MemberSaleData();

  CompanyInfoModel? companyInfo;
  List<CustomerReward> customerReward = [
    CustomerReward(),
    CustomerReward(),
    CustomerReward(),
    CustomerReward(),
    CustomerReward()
  ];
  List<GetActiveLegModel> get_active_Leg = [];
  List<DashboardAlert> alerts = [];
  List<DashboardSubscriptionPack> subscriptionPacks = [];
  List<DashboardWalletActivity> activities = [];

  bool loadingDash = true;
  bool hasSubscription = false;
  bool hasRewardsAchieved = false;
  bool hasNextReward = true;

  AchievedReward? achievedReward;
  AchievedReward? nextReward;
  List<Map<String, dynamic>> cards = [];
  WebinarEventModel? wevinarEventVideo;

  Future<void> getCustomerDashboard() async {
    Map? map;
    loadingDash = true;
    notifyListeners();
    bool isDashCacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.customerDashboard);
    if (isOnline) {
      ApiResponse apiResponse = await dashBoardRepo.getCustomerDashboard();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
        } catch (e) {}

        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.customerDashboard,
                  syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}

            try {
              sl.get<AuthProvider>().updateUser(map?["userData"]);
            } catch (e) {}
          }
        } catch (e) {
          errorLog('getCustomerDashboard could not be generated \n $e');
        }
        notifyListeners();
      } else {
        String errorMessage = "";
        if (apiResponse.error is String) {
          errorMessage = apiResponse.error.toString();
        } else {
          ErrorResponse errorResponse = apiResponse.error;
          errorMessage = errorResponse.errors[0].message;
        }
        errorLog('error message from getCustomerDashboard $errorMessage');

        notifyListeners();
      }
    } else if (isDashCacheExist) {
      try {
        var data = (await APICacheManager()
                .getCacheData(AppConstants.customerDashboard))
            .syncData;
        map = jsonDecode(data);
      } catch (e) {
        warningLog('getCustomerDashboard cache hit failed! $e');
      }
    } else {
      errorLog('dashboard data failed!');
    }
    try {
      if (map != null) {
        try {
          logoUrl = map['logo'];
          AppConstants.imageUrl =
              map['image_url'] ?? 'https://tradingfx.live/assets/images/';
          appLogoFilePath =
              await downloadAndSaveFile(map['logo'] ?? '', 'app_logo');
          kycUrl = map['kyc_url'];
          teamBuildingUrl = map['team_building_url'] ?? '';
          promotionString = map['promotion_string'] ?? '';
          subscriptionVal = map['subscription_val'] ?? false;
          subscriptionMsg = map['subscription_msg'] ?? '';
          sub_expire_days = map['sub_expire_days'] ?? 0;
          subs_per = (map['subs_per'] ?? 0);
          get_active_member1 = int.parse(map['get_active_member_1'] ?? '0');
          get_active_member2 = int.parse(map['get_active_member_2'] ?? '0');
          get_active_member3 = int.parse(map['get_active_member_3'] ?? '0');
          notifyListeners();

          if (map['webinar_event'] != null) {
            wevinarEventVideo =
                WebinarEventModel.fromJson(map['webinar_event']);
            // wevinarEventVideo = WebinarEventModel.fromJson(map['webinar_event']);
          }
          // infoLog('dashboard webinar_event ${wevinarEventVideo?.toJson()}');
          // get_active_member = 274;

          notifyListeners();
        } catch (e) {
          errorLog('dashboard get active member error $e');
        }

        ///member sale data
        try {
          if (map['member_sale'] != null) {
            memberSaleData = MemberSaleData.fromJson(map['member_sale']);
          }
        } catch (e) {
          memberSaleData = MemberSaleData();
          errorLog('member sale data error $e');
        }

        try {
          companyInfo = CompanyInfoModel.fromJson(map['company_info']);
        } catch (e) {
          errorLog('companyInfo error on dashboard $e');
        }
        notifyListeners();
        try {
          if (map['customer_reward'] != null &&
              map['customer_reward'] is List) {
            List<CustomerReward> _customerRewards = [];
            map['customer_reward'].forEach(
                (e) => _customerRewards.add(CustomerReward.fromJson(e)));
            customerReward = _customerRewards;
            notifyListeners();
          }
        } catch (e) {}
        try {
          if (map['card'] != null && map['card'] is List) {
            cards.clear();
            map['card'].forEach((e) => cards.add(e));
            notifyListeners();
          }
        } catch (e) {
          errorLog('--------- cards error $e--------- ');
        }
        try {
          if (map['get_active_Leg'] != null && map['get_active_Leg'] is List) {
            List<GetActiveLegModel> _get_active_Leg = [];
            map['get_active_Leg'].forEach(
                (e) => _get_active_Leg.add(GetActiveLegModel.fromJson(e)));
            get_active_Leg = _get_active_Leg;
            notifyListeners();
          }
        } catch (e) {}
        try {
          if (map['alerts'] != null &&
              map['alerts'] != false &&
              map['alerts'] is List) {
            List<DashboardAlert> _alerts = [];
            map['alerts']
                .forEach((e) => _alerts.add(DashboardAlert.fromJson(e)));
            alerts = _alerts;
            notifyListeners();
          }
        } catch (e) {}
        try {
          if (map['subscription'] != null &&
              map['subscription'] != false &&
              map['subscription'] is List) {
            List<DashboardSubscriptionPack> _subscriptionPacks = [];
            map['subscription'].forEach((e) =>
                _subscriptionPacks.add(DashboardSubscriptionPack.fromJson(e)));
            subscriptionPacks = _subscriptionPacks;
            hasSubscription = true;
            notifyListeners();
          } else {
            hasSubscription = false;
            notifyListeners();
          }
        } catch (e) {}

        try {
          if (map['wallet_activity'] != null &&
              map['wallet_activity'] != false &&
              map['wallet_activity'] is List) {
            List<DashboardWalletActivity> _activities = [];
            map['wallet_activity'].forEach(
                (e) => _activities.add(DashboardWalletActivity.fromJson(e)));
            activities = _activities;
            notifyListeners();
          }
        } catch (e) {}

        try {
          if (map['current_reward'] != null && map['current_reward'] != false) {
            hasRewardsAchieved = true;
            achievedReward = AchievedReward.fromJson(map['current_reward']);
            notifyListeners();
          } else {
            hasRewardsAchieved = false;
            achievedReward = null;
            notifyListeners();
          }
        } catch (e) {}
        try {
          if (map['next_reward'] != null && map['next_reward'] != false) {
            hasNextReward = true;
            nextReward = AchievedReward.fromJson(map['next_reward']);
            notifyListeners();
          } else {
            hasNextReward = false;
            nextReward = null;
            notifyListeners();
          }
        } catch (e) {}
        notifyListeners();
      }
    } catch (e) {
      errorLog('getCustomerDashboard data setup failed! $e');
    }
    loadingDash = false;
    notifyListeners();
  }

  bool editingMode = false;
  bool changed = false;
  String errorText = '';
  setEditingMode(bool val) {
    editingMode = val;
    notifyListeners();
  }

  ButtonLoadingState submittingPlacementId = ButtonLoadingState.idle;
  Future<void> changePlacement() async {
    Map map = {};
    bool status = false;
    try {
      if (isOnline) {
        submittingPlacementId = ButtonLoadingState.loading;
        errorText = '';
        notifyListeners();
        ApiResponse apiResponse = await dashBoardRepo
            .changePlacement({'placement_id': placementIdController.text});
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          map = apiResponse.response!.data;
          try {
            status = map["status"];
          } catch (e) {}
          try {
            if (status) {
              try {
                submittingPlacementId = ButtonLoadingState.completed;
                sl.get<AuthProvider>().userData.placementUsername =
                    placementIdController.text;
                errorText = map['message'];
                placementIdController.text = map['placement_url'];
                notifyListeners();
                await Future.delayed(Duration(seconds: 3));
                editingMode = false;
                changed = false;
                Toasts.showSuccessNormalToast(map['message'],
                    animationType: AnimationType.fromTop);
                notifyListeners();
              } catch (e) {}
            } else {
              submittingPlacementId = ButtonLoadingState.failed;
              errorText = map['message'];
              notifyListeners();
            }
          } catch (e) {
            submittingPlacementId = ButtonLoadingState.failed;
            errorText = 'Placement Id update failed!';
            notifyListeners();
          }
        } else {
          submittingPlacementId = ButtonLoadingState.failed;
          errorText = map['message'];
          notifyListeners();
          String errorMessage = "";
          if (apiResponse.error is String) {
            print(apiResponse.error.toString());
            errorMessage = apiResponse.error.toString();
          } else {
            ErrorResponse errorResponse = apiResponse.error;
            errorMessage = errorResponse.errors[0].message;
          }
          print('error message from changePlacement $errorMessage');

          notifyListeners();
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      await Future.delayed(Duration(seconds: 3));
      submittingPlacementId = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }

    // await Future.delayed(Duration(seconds: 5));
    // submittingPlacementId = ButtonLoadingState.failed;
    // errorText = 'Placement Id update failed!';
    // notifyListeners();
    // await Future.delayed(Duration(seconds: 5));
    // submittingPlacementId = ButtonLoadingState.idle;
    // errorText = '';
    // notifyListeners();
    await Future.delayed(Duration(seconds: 3));
    submittingPlacementId = ButtonLoadingState.idle;
    errorText = '';
    notifyListeners();
  }

  ///card feature
  bool loadingCardDetail = true;
  CardFeatureDetail? cardDetail;
  List<CardDetailsPurchasedHistoryModel> purchasedCardsList = [];
  String? selectedPayType;
  String? selectedDelivery;
  setDeliveryType(String? delivery) {
    selectedDelivery = delivery;
    notifyListeners();
  }

  setPayType(String? type) {
    selectedPayType = type;
    notifyListeners();
  }

  Future<void> getDashCardDetails(String type) async {
    Map? map;
    loadingCardDetail = true;
    notifyListeners();
    bool isDashCardDetailsCacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.cardDetails + type);
    //if online hit api
    if (isOnline) {
      ApiResponse apiResponse =
          await dashBoardRepo.getCardDetails({'type': type});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getdashcarddetails');
          }
        } catch (e) {}
        if (status) {
          try {
            var cacheModel = APICacheDBModel(
                key: AppConstants.cardDetails + type,
                syncData: jsonEncode(map));
            await APICacheManager().addCacheData(cacheModel);
          } catch (e) {}
        }
        notifyListeners();
      } else {
        String errorMessage = "";
        if (apiResponse.error is String) {
          errorMessage = apiResponse.error.toString();
        } else {
          ErrorResponse errorResponse = apiResponse.error;
          errorMessage = errorResponse.errors[0].message;
        }
        errorLog('error message from getDashCardDetails $errorMessage');
        // Toasts.showErrorNormalToast(errorMessage);
      }
    }
    //is not online but cache exists
    else if (!isOnline && isDashCardDetailsCacheExist) {
      try {
        var data = (await APICacheManager()
                .getCacheData(AppConstants.cardDetails + type))
            .syncData;
        map = jsonDecode(data);
        warningLog('getDashCardDetails cache hit $map');
      } catch (e) {
        errorLog('getDashCardDetails cache hit failed! $e');
      }
    }
    //neither online nor cache exist
    else {
      Toasts.showWarningNormalToast('You are offline!');
    }
    if (map != null) {
      try {
        cardDetail = CardFeatureDetail.fromJson(map['card']);
        if (cardDetail != null &&
            (cardDetail!.delivery != null ||
                cardDetail!.delivery!.isNotEmpty)) {
          selectedDelivery = cardDetail!.delivery!.first.name;
        }
        notifyListeners();
      } catch (e) {
        errorLog('cardDetail get cardDetail error $e');
      }
      try {
        if (map['cards_buy'] != null && map['cards_buy'] is List) {
          purchasedCardsList.clear();
          map['cards_buy'].forEach((e) => purchasedCardsList
              .add(CardDetailsPurchasedHistoryModel.fromJson(e)));
          notifyListeners();
        }
      } catch (e) {
        errorLog('card details cards_buy $type error $e');
      }
    }
    loadingCardDetail = false;
    notifyListeners();
  }

  Future<bool> purchaseACard(Map<String, dynamic> data) async {
    bool status = false;
    try {
      if (isOnline) {
        showLoading(useRootNavigator: false);
        ApiResponse apiResponse = await dashBoardRepo.cardDetailsSubmit(data);
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          String message = '';
          String? return_url;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) logOut('purchaseACard');
          } catch (e) {}
          try {
            message = map["message"] ?? "";
            return_url = map["return_url"];
          } catch (e) {}
          if (status) {
            await getDashCardDetails(data['card_type']);
            if (data['payment_type'] == 'Wallet-CM' ||
                data['payment_type'] == 'Wallet-CH') {
              getCustomerDashboard();
            }
            if (return_url != null) {
              Get.back();
              launchTheLink(return_url);
            } else {
              Get.to(MainPageCardHistory(cards: purchasedCardsList));
              Toasts.showSuccessNormalToast(message.split('.').first);
            }
          } else {
            Toasts.showErrorNormalToast(message.split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      errorLog('purchaseACard failed $e');
    }
    return status;
  }

  //income api
  List<IncomeActivityModel> incomeActivity = [];
  bool loadingIncomeActivity = true;
  int totalIncomeActivity = 0;
  int incomePage = 0;
  Future<List<IncomeActivityModel>> getIncomeActivity({
    bool loading = false,
    required String income_type,
  }) async {
    loadingIncomeActivity = loading;
    notifyListeners();
    List<IncomeActivityModel> records = [];
    Map? map;
    String path = '';
    Map<String, dynamic> data = {'page': incomePage.toString()};
    if (income_type == 'Payout') {
      path = AppConstants.myIncomeActivity;
    } else {
      path = 'myWallet/my-incomes';
      data.addEntries([MapEntry('income_type', income_type)]);
    }
    bool isIncomeActivityCacheExist =
        await APICacheManager().isAPICacheKeyExist(path);
    if (isOnline) {
      ApiResponse apiResponse =
          await dashBoardRepo.myIncomeActivity(path, data);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        bool status = false;
        map = apiResponse.response!.data;
        try {
          status = map?["status"];
        } catch (e) {}
        if (status && incomePage == 0) {
          try {
            var cacheModel =
                APICacheDBModel(key: path, syncData: jsonEncode(map));
            await APICacheManager().addCacheData(cacheModel);
          } catch (e) {}
        }
        notifyListeners();
      } else {
        String errorMessage = "";
        if (apiResponse.error is String) {
          errorMessage = apiResponse.error.toString();
        } else {
          ErrorResponse errorResponse = apiResponse.error;
          errorMessage = errorResponse.errors[0].message;
        }
        errorLog('error message from getIncomeActivity $errorMessage');
        Toasts.showErrorNormalToast(errorMessage);
      }
    } else if (!isOnline && isIncomeActivityCacheExist) {
      try {
        if (incomePage == 0) {
          var data = (await APICacheManager().getCacheData(path)).syncData;
          map = jsonDecode(data);
        }
        warningLog('getIncomeActivity cache hit $map');
      } catch (e) {
        errorLog('getIncomeActivity cache hit failed! $e');
      }
    } else {
      Toasts.showWarningNormalToast('You are offline!');
    }
    if (map != null) {
      try {
        totalIncomeActivity = int.parse(map['total'] ?? '0');
        if (map['item_list'] != null && map['item_list'] is List) {
          map['item_list']
              .forEach((e) => records.add(IncomeActivityModel.fromJson(e)));
          if (incomePage == 0) {
            incomeActivity.clear();
            incomeActivity = records;
          } else {
            incomeActivity.addAll(records);
          }
          incomePage++;
        }
      } catch (e) {
        errorLog('income_activity error $e');
      }
    }
    loadingIncomeActivity = false;
    notifyListeners();
    return records;
  }

  List<LoginLogs> loginActivities = [];
  bool loadingLoginLogs = true;
  int totalLoginLogs = 0;
  int loginLogsPage = 0;
  Future<List<LoginLogs>> getLoginLogs([bool loading = false]) async {
    loadingLoginLogs = loading;
    notifyListeners();
    List<LoginLogs> _loginActivity = [];
    Map? map;

    bool isIncomeActivityCacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.loginLogs);
    if (isOnline) {
      ApiResponse apiResponse =
          await dashBoardRepo.loginLogs({'page': loginLogsPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        bool status = false;
        map = apiResponse.response!.data;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getLoginLogs');
          }
        } catch (e) {}
        if (status && loginLogsPage == 0) {
          try {
            var cacheModel = APICacheDBModel(
                key: AppConstants.loginLogs, syncData: jsonEncode(map));
            await APICacheManager().addCacheData(cacheModel);
          } catch (e) {}
        }
        notifyListeners();
      } else {
        String errorMessage = "";
        if (apiResponse.error is String) {
          errorMessage = apiResponse.error.toString();
        } else {
          ErrorResponse errorResponse = apiResponse.error;
          errorMessage = errorResponse.errors[0].message;
        }
        errorLog('error message from get Login Logs $errorMessage');
        Toasts.showErrorNormalToast(errorMessage);
      }
    } else if (!isOnline && isIncomeActivityCacheExist) {
      try {
        if (loginLogsPage == 0) {
          var data =
              (await APICacheManager().getCacheData(AppConstants.loginLogs))
                  .syncData;
          map = jsonDecode(data);
        }
        warningLog('get Login Logs cache hit $map');
      } catch (e) {
        errorLog('get Login Logs cache hit failed! $e');
      }
    } else {
      Toasts.showWarningNormalToast('You are offline!');
    }
    if (map != null) {
      try {
        totalLoginLogs = int.parse((map['total_rows'] ?? '0').toString());
        if (map['loginLogs'] != null && map['loginLogs'] is List) {
          map['loginLogs']
              .forEach((e) => _loginActivity.add(LoginLogs.fromJson(e)));
          if (loginLogsPage == 0) {
            loginActivities.clear();
            loginActivities = _loginActivity;
          } else {
            loginActivities.addAll(_loginActivity);
          }
          loginLogsPage++;
        }
      } catch (e) {
        errorLog('login activity error $e');
      }
    }
    loadingLoginLogs = false;
    notifyListeners();
    return _loginActivity;
  }

// company trade ideas
  //income api
  List<TradeIdeaModel> tradeIdeas = [];
  bool loadingTradeIdeas = true;
  int totalTradeIdeas = 0;
  int tradeIdeaPage = 0;
  int tradeIdeaType = 0;
  setTradeIdeaType(int val) {
    tradeIdeaType = val;
    notifyListeners();
  }

  Future<List<TradeIdeaModel>> getTradeIdea([bool loading = false]) async {
    loadingTradeIdeas = loading;
    notifyListeners();
    List<TradeIdeaModel> _tradeIdeas = [];
    Map? map;

    bool isIncomeActivityCacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.tradeIdeas);
    if (isOnline) {
      ApiResponse apiResponse = await dashBoardRepo.tradeIdeas(
          {'page': tradeIdeaPage.toString(), 'type': tradeIdeaType.toString()});
      // logger.i('tradeIdeas ',
      //     tag: 'tradeIdeas', error: apiResponse.response!.data);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        bool status = false;
        map = apiResponse.response!.data;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getTradeIdea');
          }
        } catch (e) {}
        if (status && tradeIdeaPage == 0) {
          try {
            var cacheModel = APICacheDBModel(
                key: AppConstants.tradeIdeas, syncData: jsonEncode(map));
            await APICacheManager().addCacheData(cacheModel);
          } catch (e) {}
        }
        notifyListeners();
      } else {
        String errorMessage = "";
        if (apiResponse.error is String) {
          errorMessage = apiResponse.error.toString();
        } else {
          ErrorResponse errorResponse = apiResponse.error;
          errorMessage = errorResponse.errors[0].message;
        }
        errorLog('error message from tradeIdeas $errorMessage');
        Toasts.showErrorNormalToast(errorMessage);
      }
    } else if (!isOnline && isIncomeActivityCacheExist) {
      try {
        if (tradeIdeaPage == 0) {
          var data =
              (await APICacheManager().getCacheData(AppConstants.tradeIdeas))
                  .syncData;
          map = jsonDecode(data);
        }
        warningLog('tradeIdeas cache hit $map');
      } catch (e) {
        errorLog('tradeIdeas cache hit failed! $e');
      }
    } else {
      Toasts.showWarningNormalToast('You are offline!');
    }
    if (map != null) {
      try {
        totalTradeIdeas = int.parse(map['total'] ?? '0');
        if (map['data'] != null && map['data'] is List) {
          map['data']
              .forEach((e) => _tradeIdeas.add(TradeIdeaModel.fromJson(e)));
          if (tradeIdeaPage == 0) {
            tradeIdeas.clear();
            tradeIdeas = _tradeIdeas;
          } else {
            tradeIdeas.addAll(_tradeIdeas);
          }
          tradeIdeaPage++;
        }
      } catch (e) {
        errorLog('tradeIdeas error $e');
      }
    }
    loadingTradeIdeas = false;
    notifyListeners();
    return _tradeIdeas;
  }

  Future<TradeIdeaModel?> tradeIdeasDetails(String id) async {
    TradeIdeaModel? tradeIdeaModel;
    if (isOnline) {
      ApiResponse apiResponse =
          await dashBoardRepo.tradeIdeasDetails({'signal_id': id});
      infoLog('tradeIdeasDetails ${apiResponse.response?.data}');
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        bool status = false;
        Map? map = apiResponse.response!.data;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('tradeIdeasDetails');
          }
        } catch (e) {
          errorLog('tradeIdeasDetails error $e');
        }
        if (status) {
          try {
            if (map!['data'] != null) {
              tradeIdeaModel = TradeIdeaModel.fromJson(map['data']);
            } else {
              tradeIdeaModel = TradeIdeaModel(isDeleted: true);
            }
          } catch (e) {
            errorLog('tradeIdeasDetails error $e');
          }
        }
      }
    }
    return tradeIdeaModel;
  }

  clear() {
    loadingDash = true;
    hasSubscription = false;
    hasRewardsAchieved = false;
    hasNextReward = true;
    achievedReward = null;
    nextReward = null;
    companyInfo = null;
    appLogoFilePath = null;
    kycUrl = null;
    pdfLink = null;
    pptLink = null;
    promotionalVideoLink = null;
    teamBuildingUrl = '';
    promotionString = '';
    subscriptionVal = false;
    subscriptionMsg = '';
    sub_expire_days = 0;
    subs_per = 0;
    customerReward.clear();
    get_active_Leg.clear();
    incomeActivity.clear();
    totalIncomeActivity = 0;
    loadingIncomeActivity = true;
    cards.clear();
    wevinarEventVideo = null;
    selectedDrawerTile = '';
    editingMode = false;
    changed = false;
    errorText = '';
    submittingPlacementId = ButtonLoadingState.idle;
    placementIdController.clear();
    //card-details
    cardDetail = null;
    purchasedCardsList.clear();
    loadingCardDetail = false;
    selectedPayType = null;
    selectedDelivery = null;

    alerts.clear();
    subscriptionPacks.clear();
    activities.clear();

    //card-details
    cardDetail = null;
    purchasedCardsList.clear();
    loadingCardDetail = false;
    selectedPayType = null;
    selectedDelivery = null;
  }
}

enum ButtonLoadingState { idle, loading, completed, failed }
