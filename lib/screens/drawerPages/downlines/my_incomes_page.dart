import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mycarclub/providers/auth_provider.dart';
import '/database/model/response/income_activity_model.dart';
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

class MyIncomesPage extends StatefulWidget {
  const MyIncomesPage({super.key, required this.title});
  final String title;

  @override
  State<MyIncomesPage> createState() => _MyIncomesPageState();
}

class _MyIncomesPageState extends State<MyIncomesPage> {
  var provider = sl.get<DashBoardProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.getIncomeActivity(loading: true, income_type: widget.title);
    });
  }

  @override
  void dispose() {
    super.dispose();
    provider.incomePage = 0;
    provider.totalIncomeActivity = 0;
    provider.loadingIncomeActivity = false;
    provider.incomeActivity.clear();
  }

  Future<void> _loadMore() async {
    await provider.getIncomeActivity(income_type: widget.title);
  }

  Future<void> _refresh() async {
    provider.incomePage = 0;
    await provider.getIncomeActivity(income_type: widget.title, loading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardProvider>(builder: (context, provider, _) {
      return Scaffold(
        appBar: AppBar(
          title: titleLargeText(widget.title, context, useGradient: true),
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
              finishWhen: provider.incomeActivity.length >=
                  provider.totalIncomeActivity,
              onLoadMore: _loadMore,
              onRefresh: _refresh,
              builder: (scrollController, status) {
                return ListView(
                  controller: scrollController,
                  children: [
                    if (!provider.loadingIncomeActivity)
                      _MyIncomeActivityHistoryList(
                          activities: provider.incomeActivity,
                          onRetry: () => provider.getIncomeActivity(
                              loading: true, income_type: widget.title)),
                    if (provider.loadingIncomeActivity)
                      Container(
                          padding: const EdgeInsets.all(20),
                          height: provider.loadingIncomeActivity
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

class _MyIncomeActivityHistoryList extends StatelessWidget {
  const _MyIncomeActivityHistoryList(
      {Key? key, required this.activities, this.onRetry})
      : super(key: key);

  final List<IncomeActivityModel> activities;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    String currency = sl.get<AuthProvider>().userData.currency_icon ?? '';
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: assetLottie(Assets.dataNotFound),
                    ),
                    titleLargeText('Records not found', context),
                    height20(),
                    RetryButton(onRetry: onRetry),
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
                    IncomeActivityModel activity = activities[index];
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
                                    DateFormat('MMM dd yyyy').format(
                                        DateTime.parse(
                                            activity.createdAt ?? '')),
                                    context,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    textAlign: TextAlign.center),
                                height5(),
                                capText(
                                    parseHtmlString(
                                        activities[index].note ?? ''),
                                    context),
                                if (index < activities.length - 1) height20(),
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
                                bodyMedText(
                                    '$currency${double.parse(activity.amount ?? '0').toStringAsFixed(2)}',
                                    context),
                                height10(),
                                capText(
                                    DateFormat().add_jm().format(DateTime.parse(
                                        activities[index].createdAt ?? '')),
                                    context,
                                    fontSize: 8,
                                    color: Colors.white),
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
                    return const OutlinedDotIndicator(
                      color: Color.fromARGB(255, 18, 221, 126),
                      // child: Icon(Icons.check, color: Colors.white, size: 12.0),
                    );
                    // }
                  },
                  connectorBuilder: (_, index, ___) {
                    // bool credited = double.parse(activities[index].credit ?? '0') >
                    //     double.parse(activities[index].debit ?? '0');
                    return const SolidLineConnector(
                      color: Colors.white,
                      thickness: 2,
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

class RetryButton extends StatelessWidget {
  const RetryButton({
    super.key,
    required this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onRetry,
        child: Text(
          'Retry',
          style: TextStyle(color: context.theme.cardColor),
        ));
  }
}
