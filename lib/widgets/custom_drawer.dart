import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mycarclub/screens/drawerPages/pin_management.dart';
import '../screens/drawerPages/downlines/team_investments.dart';
import '../screens/drawerPages/profile/change_password.dart';
import '../screens/drawerPages/profile/kyc_details_page.dart';
import '/screens/drawerPages/downlines/my_login_logs_page.dart';
import '../screens/youtube_video_play_widget.dart';
import '/database/model/response/additional/mcc_content_models.dart';
import '../screens/drawerPages/downlines/my_incomes_page.dart';
import '../screens/drawerPages/downlines/team_view/fancy_team_view.dart';
import '../screens/drawerPages/wallets/withdraw_history_page.dart';
import '/screens/drawerPages/download_pages/edcational_downloads_page.dart';
import '../screens/dashboard/company_trade_ideas_page.dart';
import '../screens/drawerPages/downlines/geration_member/direct_member_page.dart';
import '/utils/default_logger.dart';
import '../constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/notification_provider.dart';
import '/screens/Notification/notification_page.dart';
import '/screens/auth/login_screen.dart';
import '/screens/dashboard/main_page.dart';
import '../screens/drawerPages/wallets/commission_wallet/commission_wallet_page.dart';
import '/screens/drawerPages/download_pages/gallery_main_page.dart';
import '../screens/drawerPages/download_pages/videos/drawer_videos_main_page.dart';
import '/screens/drawerPages/event_tickets/event_tickets_page.dart';
import '/screens/drawerPages/inbox/inbox_screen.dart';
import '../screens/drawerPages/profile/profile_screen.dart';
import '/screens/drawerPages/subscription/subscription_page.dart';
import '/screens/drawerPages/support_pages/support_Page.dart';
import '../screens/drawerPages/downlines/team_member_page.dart';
import '/screens/drawerPages/voucher/voucher_page.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/picture_utils.dart';
import '/utils/text.dart';
import '/widgets/scroll_to_top.dart';
import 'package:provider/provider.dart';

import '../screens/drawerPages/wallets/cash_wallet_page/cash_wallet_page.dart';
import '../screens/drawerPages/profile/payment_methods_page.dart';
import '../screens/drawerPages/download_pages/drawer_video_player_page.dart';
import '../screens/drawerPages/settings_page.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final controller = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> drawerOtherItems = [
      // ['Login Logs', Assets.logsSvg],
      // ['Notifications', Assets.notification],
      ['Settings', Assets.settings],
      ['Support', Assets.support],
      ['Logout', Assets.logout],
    ];
    String buyBack = 'BuyBack';
    String buyTrade = 'Buy Trade';
    String teamInvestment = 'Team Investment';
    String pinManagement = 'Pin Management';

    Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.blueGrey.shade900,
      height: double.maxFinite,
      width: size.width * 0.8,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Consumer<DashBoardProvider>(
            builder: (context, dashBoardProvider, child) {
              return Column(
                children: [
                  buildHeader(size, context, authProvider),
                  const Divider(color: Colors.white60, height: 0, thickness: 1),
                  // height10(),
                  Expanded(
                    child: ScrollToTop(
                      scrollController: controller,
                      child: SingleChildScrollView(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Gift Voucher
                            // if (Platform.isAndroid)
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(buyBack);
                                Widget page = const GiftVoucherPage();
                                Get.to(page);
                              },
                              leading: Assets.gift,
                              title: buyBack,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  buyBack,
                            ),
                            height10(),
                            // buildMasterClass(context, authProvider),
                            // height5(),
                            // buildCompanyTradeIdea(context, authProvider),
                            // height5(),
                            // capText('Components', context,
                            //     color: Colors.white70,
                            //     fontWeight: FontWeight.bold),
                            // height10(),

                            ///Inbox
                            // DrawerTileItem(
                            //   onTap: () {
                            //     dashBoardProvider.setDrawerTile(inbox);
                            //     Widget page = const InboxScreen();
                            //     Get.to(page);
                            //   },
                            //   leading: Assets.inbox,
                            //   title: inbox,
                            //   width: size.width * 0.7,
                            //   selected:
                            //       dashBoardProvider.selectedDrawerTile == inbox,
                            // ),
                            // height10(),

                            ///holdingTank
                            // DrawerTileItem(
                            //   onTap: () {
                            //     dashBoardProvider.setDrawerTile(holdingTank);
                            //     Widget page = const HoldingTankPage();
                            //     Get.to(page);
                            //   },
                            //   leading: Assets.creditCard,
                            //   title: holdingTank,
                            //   width: size.width * 0.7,
                            //   selected: dashBoardProvider.selectedDrawerTile ==
                            //       holdingTank,
                            // ),
                            // height10(),

                            //downlines
                            buildDownlinesExpansionTile(
                                size, dashBoardProvider),
                            height10(),

                            //Earnings
                            buildEarningsExpansionTile(size, dashBoardProvider),
                            height10(),

                            ///Matrix-Analyzer
                            // DrawerTileItem(
                            //   onTap: () {
                            //     dashBoardProvider.setDrawerTile(matrixAnalyzer);
                            //     Widget page = const MatrixAnalyzerPage();
                            //     Get.to(page);
                            //   },
                            //   leading: Assets.analyzer,
                            //   title: matrixAnalyzer,
                            //   width: size.width * 0.7,
                            //   selected: dashBoardProvider.selectedDrawerTile ==
                            //       matrixAnalyzer,
                            // ),
                            // height10(),

                            // Buy Trade
                            // if (Platform.isAndroid)
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(buyTrade);
                                Widget page = const SubscriptionPage();
                                Get.to(page);
                              },
                              leading: Assets.subscription,
                              title: buyTrade,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  buyTrade,
                            ),
                            height10(),

                            ///Team Investment]
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(teamInvestment);
                                Widget page = const TeamInvestmentPage(); 
                                Get.to(page);
                              },
                              leading: Assets.subscription,
                              title: teamInvestment,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  teamInvestment,
                            ),

                            height10(),

                            ///Pin Management
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(pinManagement);
                                Widget page = const PinManagementPage();
                                Get.to(page);
                              },
                              leading: Assets.subscription,
                              title: pinManagement,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  pinManagement,
                            ),
                            height10(),

                            ///Event Ticket
                            // DrawerTileItem(
                            //   onTap: () {
                            //     dashBoardProvider.setDrawerTile(eventTicket);
                            //     Widget page = const EventTicketsPage();
                            //     Get.to(page);
                            //   },
                            //   leading: Assets.eventTicket,
                            //   title: eventTicket,
                            //   width: size.width * 0.7,
                            //   selected: dashBoardProvider.selectedDrawerTile ==
                            //       eventTicket,
                            // ),
                            // height10(),
                            //Downloads
                            // buildDownloadExpansionTile(size, dashBoardProvider),
                            // height10(),

                            buildWalletsExpansionTile(size, dashBoardProvider),
                            height10(),

                            capText('User', context,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                            height10(),
                            buildProfileExpansionTile(size, dashBoardProvider),
                            height10(),

                            //Others
                            capText('Others', context,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                            height10(),
                            ...drawerOtherItems.map((e) => buildOthersTile(
                                e, context, size, dashBoardProvider)),

                            /// whatsNew
                            // DrawerTileItem(
                            //   onTap: () {
                            //     dashBoardProvider.setDrawerTile(whatsNew);
                            //     Widget page = const WhatsNewPage();
                            //     Get.to(page);
                            //   },
                            //   leading: Assets.pages,
                            //   title: whatsNew,
                            //   width: size.width * 0.7,
                            //   selected: dashBoardProvider.selectedDrawerTile ==
                            //       whatsNew,
                            //   trailing: assetImages(Assets.newPng,
                            //       width: 25, height: 25),
                            // ),
                            // height10(),

                            buildAppPagesExpansionTile(
                                size, dashBoardProvider, authProvider),
                            height10(),
                            buildFooter(size, context, dashBoardProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  GestureDetector buildCompanyTradeIdea(
      BuildContext context, AuthProvider authProvider) {
    bool isActive = authProvider.userData.salesActive == '1';
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          inActiveUserAccessDeniedDialog(context);
        } else {
          Get.back();
          Get.to(const CompanyTradeIdeasPage());
        }
      },
      child: Row(
        children: [
          titleLargeText(
            'Company Trade Ideas',
            context,
            color: Colors.white70,
            useGradient: true,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
          width5(),
          assetLottie(Assets.tradingSignals, width: 50),
        ],
      ),
    );
  }

  Widget buildMasterClass(BuildContext context, AuthProvider authProvider) {
    return const _MasterClasses();
  }

  Column buildOthersTile(
    List<dynamic> e,
    BuildContext context,
    // AuthProvider authProvider,
    Size size,
    DashBoardProvider dashBoardProvider,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            DrawerTileItem(
              onTap: () {
                // HapticFeedback.vibrate();
                if (e[0] == 'Logout') {
                  AwesomeDialog(
                    dialogType: DialogType.question,
                    dismissOnBackKeyPress: false,
                    dismissOnTouchOutside: false,
                    title: 'Do you really want to logout?',
                    context: context,
                    btnCancelText: 'No',
                    btnOkText: 'Yes Sure!',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async {
                      await logOut(
                        'log-out button',
                        showD: false,
                        title: 'Logout',
                        content: 'Please wait...',
                      ).then((value) => Get.offAll(const LoginScreen()));
                    },
                    reverseBtnOrder: true,
                  ).show();
                } else if (e[0] == 'Notifications') {
                  Get.to(const NotificationPage());
                } else if (e[0] == 'Settings') {
                  Get.to(const SettingsPage());
                } else if (e[0] == 'Support') {
                  Get.to(const SupportPage());
                } else if (e[0] == 'Login Logs') {
                  Get.to(const MyLoginLogsPage());
                }
              },
              leading: e[1],
              title: e[0],
              width: size.width * 0.7,
              selected: dashBoardProvider.selectedDrawerTile == e[0],
            ),
            if (e[0] == 'Notifications' &&
                Provider.of<NotificationProvider>(context, listen: true)
                        .totalUnread >
                    0)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    child: capText(
                      '${Provider.of<NotificationProvider>(context, listen: true).totalUnread}',
                      context,
                    ),
                  ),
                ),
              ),
          ],
        ),
        height10(),
      ],
    );
  }

  Column buildComponentsTile(List<dynamic> e, BuildContext context, Size size,
      DashBoardProvider dashBoardProvider) {
    return Column(
      children: [
        DrawerTileItem(
          onTap: () {
            Widget page = const Scaffold();
            switch (e[0]) {
              case 'Inbox':
                page = const InboxScreen();
                break;

              case 'Gift Voucher':
                page = const GiftVoucherPage();
                break;
              case 'Event Ticket':
                page = const EventTicketsPage();
                break;
              default:
                page = Scaffold(
                    backgroundColor: mainColor,
                    body: Center(
                        child: bodyLargeText('This is Default Page', context,
                            color: Colors.white)));
                break;
            }
            Get.to(page);
          },
          leading: e[1],
          title: e[0],
          width: size.width * 0.7,
          selected: dashBoardProvider.selectedDrawerTile == e[0],
        ),
        height10(),
      ],
    );
  }

  Widget buildDownlinesExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String frontline = 'My Frontline';
    const String myTeam = 'My Team';
    const String teamView = 'Team View';

    return expansionTile(
      title: 'Downlines',
      headerAsset: Assets.downline,
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == myTeam ||
          dashBoardProvider.selectedDrawerTile == teamView ||
          dashBoardProvider.selectedDrawerTile == frontline,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(
            children: [
              ...[
                frontline,
                myTeam,
                teamView,
                // generationTreeView,
                // generationAnalyzer,
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = const Scaffold(backgroundColor: mainColor);
                      switch (e) {
                        case myTeam:
                          page = const TeamMemberPage();
                          break;

                        case frontline:
                          page = const DirectMembersPage();
                          break;
                        case teamView:
                          page = const FancyTreeView();
                          break;

                        default:
                          page = buildDefaultPage();
                          break;
                      }
                      // Get.back();
                      Get.to(page);
                    },
                    leading: e == myTeam
                        ? Assets.teamMember
                        : e == teamView
                            ? Assets.teamView
                            : e == frontline
                                ? Assets.layer
                                : Assets.analyzer,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEarningsExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String payouts = 'Payout';
    const String tradeIncome = 'Trade Income';
    const String tradeLavelReward = 'Trade Level Reward';
    const String licenceFeeLevelReward = 'Licence Fee Level Reward';
    const String withdrawals = 'Withdraw Request';
    return expansionTile(
      title: 'Earnings',
      headerAsset: Assets.cashWallet,
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == tradeIncome ||
          dashBoardProvider.selectedDrawerTile == tradeLavelReward ||
          dashBoardProvider.selectedDrawerTile == licenceFeeLevelReward ||
          dashBoardProvider.selectedDrawerTile == withdrawals ||
          dashBoardProvider.selectedDrawerTile == payouts,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Column(
            children: [
              ...[
                payouts,
                tradeIncome,
                tradeLavelReward,
                licenceFeeLevelReward,
                withdrawals,
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = buildDefaultPage();
                      switch (e) {
                        case payouts:
                          page = MyIncomesPage(title: e);
                          break;
                        case tradeIncome:
                          page = MyIncomesPage(title: e);
                          break;
                        case tradeLavelReward:
                          page = MyIncomesPage(title: e);
                          break;
                        case licenceFeeLevelReward:
                          page = MyIncomesPage(title: e);
                          break;
                        case withdrawals:
                          page = const WithdrawRequestHistoryPage();
                          break;

                        default:
                          page = buildDefaultPage();
                          break;
                      }
                      // Get.back();
                      Get.to(page);
                    },
                    leading: e == tradeIncome
                        ? Assets.cashWallet
                        : e == tradeLavelReward
                            ? Assets.commissionWallet
                            : Assets.withdraw,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildWalletsExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String topUpWallet = 'Top Up';
    const String commissionWallet = 'Commission';
    return expansionTile(
      title: 'Wallets',
      headerAsset: Assets.cashWallet,
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == topUpWallet ||
          dashBoardProvider.selectedDrawerTile == commissionWallet,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Column(
            children: [
              ...[topUpWallet, commissionWallet].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = buildDefaultPage();
                      switch (e) {
                        case topUpWallet:
                          page = const CashWalletPage();
                          break;
                        case commissionWallet:
                          page = const CommissionWalletPage();
                          break;

                        default:
                          page = Scaffold(
                            backgroundColor: mainColor,
                            body: Center(
                              child: bodyLargeText(
                                  'This is Default Page', context,
                                  color: Colors.white),
                            ),
                          );
                          break;
                      }
                      // Get.back();
                      Get.to(page);
                    },
                    leading: e == topUpWallet
                        ? Assets.cashWallet
                        : e == commissionWallet
                            ? Assets.commissionWallet
                            : Assets.withdraw,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfileExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String profile = 'View/Edit Profile';
    const String bankDetails = 'Bank Details';
    const String kycDetails = 'KYC Details';
    const String changePassword = 'Change Password';

    return expansionTile(
      headerAsset: Assets.personalInfo,
      title: 'Personal Information',
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == profile ||
          dashBoardProvider.selectedDrawerTile == bankDetails,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              ...[
                profile,
                bankDetails,
                kycDetails,
                changePassword,
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = buildDefaultPage();
                      switch (e) {
                        case profile:
                          page = const ProfileScreen();
                          break;
                        case bankDetails:
                          page = const PaymentMethodsPage();
                          break;

                        case kycDetails:
                          page = const KycDetailsPage();
                          break;
                        case changePassword:
                          page = const ChangePasswordPage();
                          break;

                        default:
                          page = buildDefaultPage();
                          break;
                      }
                      Get.to(page);
                    },
                    leading: e == profile ? Assets.profile : Assets.bank,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAppPagesExpansionTile(Size size,
      DashBoardProvider dashBoardProvider, AuthProvider authProvider) {
    const String privacyPolicy = 'Privacy Policy';
    const String termsAndConditions = 'Terms & Conditions';
    const String cancellationPolicy = 'Cancellation Policy';
    const String returnPolicy = 'Return Policy';
    const String aboutUs = 'About Us';
    List<Cancellation> pages = authProvider.appPages
        .where((element) =>
            element.headlines != null && element.headlines!.isNotEmpty)
        .toList();

    return expansionTile(
      title: 'App Pages',
      headerAsset: Assets.pages,
      initiallyExpanded:
          dashBoardProvider.selectedDrawerTile == privacyPolicy ||
              dashBoardProvider.selectedDrawerTile == termsAndConditions ||
              dashBoardProvider.selectedDrawerTile == cancellationPolicy ||
              dashBoardProvider.selectedDrawerTile == returnPolicy ||
              dashBoardProvider.selectedDrawerTile == aboutUs,
      children: [
        //Link pages
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(children: [
            ...pages.map((e) {
              var page = e;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DrawerTileItem(
                  onTap: () async {
                    Get.to(HtmlPreviewPage(
                        title: e.headlines ?? '',
                        message: e.details ?? '',
                        file_url: ''));
                  },
                  leading: Assets.pages,
                  title: e.headlines ?? '',
                  width: size.width * 0.7,
                  selected: dashBoardProvider.selectedDrawerTile ==
                      (e.headlines ?? ''),
                  opacity: 0.7,
                ),
              );
            })
          ]),
        ),
        // one - one pages

/*
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              ...[
                privacyPolicy,
                termsAndConditions,
                cancellationPolicy,
                returnPolicy,
                aboutUs
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () async {
                      Widget page = buildDefaultPage();
                      // await future(1000);
                      if (e == privacyPolicy &&
                          authProvider.mwc_content.privacy != null) {
                        Get.to(HtmlPreviewPage(
                          title: parseHtmlString(
                              authProvider.mwc_content.privacy!.headlines ??
                                  ""),
                          message:
                              authProvider.mwc_content.privacy!.details ?? "",
                          file_url:
                              authProvider.mwc_content.privacy!.image ?? "",
                        ));
                      } else if (e == termsAndConditions &&
                          authProvider.mwc_content.termCondition != null) {
                        Get.to(HtmlPreviewPage(
                          title: parseHtmlString(authProvider
                                  .mwc_content.termCondition!.headlines ??
                              ""),
                          message:
                              authProvider.mwc_content.termCondition!.details ??
                                  "",
                          file_url:
                              authProvider.mwc_content.termCondition!.image ??
                                  "",
                        ));
                      } else if (e == cancellationPolicy &&
                          authProvider.mwc_content.cancellation != null) {
                        Get.to(HtmlPreviewPage(
                          title: parseHtmlString(authProvider
                                  .mwc_content.cancellation!.headlines ??
                              ""),
                          message:
                              authProvider.mwc_content.cancellation!.details ??
                                  "",
                          file_url:
                              authProvider.mwc_content.cancellation!.image ??
                                  "",
                        ));
                      } else if (e == returnPolicy &&
                          authProvider.mwc_content.returnPolicy != null) {
                        Get.to(HtmlPreviewPage(
                            title: parseHtmlString(authProvider
                                    .mwc_content.returnPolicy!.headlines ??
                                ""),
                            message: authProvider
                                    .mwc_content.returnPolicy!.details ??
                                "",
                            file_url:
                                authProvider.mwc_content.returnPolicy!.image ??
                                    ''));
                      } else if (e == aboutUs &&
                          authProvider.mwc_content.returnPolicy != null) {
                        Get.to(HtmlPreviewPage(
                            title: parseHtmlString(authProvider
                                    .mwc_content.returnPolicy!.headlines ??
                                ""),
                            message: aboutUsHtml,
                            file_url:
                                authProvider.mwc_content.returnPolicy!.image ??
                                    ''));
                      }
                    },
                    leading: e == privacyPolicy
                        ? Assets.privacyPolicy
                        : e == termsAndConditions
                            ? Assets.termsAndCondition
                            : e == cancellationPolicy
                                ? Assets.cancellationPolicy
                                : e == returnPolicy
                                    ? Assets.returnPolicy
                                    : Assets.aboutUs,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
  */
      ],
    );
  }

  Widget buildDownloadExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String pdf = 'PDF';
    const String ppt = 'PPT';
    const String promotionalVideo = 'Promotional Video';
    const String gallery = 'Gallery';
    const String academicVideos = 'Academic Videos';
    const String introVideo = 'Intro Video';

    return expansionTile(
      title: 'Downloads',
      headerAsset: Assets.download,
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == pdf ||
          dashBoardProvider.selectedDrawerTile == ppt ||
          dashBoardProvider.selectedDrawerTile == promotionalVideo ||
          dashBoardProvider.selectedDrawerTile == gallery ||
          dashBoardProvider.selectedDrawerTile == academicVideos ||
          dashBoardProvider.selectedDrawerTile == introVideo,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              ...[
                pdf,
                ppt,
                gallery,
                promotionalVideo,
                introVideo,
                academicVideos,
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = const Scaffold(backgroundColor: mainColor);
                      switch (e) {
                        case pdf:
                          page = MainPage();
                          launchTheLink(dashBoardProvider.pdfLink ?? '');
                          break;
                        case ppt:
                          page = MainPage();
                          launchTheLink(dashBoardProvider.pptLink ?? '');
                          break;
                        case gallery:
                          page = const GalleryMainPage();
                          break;
                        case promotionalVideo:
                          page = DrawerVideoScreen(
                              url: dashBoardProvider.promotionalVideoLink ?? '',
                              title: promotionalVideo);
                          break;
                        case introVideo:
                          page = DrawerVideoScreen(
                              url: dashBoardProvider.introVideoLink ?? '',
                              title: introVideo);
                          break;
                        case academicVideos:
                          page = const DrawerVideosMainPage();
                          break;
                        default:
                          page = buildDefaultPage();
                          break;
                      }
                      Get.to(page);
                    },
                    leading: e == pdf
                        ? Assets.pdf
                        : e == ppt
                            ? Assets.ppt
                            : e == gallery
                                ? Assets.gallery
                                : e == promotionalVideo
                                    ? Assets.video
                                    : e == introVideo
                                        ? Assets.video
                                        : Assets.video,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container buildFooter(
      Size size, BuildContext context, DashBoardProvider dashBoardProvider) {
    return Container(
      height: 20 + size.height * 0.13,
      // color: Colors.white38,
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () =>
                    launchTheLink(sl.get<AuthProvider>().privacy ?? ""),
                child: bodyMedText('Privacy Policy', context,
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    )),
              ),
            ],
          ),
          height10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => launchTheLink(sl.get<AuthProvider>().term ?? ""),
                child: bodyMedText('Terms & Conditions', context,
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    )),
              ),
            ],
          ),*/
          Row(
            children: [
              const Spacer(flex: 1),
              Expanded(
                  flex: 3,
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
                    cacheManager: CacheManager(Config(
                        "${AppConstants.packageID}_app_dash_logo",
                        stalePeriod: const Duration(days: 30))),
                  )),
              const Spacer(flex: 1)
            ],
          ),
          height10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              bodyMedText(
                'Version $appVersion',
                context,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildHeader(
      Size size, BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 100,
      // color: CupertinoColors.white,

      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: titleLargeText(
                        (authProvider.userData.customerName ?? 'Unknown')
                            // 'Jury John'
                            .capitalize!,
                        context,
                        color: Colors.white,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                height5(),
                Row(
                  children: [
                    Expanded(
                      child: capText(
                          '(${authProvider.userData.username ?? 'Unknown'})',
                          context,
                          color: Colors.white70,
                          textAlign: TextAlign.start,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PopupMenuButton(
          //   surfaceTintColor: Colors.transparent,
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //   icon: assetSvg(Assets.popupButton0, color: Colors.white),
          //   onSelected: (val) {
          //     Get.back();
          //     Get.to(ProfileScreen());
          //   },
          //   itemBuilder: (BuildContext context) {
          //     return [
          //       PopupMenuItem(
          //         child: Text('Profile'),
          //         value: 'Profile',
          //       ),
          //       const PopupMenuItem(
          //         child: Text('Commission Withdrawal'),
          //         value: 'Commission Withdrawal',
          //       ),
          //     ];
          //   },
          // ),
        ],
      ),
    );
  }

//default components

  Widget expansionTile(
      {String title = '',
      required String headerAsset,
      required List<Widget> children,
      bool initiallyExpanded = false}) {
    return Theme(
        data: Theme.of(context).copyWith(
            listTileTheme: ListTileTheme.of(context).copyWith(dense: true)),
        child: ExpansionTile(
          title: Row(
            children: [
              assetSvg(headerAsset, color: Colors.white, width: 15),
              width10(),
              Expanded(
                  child: bodyMedText(
                title,
                context,
                maxLines: 1,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                useGradient: true,
              )),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedBackgroundColor: Colors.white.withOpacity(0.03),
          backgroundColor: Colors.blueGrey.withOpacity(0.15),
          iconColor: Colors.white,
          textColor: Colors.white,
          collapsedTextColor: Colors.white70,
          collapsedIconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          initiallyExpanded: initiallyExpanded,
          children: children,
        ));
  }

  Scaffold buildDefaultPage() {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        title: titleLargeText(AppConstants.appName, context,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            useGradient: true),
        centerTitle: true,
      ),
      body: Center(
        child: bodyLargeText('Comming soon...', context, color: Colors.white),
      ),
    );
  }
}

class _MasterClasses extends StatelessWidget {
  const _MasterClasses({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashBoardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    bool isActive = authProvider.userData.salesActive == '1';
    bool isWebinarLive = dashboardProvider.wevinarEventVideo != null &&
        dashboardProvider.wevinarEventVideo!.status == '1';

    return Column(
      children: [
        Row(
          children: [
            assetImages(Assets.classPng, width: 20),
            width5(),
            bodyLargeText('Master Classes', context,
                color: Colors.white70, fontWeight: FontWeight.bold),
          ],
        ),
        height10(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // education videos
            Expanded(
              flex: 4,
              child: _SectionTile(
                onTap: () {
                  if (!isActive) {
                    inActiveUserAccessDeniedDialog(context);
                  } else {
                    Get.back();
                    Get.to(const DrawerVideosMainPage());
                  }
                },
                title: 'Educational\nVideos',
                image: Assets.videoPng,
              ),
            ),
            // education downloads
            width5(),
            Expanded(
              flex: 4,
              child: _SectionTile(
                onTap: () {
                  if (!isActive) {
                    inActiveUserAccessDeniedDialog(context);
                  } else {
                    Get.back();
                    Get.to(const DowanloadsMainPage());
                  }
                },
                title: 'Educational\nDownloads',
                image: Assets.downloadsPng,
              ),
            ),
            // Daily webinars
            width5(),
            Expanded(
              flex: 3,
              child: _SectionTile(
                onTap: () {
                  if (!isActive) {
                    inActiveUserAccessDeniedDialog(context);
                  } else if (!isWebinarLive) {
                    Fluttertoast.showToast(
                        msg: 'Currently no webinar is live',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white54,
                        textColor: Colors.black);
                  } else {
                    Get.back();
                    Navigator.pushNamed(context, YoutubePlayerPage.routeName,
                        arguments: jsonEncode({
                          'videoId':
                              dashboardProvider.wevinarEventVideo!.webinarId,
                          // 'videoId': 'ezdP1lzsNUg',
                          'isLive': false,
                          'rotate': true,
                          'data': dashboardProvider.wevinarEventVideo!.toJson()
                        }));
                    // Get.to(YoutubeApp());
                  }
                },
                title: 'Daily\nWebinars',
                image: Assets.liveStreamingPng,
                leading: isWebinarLive
                    ? assetLottie(Assets.liveBroadcastLottie, height: 37)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile(
      {super.key,
      required this.title,
      required this.image,
      required this.onTap,
      this.leading});

  final String title;
  final String image;
  final void Function() onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    double imageWidth = 30;
    double maxWidth = 100;
    double minWidth = 100;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // constraints:
        //     BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: appLogoColor.withOpacity(0.8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            leading != null ? leading! : assetImages(image, height: imageWidth),
            if (leading == null) height5(),
            capText(
              title,
              context,
              color: Colors.white,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerTileItem extends StatefulWidget {
  const DrawerTileItem({
    super.key,
    this.onTap,
    required this.leading,
    required this.title,
    required this.selected,
    required this.width,
    this.trailing,
    this.trailingOnTap,
    this.opacity = 1,
  });

  final void Function()? onTap;
  final String leading;
  final String title;
  final bool selected;
  final double width;
  final Widget? trailing;
  final VoidCallback? trailingOnTap;
  final double opacity;
  @override
  State<DrawerTileItem> createState() => _DrawerTileItemState();
}

class _DrawerTileItemState extends State<DrawerTileItem>
    with SingleTickerProviderStateMixin {
  // late AnimationController animationController;
  // late Animation animation;
  @override
  void initState() {
    // animationController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 1000));
    // animation = Tween<double>(begin: 0, end: widget.width).animate(
    //     CurvedAnimation(
    //         parent: animationController, curve: Curves.fastLinearToSlowEaseIn));

    // animationController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    // animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bound) {
      infoLog(bound.maxWidth.toString());
      return InkWell(
        onTap: () {
          Provider.of<DashBoardProvider>(context, listen: false)
              .setDrawerTile(widget.title);
          // animationController.forward();
          // setState(() {});
          widget.trailingOnTap != null
              ? widget.trailingOnTap!()
              : widget.onTap != null
                  ? widget.onTap!()
                  : null;
        },
        splashColor: Colors.red,
        child: Stack(
          children: [
            Container(
              // height: 35,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  assetSvg(widget.leading, color: Colors.white, width: 15),
                  width10(),
                  Expanded(
                    child: bodyMedText(
                      widget.title,
                      context,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      useGradient: true,
                      opacity: widget.selected ? 1 : widget.opacity,
                      // maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.trailing != null) width10(),
                  if (widget.trailing != null) widget.trailing!
                ],
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                padding: const EdgeInsets.all(10),
                width: widget.selected ? bound.maxWidth : 0,
                // height: 35,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.fastLinearToSlowEaseIn,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05 * 5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

