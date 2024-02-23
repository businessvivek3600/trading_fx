import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/widgets/load_more_container.dart';
import '../../../utils/default_logger.dart';
import '/database/model/response/subscription_request_history_model.dart';
import '/providers/auth_provider.dart';
import '/providers/subscription_provider.dart';
import '/sl_container.dart';
import '/widgets/SubscriptionPurchaseDialog.dart';
import 'package:provider/provider.dart';

import '../../../constants/assets_constants.dart';
import '../../../utils/color.dart';
import '../../../utils/sizedbox_utils.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/skeleton.dart';
import '../../../utils/text.dart';

class SubscriptionRequestsPage extends StatefulWidget {
  const SubscriptionRequestsPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionRequestsPage> createState() =>
      _SubscriptionRequestsPageState();
}

class _SubscriptionRequestsPageState extends State<SubscriptionRequestsPage> {
  var provider = sl.get<SubscriptionProvider>();
  @override
  void initState() {
    super.initState();
    provider.subReqPage = 0;
    provider.getSubscriptionRequestHistory(true);
  }

  @override
  void dispose() {
    provider.subReqPage = 0;
    provider.totalReqSubscriptions = 0;
    provider.requestHistory.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getSubscriptionRequestHistory(false);
  }

  Future<void> _refresh() async {
    provider.subReqPage = 0;
    await provider.getSubscriptionRequestHistory(true);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        infoLog(
            'SubscriptionRequestsPage: ${provider.requestHistory.length} loading: ${provider.loadingReqSub}');
        return Scaffold(
          backgroundColor: mainColor,
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            child: LoadMoreContainer(
                finishWhen: provider.requestHistory.length >=
                    provider.totalReqSubscriptions,
                onLoadMore: _loadMore,
                onRefresh: _refresh,
                builder: (scrollController, status) {
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      buildSliverAppBar(size),
                      buildSliverList(provider, currency_icon),
                    ],
                  );
                }),
          ),
        );
      },
    );
  }

  SliverPadding buildSliverList(
      SubscriptionProvider provider, String currencyText) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      sliver: (!provider.loadingReqSub && provider.requestHistory.isEmpty)
          ? SliverToBoxAdapter(
              child: SizedBox(
                height: Get.height - kToolbarHeight * 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    titleLargeText(
                        'You have not purchased any subscription.', context,
                        textAlign: TextAlign.center),
                    height10(),
                    bodyLargeText('Please explore our products', context),
                    height10(),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 30),
                            child: ElevatedButton(
                                onPressed: () {
                                  Get.dialog(
                                      const SubscriptionPurchaseDialog());
                                },
                                child: Text('Purchase')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var requestHistory = SubscriptionRequestHistory();
                  if (!provider.loadingReqSub) {
                    requestHistory = provider.requestHistory[index];
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: !provider.loadingReqSub
                          ? ExpansionTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        titleLargeText(
                                          '$currencyText${requestHistory.packageAmount}',
                                          context,
                                        ),
                                        width10(),
                                        Expanded(
                                          child: bodyLargeText(
                                            (requestHistory.packageName ?? ''),
                                            context,
                                            textAlign: TextAlign.start,
                                            // style: TextStyle(
                                            //     fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  width10(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: requestHistory.status == '0'
                                          ? Colors.amber[500]
                                          : requestHistory.status == '1'
                                              ? Colors.green[500]
                                              : Colors.red[500],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    child: bodyMedText(
                                      requestHistory.status == '0'
                                          ? 'Pending'
                                          : requestHistory.status == '1'
                                              ? 'Completed'
                                              : 'Canceled',
                                      context,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  capText(
                                    DateFormat().add_yMMMEd().format(
                                        DateTime.parse(
                                            requestHistory.createdAt ?? '')),
                                    context,
                                    textAlign: TextAlign.center,
                                  ),
                                  capText(
                                    DateFormat().add_jm().format(DateTime.parse(
                                        requestHistory.createdAt ?? '')),
                                    context,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              collapsedBackgroundColor: Colors.white24,
                              backgroundColor: Colors.white24,
                              iconColor: Colors.white,
                              textColor: Colors.white,
                              collapsedTextColor: Colors.white70,
                              collapsedIconColor: Colors.white,
                              // initiallyExpanded: true,
                              children: [
                                Container(
                                  // height: 100,
                                  width: double.maxFinite,
                                  padding: EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: bodyLargeText(
                                              '${requestHistory.packageName ?? ''}',
                                              context,
                                              // color: index % 2 == 0
                                              //     ? yearlyPackColor
                                              //     : monthlyPackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // titleLargeText('\$35', context),
                                      height5(),
                                      Row(
                                        children: [
                                          capText('Order ID:', context),
                                          width10(),
                                          capText(requestHistory.orderId ?? '',
                                              context,
                                              fontWeight: FontWeight.bold),
                                        ],
                                      ),
                                      height5(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: bodyLargeText(
                                              requestHistory.paymentType ?? '',
                                              context,
                                              // color: index % 2 == 0
                                              //     ? yearlyPackColor
                                              //     : monthlyPackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Skeleton(
                              height: 70,
                              width: double.maxFinite,
                              textColor: Colors.white54,
                            ),
                    ),
                  );
                },
                //     Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Container(
                //       // height: 150,
                //       width: double.maxFinite,
                //       margin: const EdgeInsets.only(bottom: 10),
                //       decoration: BoxDecoration(
                //         color: Colors.white10,
                //         // border: Border.all(color: Colors.white),
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: [
                //           Container(
                //             height: 45,
                //             width: double.maxFinite,
                //             margin: const EdgeInsets.only(bottom: 10),
                //             decoration: BoxDecoration(
                //               color: index % 2 == 0
                //                   ? yearlyPackColor.withOpacity(01)
                //                   : monthlyPackColor.withOpacity(01),
                //               borderRadius: const BorderRadius.only(
                //                 topLeft: Radius.circular(10),
                //                 topRight: Radius.circular(10),
                //               ),
                //             ),
                //             child: Center(
                //                 child: titleLargeText(
                //                     index % 2 == 0 ? 'Yearly Pack' : 'Monthly Pack',
                //                     context,
                //                     textAlign: TextAlign.center)),
                //           ),
                //           Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Row(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: <Widget>[
                //                     titleLargeText('\$35', context),
                //                   ],
                //                 ),
                //                 height10(),
                //                 Row(
                //                   mainAxisAlignment: MainAxisAlignment.start,
                //                   children: <Widget>[
                //                     capText(
                //                         'Ordered on ${index + 1} March 2023 2:00 PM',
                //                         context),
                //                   ],
                //                 ),
                //                 height10(),
                //                 bodyLargeText('Wallet', context),
                //                 const Divider(color: Colors.amber),
                //                 Row(
                //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     Expanded(
                //                       child: capText(
                //                           '	You received fund from MCC Commission Wallet',
                //                           context),
                //                     ),
                //                     Container(
                //                       decoration: BoxDecoration(
                //                         color: Colors.green[500],
                //                         borderRadius: BorderRadius.circular(30),
                //                       ),
                //                       padding: const EdgeInsets.symmetric(
                //                           horizontal: 10, vertical: 3),
                //                       child: bodyMedText(
                //                         'Completed',
                //                         context,
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 10,
                //                         ),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ), //ListTile
                childCount: !provider.loadingReqSub
                    ? provider.requestHistory.length
                    : 10,
              ), //SliverChildBuildDelegate
            ),
    );
  }

  SliverAppBar buildSliverAppBar(Size size) {
    return SliverAppBar(
      snap: false,
      pinned: true,
      floating: false,
      backgroundColor: mainColor,
      expandedHeight: size.height * 0.15,
      collapsedHeight: kToolbarHeight,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            titleLargeText("Request History", context),
          ],
        ), //Text
        //Images.network
      ),
    );
  }
}
