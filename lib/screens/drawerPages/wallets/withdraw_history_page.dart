import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/commission_wallet_history_model.dart';
import '/screens/drawerPages/wallets/commission_wallet/commission_withdraw_request.dart';
import '/screens/drawerPages/wallets/withdraw_request_history_details_page.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../database/model/response/withdraw_req_his_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/commission_wallet_provider.dart';
import '../../../sl_container.dart';
import '../../../widgets/load_more_container.dart';

class WithdrawRequestHistoryPage extends StatefulWidget {
  const WithdrawRequestHistoryPage({super.key});

  @override
  State<WithdrawRequestHistoryPage> createState() =>
      _WithdrawRequestHistoryPageState();
}

class _WithdrawRequestHistoryPageState
    extends State<WithdrawRequestHistoryPage> {
  var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
  late CommissionWalletProvider provider;
  @override
  void initState() {
    provider = sl.get<CommissionWalletProvider>();
    provider.getWithdrawRequestHistory(true);
    super.initState();
  }

  @override
  void dispose() {
    provider.withdrawRequestHistoryPage = 0;
    provider.withdrawRequestHistory.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getWithdrawRequestHistory();
  }

  Future<void> _refresh() async {
    provider.withdrawRequestHistoryPage = 0;
    await provider.getWithdrawRequestHistory(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommissionWalletProvider>(
        builder: (context, provider, child) {
      int loadedHistory = 0;
      provider.withdrawRequestHistory
          .forEach((e) => loadedHistory += e.list.length);
      return Scaffold(
        appBar: AppBar(
          title: titleLargeText('Withdraw Request History ', context,
              useGradient: true),
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   elevation: 5,
        //   onPressed: _addNewRequest,
        //   icon: const Icon(Icons.add),
        //   label: capText('Request', context),
        // ),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context), fit: BoxFit.cover),
          ),
          child: provider.loadingWithdrawRequestHistory
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : LoadMoreContainer(
                  finishWhen:
                      loadedHistory >= provider.totalWithdrawRequestHistory,
                  onLoadMore: _loadMore,
                  onRefresh: _refresh,
                  builder: (scrollController, status) {
                    return ListView.builder(
                        controller: scrollController,
                        itemCount: provider.withdrawRequestHistory.length,
                        itemBuilder: (context, index) {
                          var item = provider.withdrawRequestHistory[index];
                          return StickyHeader(
                              header: buildHeader(item, context),
                              content: ListView.separated(
                                itemBuilder: (context, index) =>
                                    buildTile(context, item.list[index]),
                                separatorBuilder: (context, index) =>
                                    const Divider(color: Colors.grey),
                                itemCount: item.list.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ));
                        });
                  }),
        ),
      );
    });
  }

  Container buildHeader(
      HistoryWithDate<WithdrawRequestHistoryModel> item, BuildContext context) {
    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color.fromARGB(149, 128, 128, 128),
          borderRadius: BorderRadius.circular(0)),
      child: Row(
        children: [
          capText(formatDate(item.date!, 'dd MMM yyyy'), context,
              fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  ListTile buildTile(
      BuildContext context, WithdrawRequestHistoryModel history) {
    String status = history.status ?? '0';
    Color statusColor = status == '0'
        ? Colors.amber
        : status == '1'
            ? Colors.green
            : Colors.red;
    String statusText = status == '0'
        ? 'Pending'
        : status == '1'
            ? 'Approved'
            : 'Rejected';
    double amount = double.parse(history.amount ?? '0');
    return ListTile(
      leading:
          assetSvg(Assets.commissionWallet, width: 25, color: Colors.white70),
      title: bodyLargeText(
          '$currencyIcon ${amount.toStringAsFixed(2)}', context,
          fontWeight: FontWeight.bold),
      subtitle: Row(
        children: [
          Icon(Icons.circle, size: 10, color: statusColor),
          width5(),
          capText(statusText, context, color: statusColor),
          width20(),
          capText(formatDate(DateTime.parse(history.createdAt!), 'hh:mm a'),
              context,
              color: Colors.white70),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 15, color: Colors.white70),
      onTap: () => _showDetails(history),
    );
  }

  void _showDetails(WithdrawRequestHistoryModel history) {
    Get.to(WithdrawRequesthHistoryDetailsPage(history: history));
    // showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         backgroundColor: bColor(),
    //         shape:
    //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //         title: titleLargeText('Withdraw Request Details', context),
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             capText(
    //                 'Date: ${formatDate(DateTime.parse(history.createdAt!), 'dd MMM yyyy hh:mm a')}',
    //                 context),
    //             height10(),
    //             capText(
    //                 'Amount: $currencyIcon ${(Random().nextDouble() * 1000).toStringAsFixed(2)}',
    //                 context),
    //             height10(),
    //             capText('Status: Approved', context),
    //             height10(),
    //             capText('Note: ${history.note}', context),
    //           ],
    //         ),
    //         actions: [
    //           TextButton(
    //               onPressed: () => Navigator.pop(context),
    //               child: capText('Close', context))
    //         ],
    //       );
    //     });
  }

  Future<void> _addNewRequest() async {
    Get.to(const CommissionWithdrawRequestPage(fromHistory: true));
  }
}
