import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/load_more_container.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/fund_request_model.dart';
import '/providers/Cash_wallet_provider.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import 'package:provider/provider.dart';

import '../../../../utils/picture_utils.dart';
import '../../../../utils/text.dart';

class CashWalletAddFundFromCoinPayment extends StatefulWidget {
  const CashWalletAddFundFromCoinPayment({Key? key}) : super(key: key);

  @override
  State<CashWalletAddFundFromCoinPayment> createState() =>
      _CashWalletAddFundFromCoinPaymentState();
}

class _CashWalletAddFundFromCoinPaymentState
    extends State<CashWalletAddFundFromCoinPayment> {
  String _currentPaymentTypeVal = '';
  String _currentPaymentTypeKey = '';
  var provider = sl.get<CashWalletProvider>();
  @override
  void initState() {
    provider.getCoinPaymentFundRequest(true).then((value) {
      setState(() {
        if (provider.paymentTypes.entries.isNotEmpty)
          _currentPaymentTypeKey = provider.paymentTypes.entries.first.key;
      });
    });
    super.initState();
  }

  bool isLoading = true;
  @override
  void dispose() {
    provider.amountController.clear();
    provider.coinPaymentPage = 0;
    provider.coinfundRequests.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getCoinPaymentFundRequest();
  }

  Future<void> _refresh() async {
    provider.coinPaymentPage = 0;
    await provider.getCoinPaymentFundRequest(true);
  }

  @override
  Widget build(BuildContext context) {
    // sl.get<CashWalletProvider>().getCoinPaymentFundRequest();
    return Consumer<CashWalletProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
              title:
                  titleLargeText('Coin Payment', context, useGradient: true)),
          body: buildBody(provider),
          bottomNavigationBar: buildBottomButton(context, provider),
        );
      },
    );
  }

  Container buildBody(CashWalletProvider provider) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: userAppBgImageProvider(context),
              fit: BoxFit.cover,
              opacity: 0.5)),
      child: (provider.loadingFundRequestData ||
              provider.coinfundRequests.isNotEmpty)
          ? LoadMoreContainer(
              finishWhen:
                  provider.coinfundRequests.length >= provider.totalCoinPayment,
              onLoadMore: _loadMore,
              onRefresh: _refresh,
              builder: (scrollController, status) {
                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  itemCount: !provider.loadingFundRequestData
                      ? provider.coinfundRequests.length
                      : 7,
                  itemBuilder: (context, index) {
                    var history = FundRequestModel();
                    if (!provider.loadingFundRequestData) {
                      history = provider.coinfundRequests[index];
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: !provider.loadingFundRequestData
                            ? buildExpansionTile(history, context)
                            : Skeleton(
                                height: 70,
                                width: double.maxFinite,
                                textColor: Colors.white38),
                      ),
                    );
                  },
                );
              })
          : Column(
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
    );
  }

  ExpansionTile buildExpansionTile(
      FundRequestModel history, BuildContext context) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                bodyLargeText('$currency_icon${history.amount}', context),
                // Expanded(
                //   child: capText(
                //     DateFormat()
                //         .add_yMMMEd()
                //         .add_jm()
                //         .format(DateTime.parse(history.createdAt ?? '')),
                //     context,
                //     textAlign: TextAlign.center,
                //     // style: TextStyle(
                //     //     fontWeight: FontWeight.bold),
                //   ),
                // ),
              ],
            ),
          ),
          width10(),
          Container(
            decoration: BoxDecoration(
              color: history.status == '0'
                  ? Colors.amber[500]
                  : history.status == '1'
                      ? Colors.green[500]
                      : Colors.red[500],
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: bodyMedText(
              history.status == '0'
                  ? 'Pending'
                  : history.status == '1'
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          capText(
            DateFormat()
                .add_yMMMEd()
                .format(DateTime.parse(history.createdAt ?? '')),
            context,
            textAlign: TextAlign.center,
            // style: TextStyle(
            //     fontWeight: FontWeight.bold),
          ),
          capText(
            DateFormat()
                .add_jm()
                .format(DateTime.parse(history.createdAt ?? '')),
            context,
            textAlign: TextAlign.center,
            // style: TextStyle(
            //     fontWeight: FontWeight.bold),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      collapsedBackgroundColor: Colors.white24,
      backgroundColor: Colors.white10,
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
              // titleLargeText('\$35', context),
              height5(),
              Row(
                children: [
                  capText('Request ID:', context),
                  width10(),
                  capText(history.orderId ?? '', context,
                      fontWeight: FontWeight.bold),
                ],
              ),
              height5(),
              Row(
                children: [
                  Expanded(
                    child: bodyLargeText(
                      history.paymentType ?? '',
                      context,
                      // color: index % 2 == 0
                      //     ? yearlyPackColor
                      //     : monthlyPackColor,
                    ),
                  ),
                ],
              ),
              height5(),
              GestureDetector(
                onTap: () {
                  launchTheLink(history.paymentUrl ?? '');
                },
                child: Row(
                  children: [
                    bodyLargeText('Check Status', context,
                        color: Colors.blue, decoration: TextDecoration.underline
                        // color: index % 2 == 0
                        //     ? yearlyPackColor
                        //     : monthlyPackColor,
                        ),
                    width10(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding buildBottomButton(BuildContext context, CashWalletProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        // height: 70,
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            Expanded(
              child: Builder(builder: (context) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(),
                  onPressed: () => buildShowModalBottomSheet(context),

                  //       child: Column(
                  //         children: [
                  //           Row(
                  //             children: [
                  //               TextField(
                  //                 decoration: InputDecoration(
                  //                   hintText: 'Amount',
                  //                   border: OutlineInputBorder(
                  //                       borderSide:
                  //                           BorderSide(color: Colors.black)),
                  //                   enabledBorder: OutlineInputBorder(
                  //                       borderSide:
                  //                           BorderSide(color: Colors.black)),
                  //                   focusedBorder: OutlineInputBorder(
                  //                       borderSide:
                  //                           BorderSide(color: Colors.black)),
                  //                   errorBorder: OutlineInputBorder(
                  //                       borderSide:
                  //                           BorderSide(color: Colors.black)),
                  //                 ),
                  //               ),
                  //             ],
                  //           )
                  //         ],
                  //       ),
                  //     )),
                  child: bodyMedText('Request Amount', context,
                      textAlign: TextAlign.center),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (context) => GestureDetector(
              onTap: () {
                primaryFocus?.unfocus();
                setState(() {});
              },
              child: Consumer<CashWalletProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 3,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          ],
                        ),
                        height5(),
                        bodyLargeText('Amount', context,
                            color: Colors.black, fontWeight: FontWeight.w500),
                        height5(),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: provider.amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter amount',
                                  hintStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        height5(),
                        bodyLargeText('Payment Type', context,
                            color: Colors.black, fontWeight: FontWeight.w500),
                        height5(),
                        Container(
                          // color: Colors.red,
                          child: Row(
                            children: <Widget>[
                              Expanded(child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                    ),
                                    isEmpty: _currentPaymentTypeKey == '',
                                    child: DropdownButtonHideUnderline(
                                      child: provider
                                              .paymentTypes.entries.isNotEmpty
                                          ? DropdownButton<String>(
                                              value:
                                                  _currentPaymentTypeKey == ''
                                                      ? provider.paymentTypes
                                                          .entries.first.key
                                                      : _currentPaymentTypeKey,
                                              isDense: false,
                                              alignment: AlignmentDirectional
                                                  .bottomCenter,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _currentPaymentTypeVal =
                                                      newValue!;
                                                  state.didChange(newValue);
                                                });
                                              },
                                              selectedItemBuilder: (context) {
                                                return provider
                                                    .paymentTypes.entries
                                                    .map<Center>((e) => Center(
                                                          child: Text(
                                                            e.value,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ))
                                                    .toList();
                                              },
                                              items: <DropdownMenuItem<String>>[
                                                ...provider.paymentTypes.entries
                                                    .toList()
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>((type) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: type.key,
                                                    child: Text(
                                                      type.value,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _currentPaymentTypeKey =
                                                            type.key;
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              iconEnabledColor: Colors.black,
                                              menuMaxHeight: double.maxFinite,
                                              dropdownColor: bColor(),
                                              focusColor: Colors.transparent,
                                              elevation: 10,
                                            )
                                          : Container(),
                                    ),
                                  );
                                },
                              )),
                            ],
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () => provider.coinPaymentSubmit(
                                        _currentPaymentTypeKey),
                                    child: Text('Submit')))
                          ],
                        ),
                        height5(),
                      ],
                    ),
                  );
                },
              ),
            ));
  }
}
