import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

class CashWalletAddFundFromCardPayment extends StatefulWidget {
  const CashWalletAddFundFromCardPayment({Key? key}) : super(key: key);

  @override
  State<CashWalletAddFundFromCardPayment> createState() =>
      _CashWalletAddFundFromCardPaymentState();
}

class _CashWalletAddFundFromCardPaymentState
    extends State<CashWalletAddFundFromCardPayment> {
  var provider = sl.get<CashWalletProvider>();

  @override
  void initState() {
    provider.getCardPaymentFundRequest(true).then((value) {});
    super.initState();
  }

  @override
  void dispose() {
    provider.amountController.clear();
    provider.cardPaymentPage = 0;
    provider.cardRequests.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getCardPaymentFundRequest();
  }

  Future<void> _refresh() async {
    provider.cardPaymentPage = 0;
    await provider.getCardPaymentFundRequest(true);
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    // sl.get<CashWalletProvider>().getCardPaymentFundRequest();
    return Consumer<CashWalletProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
              title: titleLargeText('Card Payment History', context,
                  useGradient: true)),
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
      child: (provider.loadingCardRequestData ||
              provider.cardRequests.isNotEmpty)
          ? LoadMoreContainer(
              finishWhen:
                  provider.cardRequests.length >= provider.totalCardPayment,
              onLoadMore: _loadMore,
              onRefresh: _refresh,
              builder: (scrollController, status) {
                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  itemCount: !provider.loadingCardRequestData
                      ? provider.cardRequests.length
                      : 7,
                  itemBuilder: (context, index) {
                    var history = FundRequestModel();
                    if (!provider.loadingCardRequestData) {
                      history = provider.cardRequests[index];
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: !provider.loadingCardRequestData
                            ? buildExpansionTile(history, context)
                            : Skeleton(
                                height: 70,
                                width: double.maxFinite,
                                textColor: Colors.white38,
                              ),
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
                bodyLargeText(
                  '$currency_icon${history.amount}',
                  context,
                ),
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
              if (history.paymentUrl != null)
                GestureDetector(
                  onTap: () {
                    // Get.to(AppWebView(url: history.paymentUrl ?? ''));
                    launchTheLink(history.paymentUrl ?? '');
                  },
                  child: Row(
                    children: [
                      bodyLargeText('Check Status', context,
                          color: Colors.blue,
                          decoration: TextDecoration.underline
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
                  onPressed: () => buildShowModalBottomSheet(context, provider),
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

  Future<dynamic> buildShowModalBottomSheet(
      BuildContext context, CashWalletProvider provider) {
    var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    return showModalBottomSheet(
        backgroundColor: bColor(1),
        elevation: 1,
        barrierColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (context) => _CashWalletAddFundFromCardPaymentBottomSheet(
            paymentTypes: provider.paymentTypes));
  }
}

double? getValidDouble(val, {bool? showToast}) {
  double? value;
  try {
    value = double.parse(val.toString());
  } catch (e) {
    print('getValidDouble $e');
    Fluttertoast.showToast(msg: 'Invalid amount');
  }
  return value;
}

class _CashWalletAddFundFromCardPaymentBottomSheet extends StatefulWidget {
  const _CashWalletAddFundFromCardPaymentBottomSheet(
      {required this.paymentTypes});
  final Map<String, dynamic> paymentTypes;

  @override
  State<_CashWalletAddFundFromCardPaymentBottomSheet> createState() =>
      _CashWalletAddFundFromCardPaymentBottomSheetState();
}

class _CashWalletAddFundFromCardPaymentBottomSheetState
    extends State<_CashWalletAddFundFromCardPaymentBottomSheet> {
  String _currentPaymentTypeVal = '';
  String _currentPaymentTypeKey = '';

  @override
  void initState() {
    setState(() {
      if (widget.paymentTypes.entries.isNotEmpty)
        _currentPaymentTypeKey = widget.paymentTypes.entries.first.key;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    sl.get<CashWalletProvider>().amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    return Consumer<CashWalletProvider>(builder: (context, provider, child) {
      return Container(
        padding: EdgeInsets.all(16),
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
            bodyLargeText('Amount', context,
                color: Colors.black, fontWeight: FontWeight.w500),
            height5(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: provider.amountController,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    inputFormatters: [NoDoubleDecimalFormatter()],
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefix: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: bodyLargeText(currencyIcon, context,
                            useGradient: false),
                      ),
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            height5(),
            bodyLargeText('Payment Type', context,
                color: Colors.black, fontWeight: FontWeight.w500),
            height5(),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.white70)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.white70)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.white70)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(color: Colors.white70)),
                        ),
                        isEmpty: _currentPaymentTypeKey == '',
                        child: provider.paymentTypes.entries.isNotEmpty
                            ? DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _currentPaymentTypeKey == ''
                                      ? null
                                      : _currentPaymentTypeKey,
                                  onChanged: (String? newValue) => setState(() {
                                    _currentPaymentTypeVal = newValue!;
                                    state.didChange(newValue);
                                  }),
                                  selectedItemBuilder: (context) =>
                                      provider.paymentTypes.entries
                                          .map<Center>((e) => Center(
                                                child: bodyLargeText(
                                                    e.value, context,
                                                    useGradient: false),
                                              ))
                                          .toList(),
                                  items: <DropdownMenuItem<String>>[
                                    ...provider.paymentTypes.entries
                                        .toList()
                                        .map<DropdownMenuItem<String>>((type) {
                                      return DropdownMenuItem<String>(
                                        value: type.key,
                                        child: bodyMedText(
                                          type.value,
                                          context,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _currentPaymentTypeKey = type.key;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ],
                                  borderRadius: BorderRadius.circular(15),
                                  iconEnabledColor: Colors.white70,
                                  menuMaxHeight: double.maxFinite,
                                  dropdownColor: Colors.white,
                                  elevation: 10,
                                  alignment: AlignmentDirectional.bottomEnd,
                                  isDense: true,
                                ),
                              )
                            : Container(),
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
                        onPressed: _currentPaymentTypeKey != '' &&
                                provider.amountController.text.isNotEmpty
                            ? () {
                                double? amount = getValidDouble(
                                    provider.amountController.text);
                                print(amount);
                                if (amount != null) {
                                  provider.getCardPaymentOrderId(
                                      amount, _currentPaymentTypeKey);
                                }
                              }
                            : null,
                        child: Text('Submit')))
              ],
            ),
            height5(),
          ],
        ),
      );
    });
  }
}
