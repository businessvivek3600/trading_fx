import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../../constants/assets_constants.dart';
import '../../../../database/functions.dart';
import '../../../../database/model/response/base/user_model.dart';
import '../../../../providers/team_view_provider.dart';
import '../../../../sl_container.dart';
import '../../../../utils/color.dart';
import '../../../../utils/picture_utils.dart';
import '../../../../utils/sizedbox_utils.dart';
import '../../../../utils/text.dart';
import '../../../../widgets/load_more_container.dart';
import '../trem_view_page.dart';

class DirectMembersPage extends StatefulWidget {
  const DirectMembersPage({super.key});

  @override
  State<DirectMembersPage> createState() => _DirectMembersPageState();
}

class _DirectMembersPageState extends State<DirectMembersPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  var provider = sl.get<TeamViewProvider>();

  @override
  void initState() {
    super.initState();
    provider.directMemberSearchController = TextEditingController();
    provider.isSearchingDirectMember = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.getDirectMembers(true);
    });
  }

  @override
  void dispose() {
    provider.directMemberPage = 0;
    provider.loadingDirectMembers = false;
    provider.totalDirectMembers = 0;
    provider.directMemberSelectedStatus = null;
    provider.isSearchingDirectMember = false;
    provider.directMemberSearchController.clear();
    provider.directMembers.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getDirectMembers();
  }

  Future<void> _refresh() async {
    provider.directMemberPage = 0;
    await provider.getDirectMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
      return Scaffold(
        key: globalKey,
        backgroundColor: mainColor,
        appBar: buildAppBar(context, provider),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 1),
          ),
          child: Consumer<TeamViewProvider>(
            builder: (context, teamViewProvider, child) {
              return provider.loadingDirectMembers ||
                      provider.directMembers.isNotEmpty
                  ? Column(
                      children: [
                        Expanded(
                          child: provider.directMembers.isNotEmpty
                              ? LoadMoreContainer(
                                  finishWhen:
                                      teamViewProvider.directMembers.length ==
                                          teamViewProvider.totalDirectMembers,
                                  onLoadMore: _loadMore,
                                  onRefresh: _refresh,
                                  builder: (scrollController, status) {
                                    return ListView(
                                      controller: scrollController,
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(8),
                                      children: [
                                        ...teamViewProvider.directMembers
                                            .map((e) => _MemberTile(user: e)),
                                      ],
                                    );
                                  })
                              : const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white)),
                        ),
                        if (provider.loadingDirectMembers &&
                            provider.directMemberPage != 0)
                          Container(
                              padding: const EdgeInsets.all(20),
                              height: provider.directMembers.isEmpty
                                  ? Get.height -
                                      kToolbarHeight -
                                      kBottomNavigationBarHeight
                                  : 100,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white))),
                      ],
                    )
                  : buildEmptyList(context, provider);
            },
          ),
        ),
      );
    });
  }

  Padding buildEmptyList(BuildContext context, TeamViewProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///TODO: teamMembersLottie
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              assetLottie(Assets.teamMembersLottie, width: 200),
            ],
          ),
          titleLargeText(
              provider.directMemberSearchController.text.isEmpty
                  ? 'Create your own team & join more people to enlarge your team.'
                  : 'No result found for ${provider.directMemberSearchController.text}',
              context,
              color: Colors.white,
              textAlign: TextAlign.center),
          height20(),
          buildTeamBuildingReferralLink(context)
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, TeamViewProvider provider) {
    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: provider.isSearchingDirectMember
            ? SizedBox(
                height: 40,
                child: TextField(
                  controller: provider.directMemberSearchController,
                  autofocus: true,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    isDense: true,
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: fadeTextColor),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      onPressed: () {
                        provider.directMemberSearchController.clear();
                      },
                      icon: const Icon(CupertinoIcons.clear_circled_solid,
                          color: Colors.white),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      provider.directMemberPage = 0;
                      provider.directMemberSelectedStatus = null;
                      provider.loadingDirectMembers = true;
                      provider.getDirectMembers(true);
                    }
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleLargeText('Direct Members', context, useGradient: true),
                  capText(
                      '${provider.directMembers.length} Of ${provider.totalDirectMembers.toString()} Members',
                      context,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500),
                ],
              ),
      ),
      /*
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: !provider.isSearchingDirectMember
              ? IconButton(
                  onPressed: () {
                    provider.setSearchingDirectMembers(
                        !provider.isSearchingDirectMember);
                  },
                  icon: const Icon(Icons.search))
              : Transform.rotate(
                  angle: pi / 2,
                  child: IconButton(
                      onPressed: () {
                        provider.setSearchingDirectMembers(
                            !provider.isSearchingDirectMember);
                        provider.directMemberSearchController.clear();
                        provider.directMemberPage = 0;
                        provider.getDirectMembers(true);
                      },
                      icon: const Icon(Icons.u_turn_left)),
                ),
        ),

        //filter
        IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            showModalBottomSheet(
              context: context,
              builder: (_) => const _FilterGenerationMemberDialog(),
            );
          },
          icon: Stack(
            children: [
              const Icon(Icons.filter_alt_outlined),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.directMemberSelectedStatus != null
                          ? Colors.red
                          : Colors.transparent),
                ),
              )
            ],
          ),
        ),
      ],
      */
    );
  }

  Widget buildMember(UserData e) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bodyLargeText((e.customerName ?? "").capitalize!, context,
                        color: Colors.black),
                    capText('( ${e.username ?? ""} )', context,
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: (e.status == '1'
                            ? Colors.green
                            : e.status == '2'
                                ? Colors.red
                                : Colors.amber)
                        .withOpacity(1)),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: capText(
                    e.status == '1'
                        ? 'Active'
                        : e.status == '2'
                            ? 'Deactive'
                            : 'Not-Active',
                    context,
                    color: Colors.white,
                    // color: e.status == '1'
                    //     ? Colors.green
                    //     : e.status == '2'
                    //         ? Colors.red
                    //         : Colors.amber,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
          /*height5(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              bodyLargeText('Reference ID:', context, color: Colors.black),
              bodyLargeText('${e.directSponserUsername ?? ''}', context,
                  color: Colors.blue),
            ],
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              capText('Rank:', context, color: Colors.black),
              capText(e.rankName ?? 'N/A', context, color: Colors.deepOrange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              capText('Joined on:', context, color: Colors.black),
              capText(
                  DateFormat()
                      .add_yMMMMd()
                      .format(DateTime.parse(e.createdAt ?? '')),
                  context,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterGenerationMemberDialog extends StatefulWidget {
  const _FilterGenerationMemberDialog({
    super.key,
  });

  @override
  State<_FilterGenerationMemberDialog> createState() =>
      _FilterGenerationMemberDialogState();
}

class _FilterGenerationMemberDialogState
    extends State<_FilterGenerationMemberDialog> {
  DateTime? selectedDate;
  final refferenceIdController = TextEditingController();
  int? selectedStatus;
  var provider = sl.get<TeamViewProvider>();

  @override
  void initState() {
    super.initState();
    selectedStatus = provider.directMemberSelectedStatus;
    selectedDate = provider.directMemberSelectedDate;
    refferenceIdController.text =
        provider.directMemberRefferenceIdController.text;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bColor()),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleLargeText('Filter', context, fontWeight: FontWeight.bold),
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(Icons.close, color: Colors.white))
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  const Divider(color: Colors.white),
                  // select joining date from calender
                  height10(),

                  /// select joining date from calender
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     titleLargeText('Joining Date :', context,
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //         useGradient: false),
                  //     OutlinedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         minimumSize: Size(double.minPositive, 30),
                  //         side: BorderSide(color: Colors.white),
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(5)),
                  //       ),
                  //       onPressed: () async {
                  //         DateTime? newDateTime = await showRoundedDatePicker(
                  //           height: 300,
                  //           context: context,
                  //           initialDate: DateTime.now(),
                  //           firstDate: DateTime(2018),
                  //           lastDate: DateTime(2030),
                  //           theme: ThemeData(
                  //             primaryColor: appLogoColor,
                  //             accentColor: appLogoColor,
                  //             colorScheme:
                  //                 ColorScheme.light(primary: appLogoColor),
                  //             buttonTheme: ButtonThemeData(
                  //                 textTheme: ButtonTextTheme.primary),
                  //           ),
                  //         );
                  //         setState(() {
                  //           selectedDate = newDateTime;
                  //         });
                  //       },
                  //       child: Row(
                  //         children: [
                  //           Icon(Icons.calendar_month_rounded,
                  //               color: Colors.white, size: 15),
                  //           width10(),
                  //           capText(
                  //               selectedDate != null
                  //                   ? formatDate(selectedDate!, 'dd MMM yyyy')
                  //                   : 'Select Date',
                  //               context,
                  //               color: Colors.white,
                  //               fontWeight: FontWeight.bold),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  //
                  /// select user status from slider
                  height10(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      titleLargeText(
                        'Status:',
                        context,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        useGradient: false,
                      ),
                      ToggleSwitch(
                        minWidth: 120.0,
                        minHeight: 30,
                        initialLabelIndex: selectedStatus,
                        cornerRadius: 5.0,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.white10,
                        inactiveFgColor: Colors.white,
                        totalSwitches: 2,
                        labels: ['Active', 'De-actve'].reversed.toList(),
                        icons: [
                          Icons.airplanemode_active_rounded,
                          Icons.airplanemode_inactive_rounded
                        ].reversed.toList(),
                        activeBgColors: [
                          [Colors.green, appLogoColor],
                          [appLogoColor, Colors.red]
                        ].reversed.toList(),
                        onToggle: (index) {
                          setState(() {
                            selectedStatus = index;
                          });
                        },
                      ),
                    ],
                  ),

                  /// text field for referrence id search
                  // height20(),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     titleLargeText('Reference ID :', context,
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //         useGradient: false),
                  //     Spacer(),
                  //     Expanded(
                  //       child: SizedBox(
                  //         height: 30,
                  //         child: TextFormField(
                  //           autofocus: false,
                  //           controller: refferenceIdController,
                  //           cursorColor: Colors.white,
                  //           style: TextStyle(color: Colors.white),
                  //           decoration: InputDecoration(
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(5),
                  //                 borderSide: BorderSide(color: Colors.white)),
                  //             enabledBorder: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(5),
                  //                 borderSide: BorderSide(color: Colors.white)),
                  //             focusedBorder: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(5),
                  //                 borderSide: BorderSide(color: Colors.white)),
                  //             contentPadding: EdgeInsets.symmetric(
                  //                 vertical: 5, horizontal: 10),
                  //             isDense: true,
                  //             hintText: 'Search...',
                  //             hintStyle:
                  //                 TextStyle(color: fadeTextColor, fontSize: 12),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            height10(),
            Row(
              children: [
                // button for cancel and apply
                Expanded(
                  child: OutlinedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.maxFinite, 40),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      if (provider.directMemberSelectedStatus != null) {
                        provider.directMemberSelectedDate = selectedDate;
                        provider.directMemberSelectedStatus = null;
                        provider.directMemberRefferenceIdController.text =
                            refferenceIdController.text;
                        provider.directMemberPage = 0;
                        provider.getDirectMembers(true);
                      }
                      Get.back();
                    },
                    child: capText(
                        provider.directMemberSelectedStatus == null
                            ? 'Cancel'
                            : 'Clear Filter',
                        context,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                width20(),
                Expanded(
                  child: FilledButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.maxFinite, 40),
                      backgroundColor: appLogoColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      provider.directMemberSelectedDate = selectedDate;
                      provider.directMemberSelectedStatus = selectedStatus;
                      provider.directMemberRefferenceIdController.text =
                          refferenceIdController.text;
                      provider.directMemberPage = 0;
                      provider.directMembers.clear();
                      provider.loadingDirectMembers = true;
                      provider.getDirectMembers(true);
                      provider.directMemberSearchController.clear();
                      provider.setSearchingDirectMembers(false);
                      Get.back();
                    },
                    child: capText('Apply', context,
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            height20(),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({super.key, required this.user});

  final UserData user;
  @override
  Widget build(BuildContext context) {
    bool active = user.salesActive == '1';
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: bColor(), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.0),
                child: buildCachedNetworkImage(
                  'https://mywealthclubs.com/assets/customer-panel/img/reward/rank-image-${user.nRankId}.png',
                  placeholderImg: Assets.appLogo_S,
                ),
              ),
              width10(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: bodyLargeText(
                              (user.customerName ?? '').capitalize!, context,
                              color: Colors.black),
                        ),
                        width5(),
                        capText(
                          '(${user.username ?? ''})',
                          context,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    height5(),
                    Row(
                      children: [
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                        width5(),
                        capText(!active ? 'De-active' : 'Active', context,
                            color: active ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500),
                        width5(),
                        if (active && user.first_active_date != null)
                          capText(
                            '( ${formatDate(DateTime.parse(user.first_active_date!), 'dd MMM yyyy h:m a')} )',
                            context,
                            color: fadeTextColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          //refered by

          Column(
            children: [
              height10(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  capText('Referred By:', context,
                      color: fadeTextColor, fontWeight: FontWeight.w500),
                  capText(
                    user.directSponserUsername ?? '',
                    context,
                    color: fadeTextColor,
                  ),
                ],
              ),
            ],
          ),

          //joined on
          Column(
            children: [
              height10(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  capText('Date of Joining:', context,
                      color: fadeTextColor, fontWeight: FontWeight.w500),
                  if (user.createdAt != null)
                    capText(
                      formatDate(
                          DateTime.parse(user.createdAt!), 'dd MMM yyyy h:m a'),
                      context,
                      color: fadeTextColor,
                    ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
