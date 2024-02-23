import 'package:flutter/material.dart';
import '/constants/assets_constants.dart';
import '/providers/Cash_wallet_provider.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class CashWalletNgCashWalletPage extends StatefulWidget {
  const CashWalletNgCashWalletPage({Key? key}) : super(key: key);

  @override
  State<CashWalletNgCashWalletPage> createState() =>
      _CashWalletNgCashWalletPageState();
}

class _CashWalletNgCashWalletPageState
    extends State<CashWalletNgCashWalletPage> {
  TextEditingController amountController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
  @override
  void initState() {
    super.initState();
    sl.get<CashWalletProvider>().getNGCashWalletData().then((value) =>
        amountController.text =
            sl.get<CashWalletProvider>().walletBalance.toStringAsFixed(1));
    setState(() {});
  }

  setNewAmount(double per) => setState(() => amountController.text =
      (sl.get<CashWalletProvider>().walletBalance * per / 100)
          .toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    return Consumer<CashWalletProvider>(
      builder: (context, provider, child) {
        double rate = provider.transaction_per;
        double amount = double.parse(
            amountController.text.isNotEmpty ? amountController.text : '0');
        double processingFee = amount * rate / 100;
        Size size = MediaQuery.of(context).size;
        return GestureDetector(
          onTap: () {
            primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: mainColor,
            appBar: AppBar(title: titleLargeText('NG Cash Wallet', context,useGradient: true)),
            body: Consumer<CashWalletProvider>(
              builder: (context, provider, child) {
                return Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: userAppBgImageProvider(context),
                        fit: BoxFit.cover,
                        opacity: 1),
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
                              provider.loadingNGCashWalletData
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : fieldTitle(
                                      '${currencyIcon}${provider.walletBalance.toStringAsFixed(2)}'),
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
                                  decoration:
                                      InputDecoration(hintText: 'Enter amount'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => setState(() {}),
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
                              fieldTitle('Processing Fee $rate% :'),
                              bodyLargeText(
                                  '${currencyIcon}${processingFee.toStringAsFixed(2)}',
                                  context),
                            ],
                          ),
                          height5(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              fieldTitle('Net Amount'),
                              bodyLargeText(
                                  '${currencyIcon}${(amount - processingFee).toStringAsFixed(2)}',
                                  context),
                            ],
                          ),
                          height20(size.height * 0.01),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            bottomNavigationBar: buildBottomButton(context, provider),
          ),
        );
      },
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: !provider.loadingNGCashWalletData
                    ? () {
                        final isValid = _formKey.currentState?.validate();
                        if (isValid == null || !isValid) {
                          return;
                        }
                        provider.addFundFromNGCashWallet(amountController.text);
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

  bool minimumExceed(double i) {
    bool exceeded = false;
    double walletBalance = sl.get<CashWalletProvider>().walletBalance;
    if (walletBalance < i) {
      exceeded = true;
    }
    return exceeded;
  }
}
