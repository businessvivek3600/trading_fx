import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mycarclub/screens/drawerPages/downlines/my_incomes_page.dart';
import '/widgets/load_more_container.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/cash_wallet_history_model.dart';
import '/providers/Cash_wallet_provider.dart';
import '/providers/auth_provider.dart';
import '../cash_wallet_page/add_fund_from_coinPayment.dart';
import '../cash_wallet_page/cash_wallet_add_fund_card_payment.dart';
import '../cash_wallet_page/cash_wallet_add_funds_ng_cash_wallet.dart';
import '/sl_container.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/picture_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../../../utils/color.dart';

class CashWalletPage extends StatefulWidget {
  const CashWalletPage({Key? key}) : super(key: key);

  @override
  State<CashWalletPage> createState() => _CashWalletPageState();
}

class _CashWalletPageState extends State<CashWalletPage> {
  var provider = sl.get<CashWalletProvider>();
  @override
  void initState() {
    provider.cashWalletPage = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    provider.getCashWallet(true);
      
    });
    super.initState();
  }

  @override
  void dispose() {
    provider.cashWalletPage = 0;
    provider.totalCashWallet = 0;
    provider.btn_fund_coinpayment = false;
    provider.btn_fund_card = false;
    provider.btn_fund_cash_wallet = false;
    provider.stripe_paymnet_cancel_url = '';
    provider.stripe_paymnet_success_url = '';
    provider.tap_paymnet_return_url = '';
    provider.paymentTypes.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getCashWallet();
  }

  Future<void> _refresh() async {
    provider.cashWalletPage = 0;
    await provider.getCashWallet(true);
  }

  @override
  Widget build(BuildContext context) {
    // print('token : ${sl.get<AuthRepo>().getUserToken()}');
    Size size = MediaQuery.of(context).size;
    return Consumer<CashWalletProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: LoadMoreContainer(
                finishWhen: provider.history.length >= provider.totalCashWallet,
                onLoadMore: _loadMore,
                onRefresh: _refresh,
                builder: (scrollController, status) {
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      buildSliverAppBar(size, provider),
                      (provider.loadingWallet || provider.history.isNotEmpty)
                          ? buildSliverList(provider)
                          : dataNotFound(context, _refresh),
                    ],
                  );
                }),
          ),
/*          bottomNavigationBar: (provider.btn_fund_cash_wallet ||
                  provider.btn_fund_card ||
                  provider.btn_fund_coinpayment)
              ? buildBottomButtons(context, provider)
              : null,*/
          // floatingActionButton: FloatingActionButton.extended(
          //   onPressed: () {
          //     showModalBottomSheet(
          //         context: context,
          //         backgroundColor: Colors.transparent,
          //         builder: (context) {
          //           return _FundTransferWidget(provider);
          //         });
          //   },
          //   label: bodyMedText('Add Fund', context),
          // ),
        );
      },
    );
  }

  SliverToBoxAdapter dataNotFound(BuildContext context, VoidCallback? onRetry) {
    return SliverToBoxAdapter(
      child: Container(
        height: Get.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //TODO: dataNotFound
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: assetLottie(Assets.dataNotFound),
            ),
            titleLargeText('Records not found', context),
            height20(),
            RetryButton(onRetry: onRetry),
          ],
        ),
      ),
    );
  }

  SliverList buildSliverList(CashWalletProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var history = CashWalletHistory();
          var date = '';
          if (!provider.loadingWallet) {
            history = provider.history[index];
            date = DateFormat()
                        .add_yMMMEd()
                        .format(DateTime.parse(history.createdAt ?? '')) ==
                    DateFormat().add_yMMMEd().format(DateTime.now())
                ? 'Today'
                : DateFormat()
                            .add_yMMMEd()
                            .format(DateTime.parse(history.createdAt ?? '')) ==
                        DateFormat()
                            .add_yMMMEd()
                            .format(DateTime.now().subtract(const Duration(days: 1)))
                    ? 'Yesterday'
                    : DateFormat()
                        .add_yMMMEd()
                        .format(DateTime.parse(history.createdAt ?? ''));
          }
          return buildTile(provider, index, history, date, context);
        }, //ListTile
        childCount: !provider.loadingWallet ? provider.history.length : 11,
      ), //SliverChildBuildDelegate
    );
  }

  Column buildTile(
    CashWalletProvider provider,
    int index,
    CashWalletHistory history,
    String date,
    BuildContext context,
  ) {
    Color textColor = const Color.fromARGB(255, 255, 255, 255);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDateHeader(provider, index, history, date),
        Container(
          width: double.maxFinite,
          margin: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bColor(),
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      !provider.loadingWallet
                          ? capText(
                              DateFormat().add_jm().format(
                                  DateTime.parse(history.createdAt ?? '')),
                              context,
                              color: fadeTextColor)
                          : Skeleton(
                              height: 15,
                              width: 70,
                              textColor: Colors.black26,
                              borderRadius: BorderRadius.circular(5),
                            ),
                    ],
                  ),
                  // height10(),
                  !provider.loadingWallet
                      ? capText(parseHtmlString(history.note ?? ''), context,
                          color: textColor)
                      : Skeleton(
                          height: 15,
                          // width: 70,
                          textColor: Colors.black26,
                          borderRadius: BorderRadius.circular(5),
                        ),
                ],
              ),
              const Divider(color: Colors.red),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      assetSvg(
                        Assets.arrowIn,
                        color: Colors.green,
                        width: 13,
                      ),
                      width5(),
                      !provider.loadingWallet
                          ? capText(
                              '${sl.get<AuthProvider>().userData.currency_icon ?? ''}${double.parse(history.credit ?? '0').toStringAsFixed(1)}',
                              context,
                              color: textColor)
                          : Skeleton(
                              height: 13,
                              width: 30,
                              textColor: Colors.black26,
                              borderRadius: BorderRadius.circular(5),
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      assetSvg(
                        Assets.arrowOut,
                        color: Colors.red,
                        width: 13,
                      ),
                      width5(),
                      !provider.loadingWallet
                          ? capText(
                              '${sl.get<AuthProvider>().userData.currency_icon ?? ''}${double.parse(history.debit ?? '0').toStringAsFixed(1)}',
                              context,
                              color: textColor)
                          : Skeleton(
                              height: 13,
                              width: 30,
                              textColor: Colors.black26,
                              borderRadius: BorderRadius.circular(5),
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      assetSvg(
                        Assets.balanceColored,
                        width: 13,
                      ),
                      width5(),
                      !provider.loadingWallet
                          ? capText(
                              '${sl.get<AuthProvider>().userData.currency_icon ?? ''}${double.parse(history.balance ?? '0').toStringAsFixed(1)}',
                              context,
                              color: textColor)
                          : Skeleton(
                              height: 13,
                              width: 30,
                              textColor: Colors.black26,
                              borderRadius: BorderRadius.circular(5),
                            ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        if (index == provider.history.length - 1) height50(70),
      ],
    );
  }

  Builder buildDateHeader(CashWalletProvider provider, int index,
      CashWalletHistory history, String date) {
    return Builder(builder: (context) {
      bool sameDay = false;
      if (!provider.loadingWallet && index != 0) {
        sameDay = DateFormat()
                .add_yMMMEd()
                .format(DateTime.parse(history.createdAt ?? '')) ==
            DateFormat().add_yMMMEd().format(
                DateTime.parse(provider.history[index - 1].createdAt ?? ''));
      }
      return Container(
        margin: EdgeInsets.only(
            top: index != 0 && !sameDay ? 10 : 0, bottom: !sameDay ? 10 : 0),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 128, 128, 128),
            borderRadius: BorderRadius.circular(0)),
        child: !provider.loadingWallet
            ? Row(
                children: [
                  !sameDay
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(
                              // color: appLogoColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: capText(date, context, color: Colors.white))
                      : Container(),
                  width10(),
                  if (!sameDay) const Expanded(child: Divider(color: Colors.white))
                ],
              )
            : Skeleton(
                height: 25,
                width: double.maxFinite,
                // textColor: appLogoColor,
                borderRadius: BorderRadius.circular(5)),
      );
    });
  }

  SliverAppBar buildSliverAppBar(Size size, CashWalletProvider provider) {
    return SliverAppBar(
      snap: false,
      pinned: true,
      floating: false,
      // expandedHeight: size.height * 0.2,
      // collapsedHeight: size.height * 0.08,
      backgroundColor: mainColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: titleLargeText("Cash Wallet", context, useGradient: true)),
          !provider.loadingWallet
              ? bodyLargeText(
                  "${sl.get<AuthProvider>().userData.currency_icon ?? ''}${provider.walletBalance.toStringAsFixed(2)}",
                  context)
              : const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
        ],
      ),
      // flexibleSpace: FlexibleSpaceBar(
      //     centerTitle: true,
      //     title: Column(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: const [
      //         Text("Commission",
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontWeight: FontWeight.bold,
      //               // fontSize: 16.0,
      //             ) //TextStyle
      //             ),
      //         Text("\$4330",
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontWeight: FontWeight.bold,
      //               // fontSize: 16.0,
      //             ) //TextStyle
      //             ),
      //       ],
      //     ), //Text
      //     background: Image.asset("assets/designs/commission.jpg",
      //         fit: BoxFit.cover,
      //         opacity: const AlwaysStoppedAnimation(0.1)) //Images.network
      //     ),
    );
  }

  Widget buildBottomButtons(BuildContext context, CashWalletProvider provider) {
    return Container(
      height: Platform.isIOS ? 110 : 110.0,
      width: 350,
      margin: const EdgeInsets.only(),
      decoration: BoxDecoration(
          // color: bColor(),
          borderRadius: BorderRadius.circular(0)),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bodyLargeText('Add Funds', context),
          const Divider(color: Colors.white),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (provider.btn_fund_coinpayment)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(1)),
                    onPressed: () => checkServiceEnableORDisable(
                        'mobile_is_cash_wallet',
                        () => Get.to(const CashWalletAddFundFromCoinPayment())),
                    child: capText('CoinPayment', context,
                        textAlign: TextAlign.center),
                  ),
                width10(),
                if (provider.btn_fund_card)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorGreen.withOpacity(1)),
                    onPressed: () => checkServiceEnableORDisable(
                        'mobile_is_cash_wallet',
                        () => Get.to(const CashWalletAddFundFromCardPayment())),
                    child:
                        capText('Card', context, textAlign: TextAlign.center),
                  ),
                width10(),
                if (provider.btn_fund_cash_wallet)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.withOpacity(1)),
                    onPressed: () => checkServiceEnableORDisable(
                        'mobile_is_cash_wallet',
                        () => Get.to(const CashWalletNgCashWalletPage())),
                    child: capText('NG Cash Wallet', context,
                        textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FundTransferWidget extends StatelessWidget {
  const _FundTransferWidget(
    this.provider, {
    super.key,
  });
  final CashWalletProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleLargeText('Add Funds from:', context, color: Colors.black),
              height20(),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  if (provider.btn_fund_coinpayment)
                    buildCard(
                      context,
                      title: 'CoinPayment',
                      onTap: () => checkServiceEnableORDisable(
                          'mobile_is_cash_wallet', () {
                        Get.back();
                        Get.to(const CashWalletAddFundFromCoinPayment());
                      }),
                      color: Colors.blue,
                    ),
                  if (provider.btn_fund_card)
                    buildCard(
                      context,
                      title: 'Card',
                      onTap: () => checkServiceEnableORDisable(
                          'mobile_is_cash_wallet', () {
                        Get.back();
                        Get.to(const CashWalletAddFundFromCardPayment());
                      }),
                      color: Colors.green,
                    ),
                  if (provider.btn_fund_cash_wallet)
                    buildCard(
                      context,
                      title: 'NG Cash Wallet',
                      onTap: () => checkServiceEnableORDisable(
                          'mobile_is_cash_wallet', () {
                        Get.back();
                        Get.to(const CashWalletNgCashWalletPage());
                      }),
                      color: Colors.amber,
                    ),
                  buildCard(
                    context,
                    title: 'Transfer To Other Member',
                    onTap: () => checkServiceEnableORDisable(
                        'mobile_is_cash_wallet', () {
                      Get.back();
                      buildShowModalBottomSheet(Get.context!, provider);
                    }),
                    color: Colors.red,
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  GestureDetector buildCard(BuildContext context,
      {required String title, Function()? onTap, Color color = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: (Get.width - 40 - 20) / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onTap == null ? Colors.grey : color),
        ),
        child: Center(
            child: bodyLargeText(title, context,
                textAlign: TextAlign.center,
                color: onTap == null ? Colors.grey : color)),
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(
      BuildContext context, CashWalletProvider provider) {
    var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (context) =>
            _TransferToOtherWidget(currencyIcon: currencyIcon));
  }
}

class _TransferToOtherWidget extends StatefulWidget {
  const _TransferToOtherWidget({
    super.key,
    required this.currencyIcon,
  });

  final String currencyIcon;

  @override
  State<_TransferToOtherWidget> createState() => _TransferToOtherWidgetState();
}

class _TransferToOtherWidgetState extends State<_TransferToOtherWidget> {
  TextEditingController amountController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
  final _formKey = GlobalKey<FormState>();
  setNewAmount(double amount) => setState(() {
        double walletBalance = sl.get<CashWalletProvider>().walletBalance;
        if (walletBalance >= amount) {
          amountController.text = amount.toStringAsFixed(1);
        }
      });
  @override
  Widget build(BuildContext context) {
    return Consumer<CashWalletProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                height5(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 2,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  ],
                ),
                height5(),
                bodyLargeText('User Name', context,
                    color: Colors.black, fontWeight: FontWeight.w500),
                height5(),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: usernameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Enter username',
                          prefixIcon: Icon(Icons.person),
                          hintStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        onChanged: (val) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'User name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                height5(),
                bodyLargeText('Amount', context,
                    color: Colors.black, fontWeight: FontWeight.w500),
                height5(),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          NoDoubleDecimalFormatter()
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          prefix: Text(widget.currencyIcon),
                          hintStyle: const TextStyle(color: Colors.black),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        onChanged: (val) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Amount is required';
                          } else if (lessThanMinimum()) {
                            double mTransfer =
                                sl.get<CashWalletProvider>().minimum_transfer;
                            return 'Minimum transfer amount is $currencyIcon ${mTransfer.toStringAsFixed(1)}';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                height5(),
                Wrap(
                  spacing: 10,
                  children: [
                    // if (!minimumExceed(470))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xBD029919)),
                      onPressed: () => setNewAmount(470),
                      child: bodyMedText('$currencyIcon 470', context,
                          textAlign: TextAlign.center),
                    ),
                    // if (!minimumExceed(143))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () => setNewAmount(143),
                      child: bodyMedText('$currencyIcon 143', context,
                          textAlign: TextAlign.center),
                    ),
                    // if (!minimumExceed(55))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                      onPressed: () => setNewAmount(55),
                      child: bodyMedText('$currencyIcon 55', context,
                          textAlign: TextAlign.center),
                    ),
                    // if (!minimumExceed(33))
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => setNewAmount(33),
                      child: bodyMedText('$currencyIcon 33', context,
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
                height5(),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: ElevatedButton(
                            onPressed: _formKey.currentState?.validate() ??
                                    false
                                ? () {
                                    primaryFocus?.unfocus();
                                    double? amount =
                                        getValidDouble(amountController.text);
                                    print(amount);
                                    if (amount != null) {
                                      provider.transferCashToOther(
                                          usernameController.text,
                                          amountController.text);
                                    }
                                  }
                                : null,
                            child: const Text('Submit')))
                  ],
                ),
                height5(),
              ],
            ),
          ),
        );
      },
    );
  }

  bool minimumExceed(double i) {
    bool exceeded = false;
    double walletBalance = sl.get<CashWalletProvider>().walletBalance;
    if (walletBalance < i) {
      exceeded = true;
    }
    return exceeded;
  }

  bool lessThanMinimum() {
    bool less = false;
    double minimum_transfer = sl.get<CashWalletProvider>().minimum_transfer;
    double amount = double.parse(amountController.text);
    if (amount < minimum_transfer) {
      less = true;
    }
    return less;
  }
}
