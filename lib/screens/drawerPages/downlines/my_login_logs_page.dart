import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/database/model/response/login_logs_model.dart';
import '/providers/dashboard_provider.dart';
import '/sl_container.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../../constants/assets_constants.dart';
import '../../../database/functions.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/sizedbox_utils.dart';
import '../../../widgets/load_more_container.dart';

class MyLoginLogsPage extends StatefulWidget {
  const MyLoginLogsPage({super.key});

  @override
  State<MyLoginLogsPage> createState() => _MyLoginLogsPageState();
}

class _MyLoginLogsPageState extends State<MyLoginLogsPage> {
  var provider = sl.get<DashBoardProvider>();

  @override
  void initState() {
    super.initState();
    provider.getLoginLogs(true);
  }

  @override
  void dispose() {
    super.dispose();
    provider.loginLogsPage = 0;
    provider.totalLoginLogs = 0;
    provider.loadingLoginLogs = false;
    provider.loginActivities.clear();
  }

  Future<void> _loadMore() async {
    await provider.getLoginLogs();
  }

  Future<void> _refresh() async {
    provider.loginLogsPage = 0;
    await provider.getLoginLogs(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardProvider>(builder: (context, provider, _) {
      return Scaffold(
        appBar: AppBar(
          title: titleLargeText("Login Activities", context, useGradient: true),
          actions: [],
        ),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 1),
          ),
          child: LoadMoreContainer(
              finishWhen:
                  provider.loginActivities.length >= provider.totalLoginLogs,
              onLoadMore: _loadMore,
              onRefresh: _refresh,
              builder: (scrollController, status) {
                return ListView(
                  controller: scrollController,
                  children: [
                    if (!provider.loadingLoginLogs)
                      _MyloginActivitiesHistoryList(
                          activities: provider.loginActivities),
                    if (provider.loadingLoginLogs)
                      Container(
                          padding: const EdgeInsets.all(20),
                          height: provider.loginActivities.isEmpty
                              ? Get.height -
                                  kToolbarHeight -
                                  kBottomNavigationBarHeight
                              : 100,
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))),
                  ],
                );
              }),
        ),
      );
    });
  }
}

class _MyloginActivitiesHistoryList extends StatelessWidget {
  const _MyloginActivitiesHistoryList({Key? key, required this.activities})
      : super(key: key);

  final List<LoginLogs> activities;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Color(0xff9b9b9b), fontSize: 12.5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: activities.isEmpty
            ? Center(
                child: SizedBox(
                height: Get.height * 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //TODO: dataNotFound
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: assetLottie(Assets.dataNotFound),
                    ),
                    titleLargeText('Records not found', context)
                  ],
                ),
              ))
            : FixedTimeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0,
                  color: const Color(0xff989898),
                  indicatorTheme:
                      const IndicatorThemeData(position: 0, size: 20.0),
                  connectorTheme: const ConnectorThemeData(thickness: 2.5),
                ),
                builder: TimelineTileBuilder.connected(
                  connectionDirection: ConnectionDirection.before,
                  itemCount: activities.length,
                  contentsBuilder: (_, index) {
                    LoginLogs activity = activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                bodyLargeText(
                                    parseHtmlString(
                                        activities[index].deviceName1 ??
                                            activities[index].deviceName ??
                                            ''),
                                    context),
                                height5(),
                                capText(
                                    DateFormat('MMM dd yyyy').add_jms().format(
                                        DateTime.parse(activity.time ?? '')),
                                    context,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    textAlign: TextAlign.center),
                                height5(),
                                if (index < activities.length - 1) height50(),
                              ],
                            ),
                          ),
                          Builder(builder: (context) {
                            // bool credited =
                            //     double.parse(activities[index].credit ?? '0') >
                            //         double.parse(activities[index].debit ?? '0');
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Container(
                                //   decoration: BoxDecoration(
                                //     color: credited
                                //         ? Colors.green[500]
                                //         : Colors.red[500]!,
                                //     borderRadius: BorderRadius.circular(30),
                                //   ),
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 10, vertical: 3),
                                //   child: bodyMedText(
                                //     credited ? 'Credit' : 'Debit',
                                //     context,
                                //     style: const TextStyle(
                                //       color: Colors.white,
                                //       fontSize: 10,
                                //     ),
                                //   ),
                                // ),
                                // bodyMedText(
                                //     '\$${double.parse(activity.amount ?? '0').toStringAsFixed(2)}',
                                //     context),
                                // height10(),
                                // capText(
                                //     DateFormat().add_jm().format(DateTime.parse(
                                //         activities[index].createdAt ?? '')),
                                //     context,
                                //     fontSize: 8,
                                //     color: Colors.white),
                              ],
                            );
                          }),
                        ],
                      ),
                    );
                  },
                  indicatorBuilder: (_, index) {
                    // bool credited = double.parse(activities[index].credit ?? '0') >
                    //     double.parse(activities[index].debit ?? '0');
                    // if (credited) {
                    //   return const OutlinedDotIndicator(
                    //     color: Color.fromARGB(255, 252, 253, 253),
                    //     // child: Icon(Icons.check, color: Colors.white, size: 12.0),
                    //   );
                    // } else {
                    return OutlinedDotIndicator(
                      color: Color.fromARGB(255, 255, 255, 255),
                      // child: Icon(Icons.check, color: Colors.white, size: 12.0),
                    );
                    // }
                  },
                  connectorBuilder: (_, index, ___) {
                    // bool credited = double.parse(activities[index].credit ?? '0') >
                    //     double.parse(activities[index].debit ?? '0');
                    return SolidLineConnector(
                      color: Colors.white,
                      thickness: 1,
                      // color: credited
                      //     ? const Color(0xff66c97f)
                      //     : const Color(0xff6676c9),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
