import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:activity_ring/activity_ring.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:banner_carousel/banner_carousel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:floating_chat_button/floating_chat_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:mycarclub/database/model/response/memberSaleData_model.dart';
import 'package:mycarclub/utils/extentions.dart';
import '../drawerPages/inbox/inbox_screen.dart';
import '/screens/drawerPages/wallets/cash_wallet_page/cash_wallet_page.dart';
import '/screens/drawerPages/wallets/commission_wallet/commission_wallet_page.dart';
import '../../database/databases/firebase_database.dart';
import '../drawerPages/dashboard_alert_widget.dart';
import '/database/repositories/settings_repo.dart';
import '../tawk_chat_page.dart';
import '/widgets/app_lock_auth_suggest_view.dart';
import '/database/model/response/videos_model.dart';
import '/screens/drawerPages/download_pages/videos/drawer_videos_main_page.dart';
import '/screens/drawerPages/event_tickets/buy_ticket_Page.dart';
import '../../providers/event_tickets_provider.dart';
import '/database/model/body/login_model.dart';
import '../../database/model/response/yt_video_model.dart';
import '/screens/dashboard/company_trade_ideas_page.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../../constants/app_constants.dart';
import '../youtube_video_play_widget.dart';
import '../../utils/theme.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/cusomer_rewards_model.dart';
import '/database/model/response/get_active_log_model.dart';
import '/myapp.dart';
import '/providers/GalleryProvider.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/notification_provider.dart';
import '/providers/subscription_provider.dart';
import '/screens/dashboard/CardFeature/CreditCardPurchaseWidget.dart';
import '/screens/dashboard/commisstion_activity_details.dart';
import '/screens/drawerPages/subscription/subscription_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/utils/toasts.dart';
import '/widgets/GalleryImagesPreviewDilaog.dart';
import '/widgets/app_rating_dialog.dart';
import '../../widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../database/functions.dart';
import '../../database/my_notification_setup.dart';
import '../../utils/picture_utils.dart';
import '../../utils/skeleton.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key, this.loginModel}) : super(key: key);
  static const String routeName = '/MainPage';
  GlobalKey<ScaffoldState> dashScaffoldKey = GlobalKey();
  final LoginModel? loginModel;
  @override
  State<MainPage> createState() => _MainPageState();
}

ValueNotifier<int> showDashPopUP = ValueNotifier(0);
ValueNotifier<bool> canShowNextDashPopUPBool = ValueNotifier(false);

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin, RouteAware {
  OverlayEntry? overlayEntry;
  int currentPage = 0;
  AnimationController? animationController;
  Animation<double>? animation;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var dashboardProvider = sl.get<DashBoardProvider>();
  var galleryProvider = sl.get<GalleryProvider>();
  var authProvider = sl.get<AuthProvider>();
  FirebaseDatabase firebaseDatabase = sl.get<FirebaseDatabase>();

  @override
  void initState() {
    // setErrorBuilder();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (notificationPaylod != null) {
        selectNotificationStream.add(notificationPaylod);
        warningLog(
            'notificationPaylod is not null  data is : ${jsonEncode(notificationPaylod)}',
            'Main Page');
        notificationPaylod = null;
      }
      dashboardProvider.getCustomerDashboard().then(
          (value) => showDashboardInitialPopUp(dashboardProvider, context));
      sl.get<NotificationProvider>().getUnRead();
      // dashboardProvider.getDownloadsData();
      sl.get<SubscriptionProvider>().mySubscriptions();
      authProvider.getSignUpInitialData();
      // galleryProvider.getGalleryData(false);
      sl.get<EventTicketsProvider>().getEventTickets(true);
      // galleryProvider.getVideos(false);
      canShowNextDashPopUPBool.addListener(() {});
      checkForUpdate(context);

      //check if user is logged in and show bottom sheet to save password
      if (widget.loginModel != null) {
        Toasts.showSuccessNormalToast('You have logged in Successfully',
            title: 'Welcome ${authProvider.userData.customerName ?? ''}');
        _checkForSavedPassword();
      }
      setupAppRating(3 * 24).then((value) {
        if (value) {
          rateApp();
        }
      });
    });
  }

  Future<void> _checkForSavedPassword() {
    Fluttertoast.cancel();
    return Future.delayed(const Duration(seconds: 5), () async {
      await authProvider.getSavedCredentials().then((list) {
        bool isSaved = false;
        bool update = false;
        if (list.isNotEmpty &&
            list.entries
                .any((element) => element.key == widget.loginModel!.username)) {
          update = list.entries
                  .firstWhere(
                      (element) => element.key == widget.loginModel!.username)
                  .value !=
              widget.loginModel!.password;
          isSaved = true;
        }
        warningLog(
            'SavedCredentials isSaved $isSaved update $update', 'Main Page');
        if (!isSaved || update) {
          _showBottomSheet(context, saved: isSaved, update: update);
        }
      });
    });
  }

  appRating() async {}

//create bottom sheet to ask to save password
  Future<void> _showBottomSheet(BuildContext context,
      {bool saved = false, bool update = false}) async {
    await showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (context) => Container(
              padding: const EdgeInsets.all(10),
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      width20(),
                      Expanded(
                        child: FilledButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              if (!update) {
                                await authProvider.saveCredentials(
                                    widget.loginModel!.username!,
                                    widget.loginModel!.password!);
                              } else {
                                await authProvider.updateCredential(
                                    widget.loginModel!.username!,
                                    widget.loginModel!.password!);
                              }
                            },
                            icon: const Icon(Icons.save_alt_rounded,
                                color: Colors.white),
                            label: Text(
                              update ? 'Update Password' : 'Save Password',
                              style: const TextStyle(color: Colors.white),
                            )),
                      ),
                      width20(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      width20(),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.red))),
                      width20(),
                    ],
                  ),
                ],
              ),
            ));
  }

  @override
  void dispose() {
    if (mounted) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  void _onRefresh() async {
    appRating();
    dashboardProvider.getDownloadsData();
    await dashboardProvider
        .getCustomerDashboard()
        .then((value) => showDashboardInitialPopUp(dashboardProvider, context));
    sl.get<NotificationProvider>().getUnRead();
    sl.get<SubscriptionProvider>().mySubscriptions();
    authProvider.getSignUpInitialData();
    sl.get<EventTicketsProvider>().getEventTickets(true);
    // galleryProvider.getGalleryData(false);
    // galleryProvider.getVideos(false);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    // getDeviceToken();
    final size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<DashBoardProvider>(
          builder: (context, dashBoardProvider, child) {
            return GestureDetector(
              onTap: () {
                primaryFocus?.unfocus();
                // logOut('Main Page Tap Test for logout');
              },
              child: Scaffold(
                key: widget.dashScaffoldKey,
                backgroundColor: Colors.transparent,
                drawer: const CustomDrawer(),
                body: Stack(
                  children: [
                    buildBody(context, dashBoardProvider, authProvider, size),

                    /// Tawk Chat Button
                    // buildTawkChatButton(authProvider),
                  ],
                ),
                floatingActionButton: authProvider.userData.kyc != '1'
                    ? buildKYCButton(dashBoardProvider)
                    : null,
                // floatingActionButton: GestureDetector(
                //   onTap: () => Get.to(TawkChatPage(
                //       username: authProvider.userData.username ?? '',
                //       email: authProvider.userData.customerEmail ?? '')),
                //   child: Container(
                //     padding: EdgeInsets.all(20),
                //     color: redDark,
                //     child: Container(
                //       padding: EdgeInsets.all(10),
                //       decoration: BoxDecoration(
                //         color: Color(0xFF03A84E),
                //         shape: BoxShape.circle,
                //       ),
                //       child: assetSvg(Assets.chat, width: 15),
                //     ),                //   ),
                // ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildTawkChatButton(AuthProvider authProvider) {
    return FloatingChatButton(
      shouldPutWidgetInCircle: false,
      chatIconBackgroundColor: Colors.transparent,
      chatIconBorderWidth: 0,
      chatIconBorderColor: Colors.transparent,
      chatIconColor: Colors.transparent,
      chatIconVerticalOffset: 120,
      chatIconHorizontalOffset: 5,
      onTap: (ctx) => print('Floating Chat Button Tapped!'),
      chatIconWidget: GestureDetector(
        onTap: () => Get.to(TawkChatPage()),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 20, top: 20, bottom: 10, right: 10),
              // color: redDark,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Color(0xFF03A84E), shape: BoxShape.circle),
                child: assetSvg(Assets.chat, width: 15),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: assetImages('168-r-br.png'),
            )
          ],
        ),
      ),
    );
  }

  Container buildBody(BuildContext context, DashBoardProvider dashBoardProvider,
      AuthProvider authProvider, Size size) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: userAppBgImageProvider(context),
            fit: BoxFit.cover,
            opacity: 1),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                buildAppLogo(dashBoardProvider, authProvider),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: _refreshController,
                    header: const MaterialClassicHeader(),
                    onRefresh: _onRefresh,
                    // footer:null,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          height10(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // if (Platform.)
                              //   FilledButton(
                              //       onPressed: () {
                              //         // showDialog(
                              //         //   context: context,
                              //         //   builder: (context) =>
                              //         //       YotiSignSuccessDialog(),
                              //         // );
                              //         Get.to(InAppPurchaseExample());
                              //       },
                              //       child: const Text('In App Purchase')),

                              ///alerts
                              if (dashboardProvider.alerts
                                  .where((element) => element.status == 1)
                                  .isNotEmpty)
                                const MainPageAlertsSlider(),
                              height10(),
                              AppLockAuthSuggestionWidget(
                                showSuggestion:
                                    sl.get<SettingsRepo>().getBiometric(),
                                margin: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 8),
                                backgroundColor: Colors.white12,
                              ),
                              buildAccountStatistics(
                                  context, authProvider, dashBoardProvider),
                              _buildTeamBuildingReferralLink(
                                  context, dashBoardProvider),
                              height10(),
                              buildTeamStatistics(
                                  context, authProvider, dashBoardProvider),

                              /*
                             _buildPlaceholderIdField(
                                 context, dashBoardProvider),
                             height10(),
                             GestureDetector(
                               onTap: () =>
                                   _showBottomSheet(context),
                               child: buildQRCodeContainer(
                                   dashBoardProvider),
                             ),
                             */

                              // Trading view,
                              // buildTradingViewWidget(context, size,
                              //     dashBoardProvider, authProvider),
                              // height10(),
                              // platinum member logo

                              // Upcommin Events,
                              /*
                              if (dashboardProvider.wevinarEventVideo != null &&
                                  dashboardProvider.wevinarEventVideo!.status ==
                                      '1' &&
                                  authProvider.userData.salesActive == '1')
                                Column(
                                  children: [
                                    buildUpcomingEvents(
                                        context, size, dashBoardProvider),
                                    // height20(),
                                  ],
                                ),
                                */
                              // platinum member logo
                              /*
                              GestureDetector(
                                onTap: () =>
                                    Get.to(YoutubePlayerDemoApp()),
                                child: buildPlatinumMemberLogo(
                                    dashBoardProvider),
                              ),
                              buildSubscriptionStatusBar(
                                  context, dashBoardProvider),
                              height30(),
                              */
                            ],
                          ),
                          // if (Platform.isAndroid)
                          // buildSubscriptionHistory(
                          //     context, size, dashBoardProvider, authProvider),
                          // height20(),

                          /// Accademic Video
                          // buildAccademicVideo(context),
                          // height20(),
                          // buildCardFeatureListview(
                          //     context, size, dashBoardProvider),
                          // buildCommissionActivity(
                          //     context, size, dashBoardProvider),
                          // height20(),
                          // ...buildTargetProgressCards(dashBoardProvider),
                          // ...buildTiers(context, dashBoardProvider),
                          // height20(),
                          // buildEventsTicketCard(context),
                          height100(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // buildDrawerMenuButton(dashBoardProvider),
          // buildSQRCodeContainer(dashBoardProvider),
        ],
      ),
    );
  }

  Widget buildEventsTicketCard(BuildContext context) {
    return Consumer<EventTicketsProvider>(
        builder: (context, eventTicketsProvider, _) =>
            !eventTicketsProvider.loadingMyTickets &&
                    eventTicketsProvider.eventsList.isNotEmpty
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          UiCategoryTitleContainer(
                              child: bodyLargeText('Events', context)),

                          /*
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(EventTicketsPage());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            bodyMedText(
                              'View All',
                              context,
                            ),
                            Icon(Icons.keyboard_arrow_right_rounded,
                                color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                  ),
                */
                        ],
                      ),
                      height20(),
                      /*
              Card(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white24,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: buildCachedNetworkImage(
                      'https://mywealthclub.com/assets/images/ticket-img/my-wealth-club-launch-event.jpg',
                      ph: 400,
                      pw: Get.width)),
                      */
                      _EventsSliderWidget(
                          listBanners: eventTicketsProvider.eventsList
                              .map((e) => BannerModel(
                                  imagePath: e.eventBanner ?? '',
                                  id: e.id.toString()))
                              .toList()),
                    ],
                  )
                : const SizedBox());
  }

  Widget buildAccademicVideo(BuildContext context) {
    return const _MainPageAccademicVideoList();
  }

  /// build target progress cards
  Padding buildAccountStatistics(
      BuildContext context, AuthProvider authProvider, DashBoardProvider dp) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    MemberSaleData ms = dp.memberSaleData;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
      child: GridView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2,
          ),
          children: [
            _buildStatisticsGridViewItem(context, 'Today Income',
                ms.todayIncome.toDouble(), currency_icon, onTap: () {
              Get.to(const CommissionWalletPage());
            }),
            _buildStatisticsGridViewItem(context, 'Trade Income',
                ms.incomeTradeIncome.toDouble(), currency_icon, onTap: () {
              Get.to(const CashWalletPage());
            }),
            _buildStatisticsGridViewItem(context, 'Trade Level Reward',
                ms.incomeTradeLevelReward.toDouble(), currency_icon,
                isCount: true),
            _buildStatisticsGridViewItem(
                context,
                'Licence Fee Level Reward',
                ms.incomeLicenceFeeLevelReward.toDouble(),
                currency_icon, onTap: () {
              Get.to(const CommissionWalletPage());
            }),
            _buildStatisticsGridViewItem(
                context, 'Top Up Wallet', ms.balTopup.toDouble(), currency_icon,
                onTap: () {
              Get.to(const CashWalletPage());
            }),
            _buildStatisticsGridViewItem(context, 'Commission Wallet',
                ms.balCommission.toDouble(), currency_icon,
                isCount: true),
            _buildStatisticsGridViewItem(context, 'Total Earnings',
                ms.incomeTotal.toDouble(), currency_icon,
                isCount: true),
          ]),
    );
  }

  Widget _buildStatisticsGridViewItem(
      BuildContext context, String title, double value, String icon,
      {bool isCount = false, Function()? onTap}) {
    var _value = isCount ? value.toInt() : value.toStringAsFixed(2);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // height: 100,
        // width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: bColor(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bodyLargeText(
              title,
              context,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              useGradient: false,
              textAlign: TextAlign.center,
            ),
            height10(),
            titleLargeText('${isCount ? '' : icon} ${_value}', context,
                useGradient: true, color: Colors.white),
          ],
        ),
      ),
    );
  }

  /// build team statistics cards
  Padding buildTeamStatistics(
      BuildContext context, AuthProvider authProvider, DashBoardProvider dp) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    MemberSaleData ms = dp.memberSaleData;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
      child: GridView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2,
          ),
          children: [
            _buildTeamStatisticsGridViewItem(context, 'Today Team Trade',
                ms.tTeamInvestment.toDouble(), currency_icon, onTap: () {
              Get.to(const CommissionWalletPage());
            }),
            _buildTeamStatisticsGridViewItem(context, 'Today Frontline Trade',
                ms.tDirectInvestment.toDouble(), currency_icon, onTap: () {
              Get.to(const CashWalletPage());
            }),
            _buildTeamStatisticsGridViewItem(context, 'Today Self Trade',
                ms.tSelfInvestment.toDouble(), currency_icon,
                isCount: true),
            _buildStatisticsGridViewItem(context, 'Total Team Trade',
                (ms.teamInvestment.toDouble() / 500), currency_icon, onTap: () {
              Get.to(const CommissionWalletPage());
            }),
            _buildTeamStatisticsGridViewItem(
                context,
                'Total Frontline Trade',
                (ms.directInvestment.toDouble() / 500),
                currency_icon, onTap: () {
              Get.to(const CashWalletPage());
            }),
            _buildTeamStatisticsGridViewItem(context, 'Total Self Trade',
                (ms.selfInvestment.toDouble() / 500), currency_icon,
                isCount: true),
            _buildTeamStatisticsGridViewItem(
                context, 'Team Member', ms.teamMember.toDouble(), currency_icon,
                isCount: true),
            _buildTeamStatisticsGridViewItem(context, 'Direct Member',
                ms.directMember.toDouble(), currency_icon,
                isCount: true),
          ]),
    );
  }

  Widget _buildTeamStatisticsGridViewItem(
      BuildContext context, String title, double value, String icon,
      {bool isCount = false, Function()? onTap}) {
    var _value = isCount ? value.toInt() : value.toStringAsFixed(2);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // height: 100,
        // width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: bColor(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bodyLargeText(
              title,
              context,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              useGradient: false,
              textAlign: TextAlign.center,
            ),
            height10(),
            titleLargeText('${isCount ? '' : icon} ${_value}', context,
                useGradient: true, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget buildTradingViewWidget(BuildContext context, Size size,
      DashBoardProvider dashBoardProvider, AuthProvider authProvider) {
    return GestureDetector(
      onTap: () {
        Get.to(const CompanyTradeIdeasPage());
      },
      child: Stack(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                child: titleLargeText(
                  'EAGLE AI',
                  context,
                  fontSize: 25,
                  useGradient: true,
                  decoration: TextDecoration.underline,
                ),
              ),
              width10(),
              assetImages(Assets.eagleAi, height: 50),
            ],
          ),
        ],
      ),
    );
  }

  Column buildUpcomingEvents(
      BuildContext context, Size size, DashBoardProvider dashBoardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiCategoryTitleContainer(
            child: bodyLargeText('Academic Broadcast', context)),
        SizedBox(
          height: 200,
          child: _BuildUpcomingEventCard(
            event: dashboardProvider.wevinarEventVideo!,
            loading: dashBoardProvider.loadingDash,
          ),
        )
      ],
    );
  }

  Widget buildPlatinumMemberLogo(DashBoardProvider dashBoardProvider) {
    return authProvider.userData.anualMembership == 1
        ? Column(
            children: [
              height5(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // color: Colors.red,
                    width: Get.width / 2.5,
                    height: 50,
                    child: buildCachedNetworkImage(
                        dashBoardProvider.platinumMemberImage ?? '',
                        pw: Get.width / 2.5,
                        ph: 50,
                        fit: BoxFit.contain,
                        placeholderImg: Assets.appWebLogoWhite,
                        cacheFileName: 'platinum_member_image'),
                  ),
                ],
              ),
            ],
          )
        : Container();
  }

  void showDashboardInitialPopUp(
      DashBoardProvider dashBoardProvider, BuildContext context) {
    /*   errorLog(
        '--------- ${dashBoardProvider.companyInfo!.popupImg} ${dashBoardProvider.companyInfo!.popupImage}');
    errorLog(
        '--------- ${(dashBoardProvider.companyInfo?.popupImage != '' && dashBoardProvider.companyInfo?.popupImage != null && dashBoardProvider.companyInfo?.popupImg != '1')}');
    errorLog(
        'images are ---${dashBoardProvider.companyInfo!.popupImage!.map((e) => (dashBoardProvider.companyInfo!.popup_url ?? "") + (e['file_name'] ?? '')).toList()}');
*/
    if (canShowNextDashPopUPBool.value == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (dashBoardProvider.companyInfo?.popupImage != '' &&
            dashBoardProvider.companyInfo?.popupImage != null &&
            dashBoardProvider.companyInfo?.popupImg != '0') {
          canShowNextDashPopUPBool.value = true;
          /* dashboardDialog(
              image:
                  // 'https://tradingfx.live/assets/images/ticket-img/international-conventional-egypt-2023-usd.jpg',
                  dashBoardProvider.companyInfo!.popupImage!,
              context: context);*/
          // errorLog(
          //     'images are ---${dashBoardProvider.companyInfo!.popupImage!.map((e) => (dashBoardProvider.companyInfo!.popup_url ?? "") + (e['file_name'] ?? '')).toList()}');
          var images = [
            (dashBoardProvider.companyInfo!.popupUrl ?? '') +
                dashBoardProvider.companyInfo!.popupImage!
          ]
              // .map((e) =>
              //     (dashBoardProvider.companyInfo!.popup_url ?? "") +
              //     (e['file_name'] ?? ''))
              // .toList()
              ;

          // images=[...images,...images,...images];
          showDialog<void>(
            context: context,
            // barrierColor: Colors.black.withOpacity(0.4),
            barrierDismissible: false,
            useRootNavigator: false,
            builder: (BuildContext dialogContext) {
              return GalleryDetailsImagePopup(
                  currentIndex: 0, images: images, showCancel: true);
            },
          );
          canShowNextDashPopUPBool.value = false;
        }
      });
    }
  }

  FloatingActionButton buildKYCButton(DashBoardProvider dashBoardProvider) {
    return FloatingActionButton.extended(
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: appLogoColor),
          borderRadius: BorderRadius.circular(30)),
      onPressed: () => launchTheLink(dashBoardProvider.kycUrl ?? ''),
      label: const Text(
        'Verify KYC',
        style: TextStyle(color: appLogoColor),
      ),
    );
  }

  PreferredSize buildAppLogo(
      DashBoardProvider dashBoardProvider, AuthProvider authProvider) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SizedBox(height: 10),
              SizedBox(
                width: Get.width * 0.5,
                height: 50,
                // color: redDark,
                child: CachedNetworkImage(
                  imageUrl: dashBoardProvider.logoUrl ?? '',
                  placeholder: (context, url) => const SizedBox(
                      height: 70,
                      width: 50,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Colors.transparent))),
                  errorWidget: (context, url, error) => SizedBox(
                      height: 70, child: assetImages(Assets.appWebLogoWhite)),
                  cacheManager: CacheManager(
                    Config(
                      "${AppConstants.packageID}_app_dash_logo",
                      stalePeriod: const Duration(days: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),

          //
          buildDrawerMenuButton(dashBoardProvider, authProvider),
          buildSQRCodeContainer(dashBoardProvider),
        ],
      ),
    );
  }

  Positioned buildDrawerMenuButton(
      DashBoardProvider dashBoardProvider, AuthProvider authProvider) {
    bool isWebinarLive = dashboardProvider.wevinarEventVideo != null &&
        dashboardProvider.wevinarEventVideo!.status == '1' &&
        authProvider.userData.salesActive == '1';
    return Positioned(
      top: 0,
      left: 16,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => widget.dashScaffoldKey.currentState?.openDrawer(),
            child: Stack(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      // color: Colors.white,
                      gradient: buildButtonGradient(),
                      shape: BoxShape.circle),
                  child: Center(
                    child: assetSvg(Assets.squareMenu, color: Colors.white),
                  ),
                ),
                // if (isWebinarLive)
                  // Positioned(
                  //   bottom: 0,
                  //   // right: 8,
                  //   // top: -2,
                  //   // left: -2,
                  //   right: 10,
                  //   // top: 15,
                  //   child: Container(
                  //       height: 20,
                  //       width: 20,
                  //       decoration: BoxDecoration(
                  //         color: Colors.black,
                  //         shape: BoxShape.circle,
                  //         image: DecorationImage(
                  //             image: userAppBgImageProvider(context)),
                  //       ),
                  //       child: assetLottie(Assets.liveLottie, width: 25)),
                  // ),
                // if (Provider.of<NotificationProvider>(context, listen: true)
                //         .totalUnread >
                //     0)
                //   Positioned(
                //     right: 0,
                //     top: 0,
                //     child: Container(
                //       decoration: const BoxDecoration(
                //           color: Colors.transparent, shape: BoxShape.circle),
                //       width: 22,
                //       height: 22,
                //       child: const Icon(Icons.circle,
                //           size: 20, color: Colors.red),
                //     ),
                  // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Positioned buildSQRCodeContainer(DashBoardProvider dashBoardProvider) {
    return Positioned(
      top: 0,
      right: 16,
      bottom: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: GestureDetector(
              onTap: () {
                Dialog QRCodeDialog = Dialog(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white
                              // color: Color(appLogoColor.value).withOpacity(01),
                              ),
                          padding: const EdgeInsets.all(10),
                          child: Hero(
                            tag: 'qr_code',
                            child: buildQRCodeContainer(
                              dashBoardProvider,
                              showLogo: true,
                              dataModuleShape: QrDataModuleShape.circle,
                              size: const Size(200, 200),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                showDialog(context: context, builder: (_) => QRCodeDialog);
              },
              child: Hero(
                tag: 'qr_code',
                child: buildQRCodeContainer(dashBoardProvider,
                    size: const Size(40, 40), logoS: const Size(10, 10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned buildDashboardAppLogo(DashBoardProvider dashBoardProvider) {
    return Positioned(
      top: kToolbarHeight / 2 + 16,
      right: 0,
      left: 0,
      child: Container(
        height: 50,
        width: Get.width * 0.7,
        decoration: const BoxDecoration(color: mainColor),
        child: Center(
          child: Image.file(File(dashBoardProvider.appLogoFilePath!)),
        ),
      ),
    );
  }

  Positioned buildUserIdTile(AuthProvider authProvider, BuildContext context) {
    var id = authProvider.userData.customerId ?? '';
    return Positioned(
      top: kToolbarHeight / 2 + 16,
      right: 16,
      child: GestureDetector(
        onDoubleTap: () async => Clipboard.setData(ClipboardData(text: id))
          ..then(
              (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Id copied  to clipboard.'),
                  ))),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          // width: 40,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: bodyMedText(id, context,
                color: mainColor,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildCommissionActivity(
      BuildContext context, Size size, DashBoardProvider dashBoardProvider) {
    return !dashBoardProvider.loadingDash &&
            dashBoardProvider.activities.isNotEmpty
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UiCategoryTitleContainer(
                      child: bodyLargeText('COMMISSION ACTIVITY', context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(CommissionActivityDetailsPage(
                            activities: dashBoardProvider.activities));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            bodyMedText('View All', context),
                            const Icon(Icons.keyboard_arrow_right_rounded,
                                color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              height20(),
              Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: CommissionActivityHistoryList(
                      activities:
                          getFirstFourElements(dashboardProvider.activities))),
            ],
          )
        : const SizedBox();
  }

  Column buildSubscriptionHistory(BuildContext context, Size size,
      DashBoardProvider dashBoardProvider, AuthProvider authProvider) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

    bool showList =
        !dashBoardProvider.loadingDash && dashBoardProvider.hasSubscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiCategoryTitleContainer(
            child: bodyLargeText('TRADES HISTORY', context)),
        SizedBox(
          // duration: const Duration(milliseconds: 500),
          height: dashBoardProvider.loadingDash ||
                  dashBoardProvider.subscriptionPacks.isNotEmpty
              ? 200
              : 130,
          child: !dashBoardProvider.loadingDash &&
                  (!dashBoardProvider.hasSubscription ||
                      dashBoardProvider.subscriptionPacks.isEmpty)
              ? Container(
                  width: double.maxFinite,
                  constraints: BoxConstraints(maxWidth: size.width),
                  margin: const EdgeInsetsDirectional.only(
                      start: 8, end: 8, top: 10, bottom: 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: LayoutBuilder(builder: (context, bound) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        bodyLargeText("You don't have any trades yet.", context,
                            color: Colors.white,
                            useGradient: false,
                            fontSize: 17,
                            textAlign: TextAlign.center),
                        height20(),
                        GestureDetector(
                          onTap: () => Get.to(
                              const SubscriptionPage(initPurchaseDialog: true)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              // color: appLogoColor,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: appLogoColor, width: 2),
                            ),
                            child: capText(
                              'Buy Trade',
                              context,
                              color: Colors.white,
                              textAlign: TextAlign.center,
                              useGradient: true,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (showList)
                      ...dashBoardProvider.subscriptionPacks
                          .map((pack) => Builder(builder: (context) {
                                // return Container(
                                //   margin:
                                //       EdgeInsets.only(right: 10, top: 10),
                                //   child: buildCachedNetworkImage(
                                //       'https://mywealthclub.com/assets/customer-panel/img/product/usd-monthly-pack-1.png'),
                                // );
                                //color for monthly, gold and platinum
                                Color monthlyColor = const Color(0xFFCC97D1);
                                Color goldColor = const Color(0xFFF9CE83);
                                Color platinumColor = const Color(0xFFB1B0B0);

                                Color color1 = pack.packageId == '1'
                                    ? monthlyColor
                                    : pack.packageId == '2'
                                        ? goldColor
                                        : pack.packageId == '3'
                                            ? platinumColor
                                            : Colors.white;

                                Color color2 = pack.packageId == '1'
                                    ? const Color.fromARGB(255, 221, 212, 248)
                                    : pack.packageId == '2'
                                        ? const Color.fromARGB(
                                            255, 255, 241, 199)
                                        : pack.packageId == '3'
                                            ? const Color.fromARGB(
                                                255, 209, 245, 245)
                                            : Colors.white;
                                Color color3 = pack.packageId == '1'
                                    ? const Color(0xFF96C5FF)
                                    : pack.packageId == '2'
                                        ? const Color(0xFFFA8B8F)
                                        : pack.packageId == '3'
                                            ? const Color(0xFF59F3CF)
                                            : Colors.white;
                                return GestureDetector(
                                  onTap: () => Get.to(const SubscriptionPage(
                                      initPurchaseDialog: false)),
                                  child: Container(
                                    width: size.width * 0.4,
                                    margin: EdgeInsets.only(
                                        top: size.height * 0.02,
                                        right: dashboardProvider
                                                    .subscriptionPacks
                                                    .indexOf(pack) <
                                                dashBoardProvider
                                                        .subscriptionPacks
                                                        .length -
                                                    1
                                            ? 10
                                            : 0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [color2.darken(30), color3],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(100),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color.fromARGB(
                                                29, 252, 197, 197),
                                            spreadRadius: 5,
                                            blurRadius: 5)
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: color1,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  spreadRadius: 5,
                                                  blurRadius: 15)
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: titleLargeText(
                                              '$currency_icon${pack.payableAmt ?? ''}',
                                              context,
                                              color: Colors.white,
                                              useGradient: false),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            titleLargeText(
                                                pack.packageName ?? '', context,
                                                color: Colors.white,
                                                textAlign: TextAlign.center,
                                                useGradient: false),
                                            height5(),
                                            bodyLargeText(
                                                pack.paymentType ?? '', context,
                                                color: Colors.white60,
                                                textAlign: TextAlign.center,
                                                useGradient: false),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                                Icons
                                                    .access_time_filled_rounded,
                                                color: color3,
                                                size: 20),
                                            width5(),
                                            Expanded(
                                              child: capText(
                                                DateFormat()
                                                    .add_yMMMEd()
                                                    // .add_jm()
                                                    .format(DateTime.parse(
                                                        pack.createdAt ?? '')),
                                                context,
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }))
                          .toList(),
                    if (dashBoardProvider.loadingDash)
                      ...[1, 2, 3, 4].map(
                        (e) => Builder(builder: (context) {
                          Color color1 = const Color(0xFFCC97D1);
                          Color color2 =
                              const Color.fromARGB(255, 221, 212, 248);
                          Color color3 = const Color(0xFF96C5FF);
                          return Container(
                            width: size.width * 0.4,
                            margin: EdgeInsets.only(
                                top: size.height * 0.02, right: e < 4 ? 10 : 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color2.darken(30), color3],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(100),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromARGB(29, 252, 197, 197),
                                    spreadRadius: 5,
                                    blurRadius: 5)
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      color: color1.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            spreadRadius: 5,
                                            blurRadius: 15)
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Skeleton(
                                      height: 20,
                                      width: 50,
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Skeleton(
                                      height: 20,
                                      width: 50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    height5(),
                                    Skeleton(
                                      height: 20,
                                      width: 50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded,
                                        color: color3, size: 20),
                                    width5(),
                                    Expanded(
                                      child: Skeleton(
                                        height: 20,
                                        width: 50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                  ],
                ),
        ),
        buildSubscriptionStatusBar(context, dashBoardProvider, authProvider),
      ],
    );
  }

  Container buildSubscriptionStatusBar(BuildContext context,
      DashBoardProvider dashBoardProvider, AuthProvider authProvider) {
    DateTime? expiryDate;
    try {
      expiryDate = DateTime.parse(authProvider.userData.expiryDate ?? '');
    } catch (e) {
      expiryDate = null;
    }
    double remaining = 100 - dashBoardProvider.subs_per.toDouble();
    return (dashBoardProvider.loadingDash || dashBoardProvider.subscriptionVal)
        ? Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(left: 8, right: 8, top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white10),
            child: !dashBoardProvider.loadingDash
                ? Column(
                    children: [
                      if (dashBoardProvider.subscriptionVal)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                    text: 'Your subscription will expire on',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      if (expiryDate != null)
                                        TextSpan(
                                            text:
                                                ' ${formatDate(expiryDate, 'dd MMMM yyyy')} ',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                      const TextSpan(
                                        text: '. ',
                                      ),
                                      TextSpan(
                                        text: '\nUpgrade Now',
                                        style: const TextStyle(
                                            color: appLogoColor,
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Get.to(const SubscriptionPage(
                                                initPurchaseDialog: true));
                                          },
                                      ),
                                    ]),
                              ),
                            ),
                            width10(),
                            // CircularPercentIndicator(
                            //   radius: 80.0,
                            //   lineWidth: 15.0,
                            //   animation: true,
                            //   percent: 0.7,
                            //   center: titleLargeText(
                            //     '${remaining.toStringAsFixed(1) + '%'}\nremaining',
                            //     context,
                            //     useGradient: false,
                            //     textAlign: TextAlign.center,
                            //   ),
                            // footer: Text(
                            //   "Sales this week",
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.bold,
                            //       fontSize: 17.0),
                            // ),
                            //   circularStrokeCap: CircularStrokeCap.round,
                            //   progressColor: Color(0xFF298AEF),
                            //   backgroundColor: Colors.white30,
                            // ),
                            SizedBox(
                              // color: redDark,
                              height: 100,
                              width: 100,
                              child: Ring(
                                percent: remaining,
                                color: RingColorScheme(
                                    backgroundColor: Colors.white30,
                                    ringGradient: [
                                      //color for danger
                                      Colors.red,
                                      //color for warning
                                      Colors.yellow,
                                      Colors.yellow,
                                      //color for success
                                      Colors.green,
                                      Colors.green,
                                      Colors.green,
                                    ]),
                                radius: 50,
                                // showBackground: false,
                                width: 10,
                                child: Center(
                                  child: bodyLargeText(
                                    '${remaining.toStringAsFixed(1) + '%'}\nremaining',
                                    context,
                                    useGradient: false,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // footer: Text(
                                //   "Sales this week",
                                //   style: TextStyle(
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: 17.0),
                                // ),
                                // circularStrokeCap: CircularStrokeCap.round,
                                // progressColor: Color(0xFF298AEF),
                                // backgroundColor: Colors.white30,
                              ),
                            ),
                            width10(),
                            // Stack(
                            //   children: [
                            //     ClipRRect(
                            //       borderRadius: BorderRadius.circular(10),
                            //       child: FAProgressBar(
                            //         currentValue: remaining,
                            //         size: 20,
                            //         maxValue: 100,
                            //         changeColorValue: 100,
                            //         changeProgressColor: appLogoColor,
                            //         backgroundColor: Colors.white30,
                            //         progressColor:
                            //             Color.fromARGB(255, 153, 233, 156),
                            //         animatedDuration:
                            //             const Duration(milliseconds: 300),
                            //         direction: Axis.horizontal,
                            //         verticalDirection: VerticalDirection.down,
                            //         displayText: '',
                            //         formatValueFixed: 1,
                            //         displayTextStyle: TextStyle(
                            //             fontSize: 0, color: Colors.white),
                            //       ),
                            //     ),
                            //     Positioned(
                            //       top: 0,
                            //       bottom: 0,
                            //       left: 0,
                            //       right: 0,
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           capText(
                            //             '${remaining.toStringAsFixed(1)} % remaining',
                            //             context,
                            //             color: Colors.black,
                            //           ),
                            //         ],
                            //       ),
                            //     )
                            //   ],
                            // ),
                          ],
                        ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(
                          height: 10,
                          width: double.maxFinite,
                          textColor: Colors.white70,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height10(),
                        Skeleton(
                          height: 10,
                          width: Get.width * 0.3,
                          textColor: Colors.white70,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height10(),
                        Skeleton(
                          height: 20,
                          width: double.maxFinite,
                          textColor: const Color.fromARGB(255, 78, 112, 78),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ),
          )
        : Container();
  }

  Container buildQRCodeContainer(DashBoardProvider dashBoardProvider,
      {Size? size,
      Size? logoS,
      bool showLogo = true,
      QrDataModuleShape dataModuleShape = QrDataModuleShape.circle,
      Color? color}) {
    return Container(
      height: size?.height,
      width: size?.width,
      padding: size != null ? null : const EdgeInsets.symmetric(horizontal: 50),
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: !dashBoardProvider.loadingDash ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 3000),
            curve: Curves.fastOutSlowIn,
            child: QrImageView(
              data: dashBoardProvider.promotionString,
              version: QrVersions.auto,
              gapless: false,
              foregroundColor: color ?? Colors.white,
              padding: EdgeInsets.zero,
              // embeddedImage:
              //     assetImageProvider(Assets.appLogo_S, fit: BoxFit.contain),
              // embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40, 40)),
              dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: dataModuleShape, color: Colors.red),
            ),
          ),
          if (dashBoardProvider.loadingDash)
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                    opacity: dashBoardProvider.loadingDash ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 3000),
                    curve: Curves.fastOutSlowIn,
                    child: Skeleton(textColor: Colors.white38))),
          if (!dashBoardProvider.loadingDash && showLogo)
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: !dashBoardProvider.loadingDash ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 3000),
                  curve: Curves.fastOutSlowIn,
                  child: Center(
                    child: Container(
                        width: logoS?.width ?? 40,
                        height: logoS?.height ?? 40,
                        padding: logoS == null ? const EdgeInsets.all(5) : null,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child:
                            assetImages(Assets.appLogo_S, fit: BoxFit.contain)),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildTeamBuildingReferralLink(
      BuildContext context, DashBoardProvider dashBoardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UiCategoryTitleContainer(
                child: bodyLargeText('Share your referral link', context)),
            width5(),
            GestureDetector(
                onTap: dashBoardProvider.loadingDash
                    ? null
                    : () => Share.share(createDeepLink(
                        sponsor: authProvider.userData.username)),
                child: SizedBox(
                    width: 30,
                    height: 30,
                    child: assetSvg(Assets.share, color: Colors.white))),
          ],
        ),
        height10(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Expanded(
                        child: dashBoardProvider.loadingDash
                            ? Skeleton(
                                height: 16,
                                style: SkeletonStyle.text,
                                textColor: Colors.white38)
                            : capText(
                                dashBoardProvider.teamBuildingUrl,
                                context,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white,
                                maxLines: 1,
                              ),
                      ),
                      IconButton(
                        onPressed: dashBoardProvider.loadingDash
                            ? null
                            : () async => await Clipboard.setData(ClipboardData(
                                    text: dashBoardProvider.teamBuildingUrl))
                                .then((_) => Toasts.showFToast(
                                    context, 'Link copied to clipboard.',
                                    icon: Icons.copy,
                                    bgColor: appLogoColor.withOpacity(0.9))),
                        icon: const Icon(Icons.copy,
                            color: Colors.white, size: 15),
                      )
                    ],
                  ),
                ),
              ),
              width10(),
              GestureDetector(
                  onTap: dashBoardProvider.loadingDash
                      ? null
                      : () =>
                          sendWhatsapp(text: dashBoardProvider.teamBuildingUrl),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: assetSvg(Assets.whatsappColored, fit: BoxFit.cover),
                  )),
              width10(),
              GestureDetector(
                  onTap: dashBoardProvider.loadingDash
                      ? null
                      : () =>
                          sendTelegram(text: dashBoardProvider.teamBuildingUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child:
                          assetSvg(Assets.telegramColored, fit: BoxFit.cover),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  buildTiers(BuildContext context, DashBoardProvider dashBoardProvider) {
    final List<double> data = [10, 15, 7, 20, 12];
    return [
      ...dashBoardProvider.customerReward.map((e) {
        int rId = int.parse(e.id ?? '0');
        int pair = int.parse(e.pair ?? '0');
        int sumPair = int.parse(e.sumPair ?? '0');
        int members = 0;
        bool completed = false;
        bool active = false;
        bool notCompleted = false;
        if (rId == 1) {
          if (dashboardProvider.get_active_member1 > sumPair) {
            completed = true;
            members = pair;
          } else {
            if (dashboardProvider.get_active_member1 < sumPair &&
                dashboardProvider.get_active_member1 >= (sumPair - pair)) {
              active = true;
              members = dashboardProvider.get_active_member1 - (sumPair - pair);
            }
          }
        } else if (rId == 2) {
          if (dashboardProvider.get_active_member2 > sumPair) {
            completed = true;
            members = pair;
          } else {
            if (dashboardProvider.get_active_member2 < sumPair &&
                dashboardProvider.get_active_member2 >= (sumPair - pair)) {
              active = true;
              members = dashboardProvider.get_active_member2 - (sumPair - pair);
            }
          }
        } else {
          if (dashboardProvider.get_active_member3 > sumPair) {
            completed = true;
            members = pair;
          } else {
            if (dashboardProvider.get_active_member3 < sumPair &&
                dashboardProvider.get_active_member3 >= (sumPair - pair)) {
              active = true;
              members = dashboardProvider.get_active_member3 - (sumPair - pair);
            }
          }
        }
        double per = ((members / pair) * 100);
        return active || completed
            ? _DashBoardCustomerRewardTile(
                customerReward: e,
                completed: completed,
                active: active,
                sumPair: sumPair,
                members: members,
                per: per,
                data: data)
            : Container();
      })
    ];
  }

  buildCardFeatureListview(
      BuildContext context, Size size, DashBoardProvider dashBoardProvider) {
    return SizedBox(
      height: size.height * 0.3,
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiCategoryTitleContainer(
              child: bodyLargeText('Buy Credit Cards'.toUpperCase(), context)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              scrollDirection: Axis.horizontal,
              children: [
                if (!dashboardProvider.loadingDash)
                  ...dashboardProvider.cards
                      .map(
                        (card) => buildMainPageCardImageWidget(
                            context, size, dashBoardProvider, card),
                      )
                      .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildMainPageCardImageWidget(BuildContext context, Size size,
      DashBoardProvider dashBoardProvider, Map<String, dynamic> card) {
    final size = MediaQuery.of(context).size;
    double offset = 2;
    return GestureDetector(
      onTap: () => Get.to(CreditCardPurchaseScreen(card: card)),
      child: Stack(
        children: [
          Container(
            width: size.width * 0.8,
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: buildCachedNetworkImage(
                card['image'],
                pw: size.width * 0.8,
                ph: double.maxFinite,
                errorBgColor: Colors.white70,
                placeholderBgColor: Colors.white70,
                errorStackChild: Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        bodyLargeText(
                          card['name'],
                          context,
                          color: Colors.white,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(offset, offset),
                                  blurRadius: 8.0,
                                  color: const Color.fromARGB(0, 0, 0, 0)),
                              Shadow(
                                  offset: Offset(offset, offset),
                                  blurRadius: 10.0,
                                  color: appLogoColor),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ),
          Positioned(
              right: card['name'] == 'Visa Card' ? null : 40,
              left: card['name'] == 'Visa Card' ? 30 : null,
              bottom: card['name'] == 'Visa Card' ? 5 : null,
              top: card['name'] == 'Visa Card' ? null : 60,
              child: titleLargeText(card['c_name'], context,
                  textAlign: TextAlign.start)),
          if (card['qr_code'] != null)
            Positioned(
                left: 30,
                bottom: 60,
                child: SizedBox(
                    height: 60,
                    width: 60,
                    child: buildCachedNetworkImage(card['qr_code'])))
        ],
      ),
    );
  }
}

class _EventsSliderWidget extends StatefulWidget {
  _EventsSliderWidget({super.key, required this.listBanners});
  List<BannerModel> listBanners;

  @override
  State<_EventsSliderWidget> createState() => _EventsSliderWidgetState();
}

class _EventsSliderWidgetState extends State<_EventsSliderWidget> {
  late PageController pageController;
  int currentIndex = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
    if (widget.listBanners.length > 1) {
      timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        currentIndex < widget.listBanners.length - 1
            ? currentIndex++
            : currentIndex = 0;
        pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Carousel Customized
    return BannerCarousel(
      // banners: widget.listBanners,
      customizedBanners: [
        ...widget.listBanners.map((e) {
          return GestureDetector(
            onTap: () {
              sl.get<EventTicketsProvider>().buyEventTicketsRequest(e.id);
              Get.to(BuyEventTicket(
                  event: sl
                      .get<EventTicketsProvider>()
                      .eventsList
                      .firstWhere((element) => element.id == e.id)));
            },
            child: Container(
              width: double.maxFinite,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: buildCachedNetworkImage(
                  e.imagePath,
                  // 'https://mywealthclub.com/assets/images/ticket-img/my-wealth-club-launch-event.jpg',
                  pw: double.maxFinite,
                  ph: 500,
                  fit: BoxFit.contain,
                  errorBgColor: Colors.white10,
                  placeholderBgColor: Colors.white10,
                  errorStackChild: Container(),
                ),
              ),
            ),
          );
        }).toList(),
      ],
      customizedIndicators: const IndicatorModel.animation(
          width: 7, height: 7, spaceBetween: 2, widthAnimation: 15),
      height: 500,
      activeColor: appLogoColor,
      disableColor: Colors.white,
      animation: true,
      borderRadius: 10,
      onTap: (id) {
        Get.to(BuyEventTicket(
            event: sl
                .get<EventTicketsProvider>()
                .eventsList
                .firstWhere((element) => element.id == id)));
      },
      width: double.maxFinite,
      indicatorBottom: false,
      pageController: pageController,
    );
  }
}

class _MainPageAccademicVideoList extends StatelessWidget {
  const _MainPageAccademicVideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(builder: (context, provider, _) {
      bool showList = provider.categoryVideos.isNotEmpty &&
          provider.categoryVideos[0].videoList!.isNotEmpty;
      bool isActive = sl.get<AuthProvider>().userData.salesActive == '1';
      return Container(
        // color: Colors.tealAccent.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    UiCategoryTitleContainer(
                        child:
                            bodyLargeText('Master Class'.capitalize!, context)),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => Get.to(const DrawerVideosMainPage()),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyMedText(
                            'View All',
                            context,
                          ),
                          const Icon(Icons.keyboard_arrow_right_rounded,
                              color: Colors.white)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //build video list
            height10(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: provider.loadingVideos
                  ? 150
                  : showList
                      ? 150
                      : 150,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                children: [
                  if (!provider.loadingVideos && showList)
                    ...provider.categoryVideos[0].videoList!.map((video) {
                      var i =
                          provider.categoryVideos[0].videoList!.indexOf(video);
                      return GestureDetector(
                        onTap: () {
                          if (!isActive) {
                            inActiveUserAccessDeniedDialog(context);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 8),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: bColor(),
                            border: Border.all(
                                color: appLogoColor.withOpacity(0.9), width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: AbsorbPointer(
                            absorbing: !isActive,
                            child: AccademicVideoCard(
                              category: provider.categoryVideos[0],
                              video: video,
                              i: i,
                              showBorder: false,
                              showCategories: false,
                              border: Border.all(color: appLogoColor, width: 1),
                              textColor: Colors.white,
                              loading: false,
                            ),
                          ),
                        ),
                      );
                    }),
                  if (provider.loadingVideos)
                    ...List.generate(
                        5,
                        (index) => AbsorbPointer(
                              child: Container(
                                margin:
                                    const EdgeInsetsDirectional.only(end: 8),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: bColor(),
                                  border: Border.all(
                                      color: appLogoColor.withOpacity(0.9),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: AccademicVideoCard(
                                  category: VideoCategoryModel(),
                                  video: CategoryVideo(),
                                  i: index,
                                  showBorder: false,
                                  showCategories: false,
                                  border:
                                      Border.all(color: appLogoColor, width: 1),
                                  textColor: Colors.white,
                                  loading: true,
                                ),
                              ),
                            )),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

Future<dynamic> inActiveUserAccessDeniedDialog(BuildContext context,
    {void Function()? onOk, void Function()? onCancel}) {
  AwesomeDialog dialog = AwesomeDialog(
    dialogType: DialogType.info,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    title: 'Access Denied?',
    desc: 'You are not active user. Please subscribe to get access.',
    context: context,
    btnOkText: 'Subscribe Now',
    btnCancelText: 'Not Now',
    btnCancelOnPress: () {
      if (onCancel != null) onCancel();
    },
    btnOkOnPress: () {
      if (onOk != null) onOk();
      Get.to(() => const SubscriptionPage(initPurchaseDialog: true));
    },
    reverseBtnOrder: true,
  );
  return dialog.show();
  return Get.defaultDialog(
    title: 'Access Denied',
    radius: 10,
    middleText: 'You are not active user. Please subscribe to get access.',
    confirmTextColor: Colors.white,
    titleStyle: const TextStyle(color: Colors.white),
    middleTextStyle: const TextStyle(color: Colors.white70),
    backgroundColor: bColor(1),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                  color: appLogoColor, width: 1, style: BorderStyle.solid),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => Get.back(),
            child: const Text('Not Now', style: TextStyle(color: Colors.white)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: appLogoColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Get.back();
              Get.to(() => const SubscriptionPage(initPurchaseDialog: true));
            },
            child: const Text('Subscribe Now',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ],
  );
}

class _BuildUpcomingEventCard extends StatelessWidget {
  const _BuildUpcomingEventCard({
    required this.event,
    required this.loading,
  });
  final WebinarEventModel event;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    int index = 2;
    // create shimmer effect fro upcoming event

    return LayoutBuilder(builder: (context, bound) {
      double width = Get.width;
      double maxWidth = width > 500 ? 500 : width;
      double pd = 5;
      var url =
          // 'https://www.analyticsinsight.net/wp-content/uploads/2021/10/Top-10-Cheap-Cryptocurrencies-to-Buy-in-October-2021.jpg';
          // 'https://i.ytimg.com/vi/qI_zuDqcTEI/hqdefault.jpg';
          // 'https://img.youtube.com/vi/ezdP1lzsNUg/0.jpg';
          'https://img.youtube.com/vi/${event.webinarId}/0.jpg';
      String title = event.webinarTitle ?? '';
      DateTime? date =
          event.webinarTime != null ? DateTime.parse(event.webinarTime!) : null;

      return Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                constraints:
                    BoxConstraints(maxWidth: maxWidth, minWidth: maxWidth),
                padding: EdgeInsets.all(pd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: appLogoColor.withOpacity(0.9),
                  boxShadow: [
                    // if (!loading)
                    //   BoxShadow(
                    //     color: appLogoColor.withOpacity(0.9),
                    //     blurRadius: 15,
                    //     spreadRadius: 15,
                    //     offset: Offset(5, 5),
                    //   ),
                  ],
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: loading
                        ? Skeleton(
                            animation: SkeletonAnimation.none,
                            height: bound.maxHeight,
                            textColor: Colors.white10,
                          )
                        : buildCachedNetworkImage(
                            url,
                            fit: BoxFit.cover,
                            cache: true,
                            ph: double.infinity,
                            pw: double.infinity,
                            placeholderImg: Assets.videoPlaceholder,
                          )),
              ),
              Positioned(
                top: pd,
                bottom: pd,
                left: pd,
                right: pd,
                child: LayoutBuilder(builder: (context, bound) {
                  return Container(
                    // margin: EdgeInsets.all(5),
                    decoration: loading
                        ? null
                        : BoxDecoration(
                            backgroundBlendMode: BlendMode.darken,
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                    padding: const EdgeInsets.all(10),

                    child: Row(
                      children: [
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(10),
                        //   child: Container(
                        //     width: bound.maxWidth * 0.3,
                        //     height: bound.maxWidth * 0.3 * (2 / 4),
                        //     child: loading
                        //         ? Skeleton(
                        //             height: bound.maxHeight,
                        //             textColor: Colors.white54)
                        //         : buildCachedNetworkImage(url,
                        //             fit: BoxFit.fill),
                        //   ),
                        // ),
                        // width10(),
                        Expanded(child: LayoutBuilder(builder: (context, tb) {
                          //decide text size on the basis of width
                          double titleS = 12;
                          if (tb.maxWidth > 300) {
                            titleS = 16;
                          } else if (tb.maxWidth > 200) {
                            titleS = 14;
                          }
                          double timeS = 10;
                          if (tb.maxWidth > 300) {
                            timeS = 12;
                          } else if (tb.maxWidth > 200) {
                            timeS = 10;
                          }
                          double capS = 10;
                          if (tb.maxWidth > 300) {
                            capS = 12;
                          } else if (tb.maxWidth > 200) {
                            capS = 10;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              loading
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Skeleton(
                                          height: titleS,
                                          textColor: Colors.white54,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        height5(),
                                        Skeleton(
                                          height: titleS,
                                          width: 70,
                                          textColor: Colors.white54,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        )
                                      ],
                                    )
                                  : bodyLargeText(
                                      title,
                                      context,
                                      color: Colors.white,
                                      useGradient: false,
                                      fontSize: titleS,
                                      textAlign: TextAlign.start,
                                    ),
                              const Spacer(),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.white70,
                                        size: capS,
                                      ),
                                      width5(),
                                      loading
                                          ? Skeleton(
                                              height: timeS,
                                              width: 70,
                                              textColor: Colors.white54,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            )
                                          : RichText(
                                              text: TextSpan(children: [
                                              TextSpan(
                                                text: formatDate(
                                                    date!, 'dd MMM yyyy'),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: timeS,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ])),
                                    ],
                                  ),
                                  width10(),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white70,
                                        size: capS,
                                      ),
                                      width5(),
                                      loading
                                          ? Skeleton(
                                              height: timeS,
                                              width: 50,
                                              textColor: Colors.white54,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            )
                                          : RichText(
                                              text: TextSpan(children: [
                                              TextSpan(
                                                text: formatDate(
                                                    date!, 'hh:mm a'),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: timeS,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ])),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        }))
                      ],
                    ),
                  );
                }),
              ),
              // play button
              Positioned.fill(
                child: Visibility(
                  visible: !loading,
                  child: Center(
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: () {
                        Navigator.pushNamed(
                            context, YoutubePlayerPage.routeName,
                            arguments: jsonEncode({
                              'videoId': event.webinarId,
                              // 'videoId': 'ezdP1lzsNUg',
                              'isLive': true,
                              'rotate': true,
                              'data': event.toJson()
                            }));
                      },
                      child: Container(
                        width: 57,
                        height: 57,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(1),
                          shape: BoxShape.circle,
                        ),
                        padding:
                            const EdgeInsets.only(left: 6, top: 10, bottom: 10),
                        child: Center(child: assetImages('playbutton.png')),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                top: pd,
                bottom: pd + 10,
                left: pd,
                right: pd + 10,
                child: LayoutBuilder(builder: (context, tb) {
                  double titleS = 12;
                  if (tb.maxWidth > 300) {
                    titleS = 16;
                  } else if (tb.maxWidth > 200) {
                    titleS = 14;
                  }
                  double timeS = 10;
                  if (tb.maxWidth > 300) {
                    timeS = 12;
                  } else if (tb.maxWidth > 200) {
                    timeS = 10;
                  }
                  double capS = 10;
                  if (tb.maxWidth > 300) {
                    capS = 12;
                  } else if (tb.maxWidth > 200) {
                    capS = 10;
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      loading
                          ? Skeleton(
                              height: 25,
                              width: 60,
                              textColor: Colors.white54,
                              borderRadius: BorderRadius.circular(5),
                            )
                          : index % 2 == 0
                              ?
                              // build live container
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: capS / 3, horizontal: capS),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icon(
                                      //   Icons.circle,
                                      //   color: Colors.white,
                                      //   size: capS * 0.6,
                                      // ),
                                      // width5(),
                                      capText(
                                        'Live',
                                        context,
                                        color: Colors.white,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                )
                              : Builder(builder: (context) {
                                  const defaultDuration =
                                      Duration(hours: 2, minutes: 30);
                                  return SlideCountdown(
                                    duration: defaultDuration,
                                    padding: EdgeInsets.all(capS / 2),
                                    separatorType: SeparatorType.symbol,
                                    textStyle: TextStyle(
                                        fontSize: capS, color: Colors.white),
                                    durationTitle: DurationTitle.id(),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  );
                                }),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class UiCategoryTitleContainer extends StatelessWidget {
  const UiCategoryTitleContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bound) {
      return Stack(
        children: [
          Container(
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    Colors.white12,
                    Colors.transparent
                  ],
                      stops: [
                    0.2,
                    1
                  ], // Add color stops (0.2 = 20% of the container, 1.0 = 100% of the container)
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [child])),
          Container(
            width: 5,
            height: 40,
            decoration: const BoxDecoration(
                color: appLogoColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                )),
          ),
        ],
      );
    });
  }
}

class _DashBoardCustomerRewardTile extends StatefulWidget {
  const _DashBoardCustomerRewardTile({
    super.key,
    required this.completed,
    required this.active,
    required this.sumPair,
    required this.members,
    required this.per,
    required this.data,
    required this.customerReward,
  });

  final bool completed;
  final CustomerReward customerReward;
  final bool active;
  final int sumPair;
  final int members;
  final double per;
  final List<double> data;

  @override
  State<_DashBoardCustomerRewardTile> createState() =>
      _DashBoardCustomerRewardTileState();
}

class _DashBoardCustomerRewardTileState
    extends State<_DashBoardCustomerRewardTile> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    print(
        '${widget.completed} ${widget.active} ${widget.sumPair} ${widget.members}');
    return Consumer<DashBoardProvider>(
      builder: (context, dashBoardProvider, child) {
        return GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Card(
            elevation: 10,
            color: widget.completed
                ? Colors.greenAccent.withOpacity(0.1)
                : widget.active
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dashBoardProvider.loadingDash
                      ? Skeleton(
                          textColor: Colors.white70,
                          height: 15,
                          width: 120,
                          borderRadius: BorderRadius.circular(3),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            bodyLargeText(
                                '${widget.customerReward.name}', context),
                          ],
                        ),
                  height20(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          capText(
                              'Active Member: ${!dashBoardProvider.loadingDash ? (widget.completed ? widget.sumPair :
                                  // widget.active ? dashBoardProvider.get_active_member :
                                  widget.members) : ''}',
                              context),
                          if (dashBoardProvider.loadingDash)
                            Skeleton(
                              height: 10,
                              width: 20,
                              textColor: Colors.white70,
                              borderRadius: BorderRadius.circular(1),
                            )
                        ],
                      ),
                      Row(
                        children: [
                          capText(
                              'Target Member:  ${!dashBoardProvider.loadingDash ? widget.customerReward.sumPair ?? '' : ''}',
                              context),
                          if (dashBoardProvider.loadingDash)
                            Skeleton(
                              height: 10,
                              width: 20,
                              textColor: Colors.white70,
                              borderRadius: BorderRadius.circular(1),
                            )
                        ],
                      ),
                    ],
                  ),
                  height5(),
                  SizedBox(
                    height: 20,
                    child: dashBoardProvider.loadingDash
                        ? Skeleton(
                            textColor: appLogoColor.withOpacity(0.4),
                            width: double.maxFinite,
                            borderRadius: BorderRadius.circular(5))
                        : LiquidLinearProgressIndicator(
                            value: widget.per >= 100
                                ? widget.per
                                : widget.per / 100,
                            valueColor: AlwaysStoppedAnimation(widget.completed
                                ? Colors.greenAccent.withOpacity(0.7)
                                : widget.active
                                    ? appLogoColor.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.2)),
                            backgroundColor: Colors.white38,
                            borderColor: Colors.white38,
                            borderWidth: 0.0,
                            borderRadius: 5.0,
                            direction: Axis.horizontal,
                            center: capText(
                                "${widget.per.toStringAsFixed(1)}%", context),
                          ),
                  ),
                  Visibility(
                    visible: expanded &&
                        dashBoardProvider.get_active_Leg.isNotEmpty &&
                        (widget.completed || widget.active),
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 200,
                      // child: BarChartRace(data: widget.data),
                      child: _BarChartWidget(
                        legs: dashBoardProvider.get_active_Leg,
                        customerReward: widget.customerReward,
                        color: widget.completed
                            ? Colors.greenAccent
                            : appLogoColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BarChartWidget extends StatefulWidget {
  const _BarChartWidget(
      {Key? key,
      required this.legs,
      required this.customerReward,
      required this.color})
      : super(key: key);
  final List<GetActiveLegModel> legs;
  final CustomerReward customerReward;
  final Color color;

  @override
  State<_BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<_BarChartWidget> {
  late List<GetActiveLegModel> _chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _chartData = widget.legs;
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int condition = int.parse(widget.customerReward.requireCondition ?? '0');
    return SfCartesianChart(
      tooltipBehavior: _tooltipBehavior,
      series: <ChartSeries>[
        BarSeries<GetActiveLegModel, String>(
          name: widget.customerReward.name ?? '',
          dataSource: _chartData,
          xValueMapper: (GetActiveLegModel gal, index) => gal.username,
          yValueMapper: (GetActiveLegModel gal, _) {
            int members = int.parse(gal.activeMember ?? '0');
            return members > condition ? condition : members;
          },
          color: widget.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: Colors.white, fontSize: 12),
            angle: 0,
          ),
          enableTooltip: true,
          isVisible: true,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(3),
            bottomRight: Radius.circular(3),
          ),
        )
      ],
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Legs',
          textStyle: const TextStyle(color: Colors.white, fontSize: 9),
        ),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 0),
        isVisible: false,
        labelRotation: 45,
        interval: 1,
        majorGridLines: const MajorGridLines(color: Colors.transparent),
        minorGridLines: const MinorGridLines(color: Colors.transparent),
        axisLine: const AxisLine(width: 0, color: Colors.transparent),
      ),
      primaryYAxis: NumericAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        labelStyle: const TextStyle(color: Colors.white),
        majorGridLines: const MajorGridLines(color: Colors.transparent),
        minorGridLines: const MinorGridLines(color: Colors.transparent),
        axisLine: const AxisLine(width: 0, color: Colors.transparent),
      ),
      isTransposed: true,
    );
  }
}

class MainPageRewardImageCard extends StatelessWidget {
  const MainPageRewardImageCard({
    super.key,
    required this.url,
    required this.title,
    required this.dashBoardProvider,
    required this.show,
  });

  final String url;
  final String title;
  final DashBoardProvider dashBoardProvider;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: !dashBoardProvider.loadingDash ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 3000),
          curve: Curves.fastOutSlowIn,
          child: Visibility(
            visible: dashBoardProvider.loadingDash ||
                (!dashBoardProvider.loadingDash && show) ||
                (!dashBoardProvider.loadingDash && title == 'Achieved'),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              height: 250,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: assetImageProvider('achieved.gif'),
                    fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  height10(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(00.7),
                          offset: const Offset(1, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  height10(),
                  if (!dashBoardProvider.loadingDash)
                    Expanded(
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          placeholder: (context, url) => SizedBox(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: appLogoColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              assetImages(Assets.noImage, width: 200),
                          cacheManager: CacheManager(Config(
                              "${AppConstants.packageID}_$title",
                              stalePeriod: const Duration(days: 7))),
                        ),
                        // child: Image.network(url),
                      ),
                    ),
                  height20(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: AnimatedOpacity(
                opacity: dashBoardProvider.loadingDash ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 3000),
                curve: Curves.fastOutSlowIn,
                child: Skeleton(
                  height: 250,
                  width: double.maxFinite,
                  textColor: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationExample extends StatefulWidget {
  @override
  _NotificationExampleState createState() => _NotificationExampleState();
}

class _NotificationExampleState extends State<NotificationExample> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> showNotification(int id, String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel_id', // Replace with your channel ID
      'Channel name', // Replace with your channel name
      channelDescription:
          'Channel description', // Replace with your channel description
      importance: Importance.max,
      priority: Priority.high,
    );
/*
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);*/
    showCustomizedNotification('_title', '_body', 'payload', '_image');
    // await flutterLocalNotificationsPlugin.show(
    //   id,
    //   title,
    //   body,
    //   platformChannelSpecifics,
    //   payload: 'payload', // Replace with your payload data if needed
    //    // Use a unique threadIdentifier for each notification
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Generate multiple notifications with unique threadIdentifier
          for (int i = 1; i <= 5; i++) {
            showNotification(i, 'Notification $i', 'This is notification $i');
          }
        },
        child: const Text('Show Notifications'),
      ),
    );
  }
}
