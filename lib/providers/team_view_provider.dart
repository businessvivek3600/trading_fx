import 'dart:convert';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycarclub/database/app_update/upgrader.dart';
import '../database/model/response/abstract_user_model.dart';
import '../database/model/response/base/error_response.dart';
import '../utils/toasts.dart';
import '/screens/drawerPages/downlines/generation_analyzer.dart';
import '/utils/default_logger.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/base/user_model.dart';
import '/database/model/response/team_downline_user_model.dart';
import '/database/repositories/team_view_repo.dart';
import '/widgets/MultiStageButton.dart';

import '../constants/app_constants.dart';

class TeamViewProvider extends ChangeNotifier {
  final TeamViewRepo teamViewRepo;
  TeamViewProvider({required this.teamViewRepo});
  IndexedTreeNode<TeamDownlineUser> tree = IndexedTreeNode();
  bool initialLoading = true;
  bool adding = true;
  int? loadingLevel = 0;
  int widthLevel = 1;
  String? loadingId = '';
  setLevel(int? val, String? id) {
    loadingLevel = val;
    loadingId = id;
    notifyListeners();
  }

// team member
  late TextEditingController teamMemberSearchController;
  bool isSearchingTeamMember = false;
  setSearchingTeamMembers(bool val) {
    isSearchingTeamMember = val;
    notifyListeners();
  }

  bool loadingTeamMembers = false;
  List<UserData> customerTeamMembers = [];
  int totalTeamMembers = 0;
  int teamMemberPage = 0;

  Future<void> getTeamMembers([bool loading = false]) async {
    loadingTeamMembers = loading;
    notifyListeners();
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.myTeam);
    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.getTeamMember({
        'page': teamMemberPage.toString(),
        'search': teamMemberSearchController.text,
      });
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getCustomerTeam');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.myTeam, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCustomerTeam online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.myTeam)).syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCustomerTeam not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['data'] != null && map['data'].isNotEmpty) {
            List<UserData> team = [];
            map['data'].forEach((e) => team.add(UserData.fromJson(e)));
            if (teamMemberPage == 0) {
              customerTeamMembers.clear();
              customerTeamMembers = team;
            } else {
              customerTeamMembers.addAll(team);
            }
            totalTeamMembers = int.parse(map['total'] ?? '0');
            teamMemberPage++;
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {
      print('getCustomerTeam failed ${e}');
    }
    loadingTeamMembers = false;
    notifyListeners();
  }

  ButtonLoadingState sendingStatus = ButtonLoadingState.idle;
  String? errorText;
  Future<bool> sendMessage({
    VoidCallback? onError,
    VoidCallback? onSuccess,
    required String userId,
    required String title,
    required String subject,
  }) async {
    bool status = false;

    Map? map;
    Map<String, dynamic> data = {
      "user_id": userId,
      'title': title,
      'subject': subject
    };
    try {
      if (isOnline) {
        sendingStatus = ButtonLoadingState.loading;
        errorText = '';
        notifyListeners();
        ApiResponse apiResponse =
            await teamViewRepo.sendInboxMessageToUser(data);
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          map = apiResponse.response!.data;
          try {
            status = map?["status"] ?? false;
            if (map?['is_logged_in'] != 1) {
              logOut('sendMessage');
            }
            if (status) {
              try {
                sendingStatus = ButtonLoadingState.completed;
                errorText = map?['message'];
                status = true;
                if (onSuccess != null) onSuccess();
                notifyListeners();
              } catch (e) {}
            } else {
              sendingStatus = ButtonLoadingState.failed;
              errorText = map?['message'];
              if (onError != null) onError();
              notifyListeners();
            }
          } catch (e) {}
        }
      } else {
        sendingStatus = ButtonLoadingState.failed;
        errorText = 'failed message';
        if (onError != null) onError();
        notifyListeners();
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 3));
      sendingStatus = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      if (onError != null) onError();
      notifyListeners();
    }
    await Future.delayed(const Duration(seconds: 3));
    sendingStatus = ButtonLoadingState.idle;
    errorText = null;
    notifyListeners();
    return status;
  }

//direct team
  DateTime? directMemberSelectedDate;
  final directMemberRefferenceIdController = TextEditingController();
  int? directMemberSelectedStatus;
  late TextEditingController directMemberSearchController;
  bool isSearchingDirectMember = false;
  setSearchingDirectMembers(bool val) {
    isSearchingDirectMember = val;
    notifyListeners();
  }

  List<UserData> directMembers = [];
  bool loadingDirectMembers = true;
  int totalDirectMembers = 0;
  int directMemberPage = 0;
  Future<List<UserData>> getDirectMembers([bool loading = false]) async {
    loadingDirectMembers = loading;
    notifyListeners();
    List<UserData> _directMember = [];
    Map? map;

    bool isIncomeActivityCacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.directMember);
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.directMember({
        'page': directMemberPage.toString(),
        'status': (directMemberSelectedStatus ?? '').toString(),
        'search': directMemberSearchController.text,
      });
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        bool status = false;
        map = apiResponse.response!.data;
        try {
          status = map?["status"];
        } catch (e) {}
        if (status && directMemberPage == 0) {
          try {
            var cacheModel = APICacheDBModel(
                key: AppConstants.directMember, syncData: jsonEncode(map));
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
        errorLog('error message from directMember ${errorMessage}');
        Toasts.showErrorNormalToast(errorMessage);
      }
    } else if (!isOnline && isIncomeActivityCacheExist) {
      try {
        if (directMemberPage == 0) {
          var data =
              (await APICacheManager().getCacheData(AppConstants.directMember))
                  .syncData;
          map = jsonDecode(data);
        }
        warningLog('directMember cache hit $map');
      } catch (e) {
        errorLog('directMember cache hit failed! $e');
      }
    } else {
      Toasts.showWarningNormalToast('You are offline!');
    }
    if (map != null) {
      try {
        totalDirectMembers = int.parse(map['total'] ?? '0');
        if (map['data'] != null && map['data'] is List) {
          map['data'].forEach((e) => _directMember.add(UserData.fromJson(e)));
          if (directMemberPage == 0) {
            directMembers.clear();
            directMembers = _directMember;
          } else {
            directMembers.addAll(_directMember);
          }
          directMemberPage++;
        }
      } catch (e) {
        errorLog('directMember error $e');
      }
    }
    loadingDirectMembers = false;
    notifyListeners();
    return _directMember;
  }

  ///generationAnalyzer
  List<BreadCrumbContent> breadCrumbContent = [];
  setBreadCrumbContent(int index, [BreadCrumbContent? content]) async {
    loadingGUsers = ButtonLoadingState.loading;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    if (content != null) {
      if (breadCrumbContent.isEmpty) {
        breadCrumbContent.insert(index, content);
      } else if (breadCrumbContent.length > index) {
        breadCrumbContent[index] = content;
        breadCrumbContent.removeRange(index + 1, breadCrumbContent.length);
      } else {
        breadCrumbContent.add(content);
      }
    } else {
      breadCrumbContent.removeRange(index, breadCrumbContent.length);
    }

    loadingGUsers = ButtonLoadingState.completed;
    notifyListeners();
  }

  List<GenerationAnalyzerUser> gUsers = [];
  ButtonLoadingState loadingGUsers = ButtonLoadingState.idle;
  setGenerationUsers(String username) async {
    loadingGUsers = ButtonLoadingState.loading;
    notifyListeners();
    gUsers.clear();
    // gUsers.addAll(generateRandomUsers(username, selectedGeneration));
    gUsers.addAll(await getGenerationAnalyzer(username, selectedGeneration));
    // await getGenerationAnalyzer(username, selectedGeneration);
    await Future.delayed(const Duration(seconds: 1))
        .then((value) => loadingGUsers = ButtonLoadingState.completed);
    notifyListeners();
  }

  // generateRandomUsers(String username, int generaionID) {
  //   List<GenerationAnalyzerUser> users = [];
  //   for (var i = 0; i < Random().nextInt(50); i++) {
  //     users.add(GenerationAnalyzerUser(
  //       name: 'User $i',
  //       generation: generaionID,
  //       image: Assets.appLogo_S,
  //       referralId: username,
  //     ));
  //   }
  //   return users;
  // }

  int selectedGeneration = 0;
  setSelectedGeneration(int val) {
    selectedGeneration = val;
    notifyListeners();
  }

  bool isSearchingGUsers = false;
  late TextEditingController generationAnalyzerSearchController;
  setSearchingGUsers(bool val) {
    isSearchingGUsers = val;
    notifyListeners();
  }

  int generationAnalyzerPage = 0;
  int totalGUsers = 0;
  int levelMemberCount = 0;
  bool loadingGenerationAnalyzer = false;

  Future<List<GenerationAnalyzerUser>> getGenerationAnalyzer(
      String username, int selectedGeneration) async {
    List<GenerationAnalyzerUser> gUsers = [];
    loadingGenerationAnalyzer = true;
    notifyListeners();
    if (isOnline) {
      try {
        var data = {
          'username': username,
          'level': selectedGeneration.toString(),
          'page': generationAnalyzerPage.toString(),
          'search': generationAnalyzerSearchController.text,
        };
        print('getGenerationAnalyzer post data: $data');
        ApiResponse apiResponse =
            await teamViewRepo.getGenerationAnalyzer(data);
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('getGenerationAnalyzer');
            }
          } catch (e) {}
          if (status) {
            try {
              if (map['levelMember'] != null) {
                gUsers.clear();
                map['levelMember'].forEach((e) {
                  gUsers.add(GenerationAnalyzerUser.fromJson(e));
                });
                totalGUsers = int.parse(map['total'] ?? '0');
                levelMemberCount = int.parse(map['levelMemberCount'] ?? '0');

                generationAnalyzerPage++;

                notifyListeners();
              }
            } catch (e) {}
          }
        }
      } catch (e) {}
    } else {
      Fluttertoast.showToast(msg: 'No internet connection');
    }
    loadingGenerationAnalyzer = false;
    notifyListeners();
    return gUsers;
  }

//Liquid user

  bool loadingLoquidUser = false;
  List<UserData> liquidUsers = [];
  Future<void> getLiquidUsers() async {
    loadingLoquidUser = true;
    notifyListeners();
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.liquidUser);
    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.liquidUser({});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getLiquidUsers');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.liquidUser, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('liquidUser online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.liquidUser))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('liquidUser not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['direct_child'] != null && map['direct_child'].isNotEmpty) {
            liquidUsers.clear();
            map['direct_child']
                .forEach((e) => liquidUsers.add(UserData.fromJson(e)));
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {
      print('liquidUser failed ${e}');
    }
    loadingLoquidUser = false;
    notifyListeners();
  }

  //place user
  ButtonLoadingState placeUserStatus = ButtonLoadingState.idle;
  String? placeUserErrorText;
  Future<bool> placeUser({
    Function(String? msg)? onError,
    Function(String? msg)? onSuccess,
    required String leg,
    required String placementId,
    required String customerId,
  }) async {
    bool status = false;

    Map? map;
    Map<String, dynamic> data = {
      "leg": leg,
      'customer_id': customerId,
      'placement_id': placementId
    };
    print('placeUser post data: $data');
    try {
      if (isOnline) {
        placeUserStatus = ButtonLoadingState.loading;
        placeUserErrorText = '';
        notifyListeners();
        ApiResponse apiResponse = await teamViewRepo.liquidUserAutoPlace(data);
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          map = apiResponse.response!.data;
          try {
            status = map?["status"] ?? false;
            if (map?['is_logged_in'] != 1) {
              logOut('placeUser');
            }
            if (status) {
              try {
                placeUserStatus = ButtonLoadingState.completed;
                placeUserErrorText = map?['message'];
                status = true;
                if (onSuccess != null) onSuccess(placeUserErrorText);
                notifyListeners();
              } catch (e) {}
            } else {
              placeUserStatus = ButtonLoadingState.failed;
              placeUserErrorText = map?['message'];
            }
          } catch (e) {
            placeUserStatus = ButtonLoadingState.failed;
            placeUserErrorText = 'failed message';
          }
        }
      } else {
        placeUserStatus = ButtonLoadingState.failed;
        placeUserErrorText = 'failed message';
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      placeUserStatus = ButtonLoadingState.failed;
      placeUserErrorText = 'Some thing went wrong!';
    }
    notifyListeners();

    if (onError != null &&
        placeUserErrorText != null &&
        placeUserStatus == ButtonLoadingState.failed) {
      onError(placeUserErrorText);
    }
    await Future.delayed(const Duration(seconds: 1));
    placeUserStatus = ButtonLoadingState.idle;
    placeUserErrorText = null;
    notifyListeners();
    return status;
  }

// get matrix user api
  String? matrixUserErrorText;

  Future<List<MatrixUser>> getMatrixUsers(Map<String, dynamic> data) async {
    List<MatrixUser> matrixUsers = [];
    matrixUserErrorText = null;
    notifyListeners();
    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.matrixAnalyzer(data);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getMatrixUsers');
          }
        } catch (e) {}
      }
    } else {
      print('getMatrixUsers not online not cache exist ');
    }
    print('getMatrixUsers online hit success data: $map');

    try {
      if (map != null) {
        try {
          matrixUserErrorText = map['message'];
          errorLog('getMatrixUsers error: $matrixUserErrorText');
          notifyListeners();
          if (matrixUserErrorText != null) return matrixUsers;

          if (map['client_tree'] != null && map['client_tree'].isNotEmpty) {
            matrixUsers.clear();
            map['client_tree']
                .forEach((e) => matrixUsers.add(MatrixUser.fromJson(e)));
            notifyListeners();
          }
        } catch (e) {
          print('getMatrixUsers failed ${e}');
        }
      }
    } catch (e) {
      print('getMatrixUsers failed ${e}');
    }
    print('getMatrixUsers return matrixUsers: $matrixUsers');
    return matrixUsers;
  }

  clear() {
    tree = IndexedTreeNode();
    initialLoading = true;
    adding = true;
    loadingLevel = 0;
    widthLevel = 1;
    loadingId = '';
    customerTeamMembers.clear();

    sendingStatus = ButtonLoadingState.idle;
    errorText = null;
    breadCrumbContent.clear();
    gUsers.clear();
    loadingGUsers = ButtonLoadingState.idle;
    liquidUsers.clear();
    loadingLoquidUser = false;
    selectedGeneration = 0;
  }

  //income api
  List<TeamInvestment> incomeActivity = [];
  bool loadingIncomeActivity = true;
  int totalIncomeActivity = 0;
  int incomePage = 0;
  Future<List<TeamInvestment>> teamInvestment({
    bool loading = false,
  }) async {
    loadingIncomeActivity = loading;
    notifyListeners();
    List<TeamInvestment> records = [];
    Map? map;
    String path = AppConstants.teamInvestment;
    Map<String, dynamic> data = {'page': incomePage.toString()};
    bool isIncomeActivityCacheExist =
        await APICacheManager().isAPICacheKeyExist(path);
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.teamInvestment(data);
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
        errorLog('error message from teamInvestment $errorMessage');
        Toasts.showErrorNormalToast(errorMessage);
      }
    } else if (!isOnline && isIncomeActivityCacheExist) {
      try {
        if (incomePage == 0) {
          var data = (await APICacheManager().getCacheData(path)).syncData;
          map = jsonDecode(data);
        }
        warningLog('teamInvestment cache hit $map');
      } catch (e) {
        errorLog('teamInvestment cache hit failed! $e');
      }
    } else {
      Toasts.showWarningNormalToast('You are offline!');
    }

    ///data handling
    if (map != null) {
      try {
        totalIncomeActivity = int.tryParse(map['totalRows'].toString()) ?? 0;
        incomePage = int.tryParse(map['page'].toString()) ?? 0;
        if (map['my_trades'] != null && map['my_trades'] is List) {
          map['my_trades']
              .forEach((e) => records.add(TeamInvestment.fromJson(e)));
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
}

class TeamInvestment {
  String? date;
  String? saleType;
  String? invoiceId;
  String? invoiceAmt;
  String? child;

  TeamInvestment({
    this.date,
    this.saleType,
    this.invoiceId,
    this.invoiceAmt,
    this.child,
  });

  TeamInvestment.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    saleType = json['sale_type'];
    invoiceId = json['invoice_id'];
    invoiceAmt = json['invoice_amt'];
    child = json['child'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['sale_type'] = saleType;
    data['invoice_id'] = invoiceId;
    data['invoice_amt'] = invoiceAmt;
    data['child'] = child;
    return data;
  }
}
