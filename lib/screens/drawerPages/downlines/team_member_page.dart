import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/load_more_container.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/user_model.dart';
import '/providers/dashboard_provider.dart';
import '/providers/team_view_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class TeamMemberPage extends StatefulWidget {
  const TeamMemberPage({Key? key}) : super(key: key);

  @override
  State<TeamMemberPage> createState() => _TeamMemberPageState();
}

class _TeamMemberPageState extends State<TeamMemberPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  var provider = sl.get<TeamViewProvider>();
  @override
  void initState() {
    provider.loadingTeamMembers = true;
    provider.teamMemberSearchController = TextEditingController();
    provider.isSearchingTeamMember = false;
    provider.teamMemberPage = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.getTeamMembers(true);
    });
    super.initState();
  }

  @override
  void dispose() {
    provider.loadingTeamMembers = false;
    provider.customerTeamMembers.clear();
    provider.teamMemberSearchController.clear();
    provider.isSearchingTeamMember = false;
    provider.teamMemberPage = 0;
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getTeamMembers();
  }

  Future<void> _refresh() async {
    provider.teamMemberPage = 0;
    await provider.getTeamMembers();
  }

  @override
  Widget build(BuildContext context) {
    // sl.get<TeamViewProvider>().getCustomerTeam();
    return Consumer<TeamViewProvider>(
        builder: (context, teamViewProvider, child) {
      return Scaffold(
        key: globalKey,
        backgroundColor: mainColor,
        appBar: appBar(context, teamViewProvider),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 1),
          ),
          child: Builder(builder: (context) {
            return (teamViewProvider.loadingTeamMembers ||
                    teamViewProvider.customerTeamMembers.isNotEmpty)
                ? Column(
                    children: [
                      if (teamViewProvider.customerTeamMembers.isNotEmpty)
                        Expanded(
                          child: LoadMoreContainer(
                              finishWhen:
                                  teamViewProvider.customerTeamMembers.length ==
                                      teamViewProvider.totalTeamMembers,
                              onLoadMore: _loadMore,
                              onRefresh: _refresh,
                              builder: (scrollController, status) {
                                return ListView(
                                  controller: scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(8),
                                  children: [
                                    ...teamViewProvider.customerTeamMembers
                                        .map((e) => buildMember(e)),
                                  ],
                                );
                              }),
                        ),
                      if (provider.loadingTeamMembers)
                        Container(
                            padding: const EdgeInsets.all(20),
                            height: provider.customerTeamMembers.isEmpty
                                ? Get.height * 0.7
                                : 100,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))),
                    ],
                  )
                : buildEmptyList(context, teamViewProvider);
          }),
        ),
      );
    });
  }

  AppBar appBar(BuildContext context, TeamViewProvider teamViewProvider) {
    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: provider.isSearchingTeamMember
            ? SizedBox(
                height: 40,
                child: TextField(
                  controller: provider.teamMemberSearchController,
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
                        provider.teamMemberSearchController.clear();
                      },
                      icon: const Icon(CupertinoIcons.clear_circled_solid,
                          color: Colors.white),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      provider.teamMemberPage = 0;
                      // provider.directMemberSelectedStatus = null;
                      provider.loadingTeamMembers = true;
                      provider.getTeamMembers(true);
                    }
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleLargeText('Team Members', context, useGradient: true),
                  capText(
                      '${teamViewProvider.customerTeamMembers.length} Of ${teamViewProvider.totalTeamMembers.toString()} Members',
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
          child: !provider.isSearchingTeamMember
              ? IconButton(
                  onPressed: () {
                    provider.setSearchingTeamMembers(
                        !provider.isSearchingTeamMember);
                  },
                  icon: const Icon(Icons.search))
              : Transform.rotate(
                  angle: pi / 2,
                  child: IconButton(
                      onPressed: () {
                        provider.setSearchingTeamMembers(
                            !provider.isSearchingTeamMember);
                        provider.teamMemberSearchController.clear();
                        provider.teamMemberPage = 0;
                        provider.getTeamMembers(true);
                      },
                      icon: const Icon(Icons.u_turn_left)),
                ),
        ),
      ],
      */
    );
  }

  Padding buildEmptyList(
      BuildContext context, TeamViewProvider teamViewProvider) {
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
              teamViewProvider.teamMemberSearchController.text.isEmpty
                  ? 'Create your own team & join more people to enlarge your team.'
                  : 'No results found for ${teamViewProvider.teamMemberSearchController.text}',
              context,
              color: Colors.white,
              textAlign: TextAlign.center),
          height20(),
          buildTeamBuildingReferralLink(context)
        ],
      ),
    );
  }

  Widget buildTeamBuildingReferralLink(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashBoardProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: titleLargeText('Refer and invite: ', context,
                      color: appLogoColor))
            ]),
            height10(),
            Row(children: [
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
                                dashBoardProvider.teamBuildingUrl, context,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () async => await Clipboard.setData(
                                ClipboardData(
                                    text: dashBoardProvider.teamBuildingUrl))
                            .then((_) => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('Link copied  to clipboard.'),
                                    backgroundColor: appLogoColor))),
                        icon: const Icon(Icons.copy,
                            color: Colors.white, size: 15),
                      )
                    ],
                  ),
                ),
              )
            ]),
            height20(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      sendWhatsapp(text: dashBoardProvider.teamBuildingUrl);
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child:
                          assetSvg(Assets.whatsappColored, fit: BoxFit.cover),
                    )),
                width30(),
                GestureDetector(
                    onTap: () {
                      sendTelegram(text: dashBoardProvider.teamBuildingUrl);
                    },
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
          ],
        );
      },
    );
  }

  Widget buildMember(UserData e) {
    Color tColor = Colors.white;
    Color _color() {
      if (e.salesActive == '1') {
        return Colors.green.withOpacity(1);
      } else if (e.salesActive == '2') {
        return Colors.red.withOpacity(0.1);
      } else {
        return Colors.amber.withOpacity(0.1);
      }
    }

    return Container(
      decoration: BoxDecoration(
          color: bColor(), borderRadius: BorderRadius.circular(5)),
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
                        color: tColor),
                    capText('( ${e.username ?? ""} )', context,
                        color: tColor, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _color()),
                  borderRadius: BorderRadius.circular(5),
                  color: _color(),
                ),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: capText(
                    e.salesActive == '1'
                        ? 'Active'
                        : e.salesActive == '2'
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
              capText('Rank:', context, color: tColor.withOpacity(0.5)),
              capText(e.rankName ?? 'N/A', context, color: Colors.deepOrange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              capText('Joined on:', context, color: tColor.withOpacity(0.5)),
              capText(
                  DateFormat()
                      .add_yMMMMd()
                      .format(DateTime.parse(e.createdAt ?? '')),
                  context,
                  color: tColor.withOpacity(0.5),
                  fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}
