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

class CommissionTransferToCashWalletPage extends StatefulWidget {
  const CommissionTransferToCashWalletPage({Key? key}) : super(key: key);

  @override
  State<CommissionTransferToCashWalletPage> createState() =>
      _CommissionTransferToCashWalletPageState();
}

class _CommissionTransferToCashWalletPageState
    extends State<CommissionTransferToCashWalletPage> {
  TextEditingController amountController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
  @override
  void initState() {
    amountController.text =
        sl.get<CommissionWalletProvider>().walletBalance.toStringAsFixed(1);
    setState(() {});
    super.initState();
  }

  setNewAmount(double per) => setState(() => amountController.text =
      (sl.get<CommissionWalletProvider>().walletBalance * per / 100)
          .toStringAsFixed(1));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<CommissionWalletProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
              title: titleLargeText('Transfer To Cash Wallet', context,
                  useGradient: true)),
          body: GestureDetector(
            onTap: () => primaryFocus?.unfocus(),
            child: Container(
              height: double.maxFinite,
              width: double.maxFinite,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: userAppBgImageProvider(context),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                              controller: amountController,
                              cursorColor: Colors.white,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter amount',
                                prefix: Text(
                                    '${sl.get<AuthProvider>().userData.currency_icon ?? ''}'),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() {}),
                              // autovalidateMode: AutovalidateMode.always,
                              validator: (val) {
                                if (val != null &&
                                    val.isNotEmpty &&
                                    double.parse(val).isNegative) {
                                  return 'Amount should not be negative.';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      height10(),
                      Divider(color: Colors.white),
                      Wrap(
                        spacing: 10,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xBD029919)),
                            onPressed: () => setNewAmount(100),
                            child: bodyMedText('100%', context,
                                textAlign: TextAlign.center),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () => setNewAmount(75),
                            child: bodyMedText('75%', context,
                                textAlign: TextAlign.center),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber),
                            onPressed: () => setNewAmount(50),
                            child: bodyMedText('50%', context,
                                textAlign: TextAlign.center),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => setNewAmount(25),
                            child: bodyMedText('25%', context,
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white),
                      height20(size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          fieldTitle('Net Amount'),
                          bodyLargeText(
                              '${currencyIcon}${amountController.text}',
                              context),
                        ],
                      ),
                      height20(size.height * 0.01),
                    ],
                  ),
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
                onPressed: provider.walletBalance > 0
                    ? () {
                        final isValid = _formKey.currentState?.validate();
                        if (isValid == null || !isValid) {
                          return;
                        }
                        provider.transferToCashWallet(amountController.text);
                      }
                    : null,
                child:
                    bodyMedText('Submit', context, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
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
