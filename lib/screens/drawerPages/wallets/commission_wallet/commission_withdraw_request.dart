import 'dart:io';

import 'package:flutter/material.dart';
import '/providers/auth_provider.dart';
import '/providers/commission_wallet_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class CommissionWithdrawRequestPage extends StatefulWidget {
  const CommissionWithdrawRequestPage({Key? key, this.fromHistory = false})
      : super(key: key);
  final bool fromHistory;

  @override
  State<CommissionWithdrawRequestPage> createState() =>
      _CommissionWithdrawRequestPageState();
}

class _CommissionWithdrawRequestPageState
    extends State<CommissionWithdrawRequestPage> {
  var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';

  var _formKey = GlobalKey<FormState>();
  String _currentWalletVal = 'wallet_commission';
  String _currentWalletKey = 'wallet_commission';

  String _currentPaymentTypeVal = '';
  String _currentPaymentTypeKey = '';

  @override
  void initState() {
    var provider = sl.get<CommissionWalletProvider>();
    provider.getCommissionWithdrawRequest().then((value) {
      setState(() {
        if (provider.paymentTypes.entries.isNotEmpty) {
          _currentPaymentTypeVal = provider.paymentTypes.entries.first.value;
          _currentPaymentTypeKey = provider.paymentTypes.entries.first.key;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    var provider = sl.get<CommissionWalletProvider>();
    provider.amountController.clear();
    provider.paymentTypes.clear();
    provider.loadingWithdrawSubmit = false;
    provider.loadingWithdrawSubmit = false;
    if (widget.fromHistory) {
      provider.withdrawRequestHistoryPage = 0;
      provider.getWithdrawRequestHistory(true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

    Size size = MediaQuery.of(context).size;
    return Consumer<CommissionWalletProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(title: titleLargeText('Withdraw Request', context)),
          body: GestureDetector(
            onTap: () => primaryFocus?.unfocus(),
            child: Container(
              height: double.maxFinite,
              width: double.maxFinite,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 0.8),
              ),
              child: !provider.loadingWithdrawRequestData
                  ? SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     fieldTitle('Select Wallet'),
                            //     fieldTitle('\$${provider.walletBalance}'),
                            //   ],
                            // ),
                            // Row(
                            //   children: <Widget>[
                            //     Expanded(
                            //       child: TextFormField(
                            //         enabled: true,
                            //         readOnly: true,
                            //         // controller: _nextOfKinController,
                            //         cursorColor: Colors.white,
                            //         style: TextStyle(color: Colors.white),
                            //         decoration:
                            //             InputDecoration(hintText: 'Choose your wallet'),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   children: <Widget>[
                            //     Expanded(child: FormField<String>(
                            //       builder: (FormFieldState<String> state) {
                            //         return InputDecorator(
                            //           baseStyle: TextStyle(color: Colors.white),
                            //           decoration: InputDecoration(
                            //               // labelStyle: textStyle,
                            //               hintStyle:
                            //                   TextStyle(color: Colors.white54),
                            //               errorStyle: TextStyle(
                            //                   color: Colors.redAccent,
                            //                   fontSize: 16.0),
                            //               hintText: 'Choose your wallet',
                            //               border: OutlineInputBorder(
                            //                   borderRadius:
                            //                       BorderRadius.circular(5.0))),
                            //           isEmpty: _currentWalletVal == '',
                            //           child: DropdownButtonHideUnderline(
                            //             child: DropdownButton<String>(
                            //               value: _currentWalletVal,
                            //               isDense: true,
                            //               alignment:
                            //                   AlignmentDirectional.bottomCenter,
                            //               onChanged: (String? newValue) {
                            //                 setState(() {
                            //                   _currentWalletVal = newValue!;
                            //                   state.didChange(newValue);
                            //                 });
                            //               },
                            //               items: <DropdownMenuItem<String>>[
                            //                 ...{'wallet_commission': 'Commission'}
                            //                     .entries
                            //                     .toList()
                            //                     .map<DropdownMenuItem<String>>(
                            //                         (type) {
                            //                   return DropdownMenuItem<String>(
                            //                     value: type.key,
                            //                     child: Text(type.value),
                            //                     onTap: () {
                            //                       setState(() {
                            //                         _currentWalletKey = type.key;
                            //                       });
                            //                     },
                            //                   );
                            //                 }).toList(),
                            //               ],
                            //               borderRadius: BorderRadius.circular(15),
                            //               iconEnabledColor: Colors.white,
                            //               style: TextStyle(color: Colors.white70),
                            //               menuMaxHeight: double.maxFinite,
                            //               dropdownColor: bColor(),
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //     )),
                            //   ],
                            // ),
                            // height20(size.height * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                fieldTitle('Amount'),
                                fieldTitle(
                                    '${currencyIcon}${provider.walletBalance}'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    enabled: true,
                                    controller: provider.amountController,
                                    cursorColor: Colors.white,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: Colors.white),
                                    onChanged: (val) => setState(() {}),
                                    decoration: InputDecoration(
                                      prefix: Text(
                                          '${sl.get<AuthProvider>().userData.currency_icon ?? ''}'),
                                      hintText: 'Enter amount',
                                      helperText:
                                          'Note:- minimum ${currencyIcon}${provider.minimumBalance} withdraw',
                                      helperStyle: TextStyle(
                                          color: appLogoColor.withOpacity(0.8)),
                                    ),
                                    // autovalidateMode: AutovalidateMode.always,
                                    validator: (val) {
                                      if (val != null &&
                                          val.isNotEmpty &&
                                          double.parse(val) <
                                              provider.minimumBalance) {
                                        return 'Please withdraw minimum $currency_icon${provider.minimumBalance}';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            height20(size.height * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                fieldTitle('Payment Type'),
                              ],
                            ),
                            // Row(
                            //   children: <Widget>[
                            //     Expanded(
                            //       child: TextFormField(
                            //         enabled: true,
                            //         readOnly: true,
                            //         // controller: _nextOfKinController,
                            //         cursorColor: Colors.white,
                            //         style: TextStyle(color: Colors.white),
                            //         decoration: InputDecoration(
                            //           hintText: 'Select payment type',
                            //           helperText:
                            //               'Bank withdrawals are only available to UAE, UK and Europe members !!\nPlease review your payment information !!',
                            //           helperStyle:
                            //               TextStyle(color: appLogoColor.withOpacity(0.8)),
                            //           helperMaxLines: 10,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            /*
                Row(
                  children: <Widget>[
                    Expanded(child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            baseStyle: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                // labelStyle: textStyle,
                                hintStyle: TextStyle(color: Colors.white54),
                                errorStyle: TextStyle(
                                    color: Colors.redAccent, fontSize: 16.0),
                                hintText: 'Select payment type',
                                helperText:
                                    'Bank withdrawals are only available to UAE, UK and Europe members !!\nPlease review your payment information !!',
                                helperStyle: TextStyle(
                                    color: appLogoColor.withOpacity(0.8)),
                                helperMaxLines: 10,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            isEmpty: _currentSelectedValue == '',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _currentSelectedValue,
                                isDense: true,
                                alignment: AlignmentDirectional.bottomCenter,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _currentSelectedValue = newValue!;
                                    state.didChange(newValue);
                                  });
                                },
                                items: <DropdownMenuItem<String>>[
                                  ..._currencies.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ],
                                borderRadius: BorderRadius.circular(15),
                                iconEnabledColor: Colors.white,
                                style: TextStyle(color: Colors.white70),
                                menuMaxHeight: double.maxFinite,
                                dropdownColor: bColor(),
                              ),
                            ),
                          );
                        },
                    )),
                  ],
                ),
                */
                            Row(
                              children: <Widget>[
                                Expanded(child: FormField<String>(
                                  builder: (FormFieldState<String> state) {
                                    return InputDecorator(
                                      baseStyle: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                          // labelStyle: textStyle,
                                          hintStyle:
                                              TextStyle(color: Colors.white),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 16.0),
                                          hintText: '',
                                          helperText:
                                              'Bank withdrawals are only available to UAE, UK and Europe members !!\nPlease review your payment information !!',
                                          helperStyle: TextStyle(
                                              color: appLogoColor
                                                  .withOpacity(0.8)),
                                          helperMaxLines: 10,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
                                      // isEmpty: _currentSelectedValue == '',
                                      child: provider
                                              .paymentTypes.entries.isNotEmpty
                                          ? DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _currentPaymentTypeKey ==
                                                        ''
                                                    ? provider.paymentTypes
                                                        .entries.first.key
                                                    : _currentPaymentTypeKey,
                                                isDense: true,
                                                alignment: AlignmentDirectional
                                                    .bottomCenter,
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _currentPaymentTypeVal =
                                                        newValue!;
                                                    state.didChange(newValue);
                                                  });
                                                },
                                                items: <
                                                    DropdownMenuItem<String>>[
                                                  ...provider
                                                      .paymentTypes.entries
                                                      .toList()
                                                      .map<
                                                          DropdownMenuItem<
                                                              String>>((type) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: type.key,
                                                      child: Text(type.value),
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
                                                iconEnabledColor: Colors.white,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                menuMaxHeight: double.maxFinite,
                                                dropdownColor: bColor(),
                                              ),
                                            )
                                          : Container(),
                                    );
                                  },
                                )),
                              ],
                            ),
                            height20(size.height * 0.01),
                            Divider(color: Colors.white),
                            if (_currentPaymentTypeKey == 'USDTB' &&
                                provider.paymentTypes.entries.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: bodyLargeText(
                                                        provider
                                                                .paymentTypes
                                                                .entries
                                                                .isNotEmpty
                                                            ? provider
                                                                .paymentTypes
                                                                .entries
                                                                .firstWhere(
                                                                    (element) =>
                                                                        element
                                                                            .key ==
                                                                        _currentPaymentTypeKey)
                                                                .value
                                                            : '',
                                                        context,
                                                        color: Colors.white60)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      width10(),
                                      if (provider.banks.isNotEmpty)
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    provider.banks.first
                                                            .usdtbAddress ??
                                                        '',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  height5(),
                                ],
                              ),
                            if (_currentPaymentTypeKey == 'USDTT' &&
                                provider.paymentTypes.entries.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: bodyLargeText(
                                                        provider.paymentTypes
                                                            .entries
                                                            .firstWhere((element) =>
                                                                element.key ==
                                                                _currentPaymentTypeKey)
                                                            .value,
                                                        context,
                                                        color: Colors.white60)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      width10(),
                                      if (provider.banks.isNotEmpty)
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    provider.banks.first
                                                            .usdttAddress ??
                                                        '',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  height5(),
                                ],
                              ),
                            if (_currentPaymentTypeKey == 'Bank' &&
                                provider.paymentTypes.entries.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: bodyLargeText(
                                                        'Account Holder Name:',
                                                        context,
                                                        color: Colors.white60)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      width10(),
                                      if (provider.banks.isNotEmpty)
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    provider.banks.first
                                                            .accountHolderName ??
                                                        '',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  height5(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: bodyLargeText(
                                                        'Account/IBAN:',
                                                        context,
                                                        color: Colors.white60)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      width10(),
                                      if (provider.banks.isNotEmpty)
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    provider.banks.first
                                                            .accountNumber ??
                                                        '',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  height5(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: bodyLargeText(
                                                        'Sort Code/ Swift Code/ BIC:',
                                                        context,
                                                        color: Colors.white60)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      width10(),
                                      if (provider.banks.isNotEmpty)
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    provider.banks.first
                                                            .ifscCode ??
                                                        '',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  height5(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: bodyLargeText(
                                                        'Bank:', context,
                                                        color: Colors.white60)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      width10(),
                                      if (provider.banks.isNotEmpty)
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    provider.banks.first.bank ??
                                                        '',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            height5(),
                            height5(),
                            if (provider.admin_per.entries.isNotEmpty)
                              Builder(builder: (context) {
                                double rate = double.parse(provider
                                    .admin_per.entries
                                    .firstWhere((element) =>
                                        element.key == _currentPaymentTypeKey)
                                    .value);
                                // double minimum = 7.0;
                                double amount = double.parse(
                                    provider.amountController.text.isNotEmpty
                                        ? provider.amountController.text
                                        : '0');
                                double processingFee =
                                    amount < provider.minimumBalance
                                        // ? (amount == 0 ? 0 : minimum)
                                        ? 0
                                        : (amount * rate / 100);
                                double netEuro = amount - processingFee;
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                          'Processing Fee ${amount < provider.minimumBalance ? '$currency_icon 0' : '$currency_icon$rate %'} :',
                                                          context,
                                                          color:
                                                              Colors.white60)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        width10(),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    '$currency_icon$processingFee ',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    height5(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                          'Net Euro:', context,
                                                          color:
                                                              Colors.white60)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        width10(),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: bodyLargeText(
                                                    '$currency_icon$netEuro',
                                                    context,
                                                    color: Colors.white70,
                                                  )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(color: Colors.white),
                                  ],
                                );
                              }),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed:
                                        provider.admin_per.entries.isNotEmpty ||
                                                provider.paymentTypes.entries
                                                    .isNotEmpty
                                            ? () => provider.getEmailOtp()
                                            : null,
                                    child: Text('Get Email OTP',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        )))
                              ],
                            ),
                            Divider(color: Colors.white),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                fieldTitle('Email OTP (One Time Password)'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    enabled: true,
                                    controller: provider.emailOtpController,
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        hintText: 'ex:- 123456'),
                                  ),
                                ),
                              ],
                            ),
                            height20(size.height * 0.01),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          bottomNavigationBar: buildBottomButton(context, provider),
        );
      },
    );
  }

  Padding buildBottomButton(
      BuildContext context, CommissionWalletProvider provider) {
    return Padding(
      padding: EdgeInsets.only(
          left: 10.0, right: 10, bottom: Platform.isIOS ? 20 : 10),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: canWithdraw(provider)
                    ? () {
                        final isValid = _formKey.currentState?.validate();
                        print('8888888 $isValid');
                        if (isValid == null || !isValid) {
                          return;
                        }
                        sl.get<CommissionWalletProvider>().withdrawSubmit(
                            _currentWalletKey, _currentPaymentTypeKey);
                      }
                    : null,
                child: bodyMedText('Withdraw Request', context,
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool canWithdraw(CommissionWalletProvider provider) {
    bool canWithdraw = false;
    if (!provider.loadingWithdrawRequestData &&
        sl.get<CommissionWalletProvider>().banks.isNotEmpty &&
        provider.walletBalance > 0) {
      var bank = sl.get<CommissionWalletProvider>().banks[0];
      if (_currentPaymentTypeKey == 'USDTB') {
        canWithdraw = bank.usdtbAddress != null && bank.usdtbAddress != '';
      } else if (_currentPaymentTypeKey == 'USDTT') {
        canWithdraw = bank.usdttAddress != null && bank.usdttAddress != '';
      }
      if (_currentPaymentTypeKey == 'Bank') {
        canWithdraw = bank.accountNumber != null && bank.accountNumber != '';
      }
    }
    return canWithdraw;
  }

  Widget fieldTitle(String title) {
    return Column(
      children: [
        Row(
          children: [
            bodyLargeText(title, context, color: Colors.white70),
          ],
        ),
        height10(),
      ],
    );
  }
}
