import 'package:flutter/material.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  TextEditingController account_holder_name = TextEditingController();
  TextEditingController account_number = TextEditingController();
  TextEditingController ifsc_code = TextEditingController();
  TextEditingController bank = TextEditingController();
  TextEditingController bankBranch = TextEditingController();
  TextEditingController upi = TextEditingController();
  TextEditingController emailOTP = TextEditingController();

  initiate() {
    var provider = sl.get<AuthProvider>();
    provider.commissionWithdrawal().then((value) {
      setState(() {
        account_holder_name =
            TextEditingController(text: provider.account_holder_name);
        account_number = TextEditingController(text: provider.account_number);
        ifsc_code = TextEditingController(text: provider.ifsc_code);
        bank = TextEditingController(text: provider.bank);
        upi = TextEditingController(text: provider.upiId);
        bankBranch = TextEditingController(text: provider.branch);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initiate();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(title: titleLargeText('Bank Details', context)),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: userAppBgImageProvider(context),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: buildBody(size.height),
      ),
      bottomNavigationBar: buildBottomButton(context),
    );
  }

  Padding buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
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
                onPressed: () {
                  var provider = sl.get<AuthProvider>();
                  provider.paymentMethodSubmit(
                    account_holder_name.text,
                    account_number.text,
                    ifsc_code.text,
                    bank.text,
                    bankBranch.text,
                    upi.text,
                  );
                },
                child:
                    bodyMedText('Update', context, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(double height) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return !provider.loadingCommissionWithdrawal
            ? ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  /// Bank Name
                  fieldTitle('Bank Name*'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: bank,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              const InputDecoration(hintText: 'Bank Name'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),

                  /// Bank Branch
                  fieldTitle('Bank Branch*'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: bankBranch,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              const InputDecoration(hintText: 'Bank Branch'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),

                  /// Account Holder Name
                  fieldTitle('Account Holder Name*'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: account_holder_name,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: 'Account Holder Name'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('Account Number*'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: account_number,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              const InputDecoration(hintText: 'Account Number'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('IFSC Code*'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: ifsc_code,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              const InputDecoration(hintText: 'IFSC Code'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('UPI ID'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: upi,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: 'UPI ID (Optional)'),
                        ),
                      ),
                    ],
                  ),
                  // const Divider(color: Colors.white),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     TextButton(
                  //         onPressed: () => sl
                  //             .get<AuthProvider>()
                  //             .getCommissionWithdrawalsEmailOtp(),
                  //         child: const Text('Get Email OTP',
                  //             style: TextStyle(
                  //                 color: Colors.blue,
                  //                 decoration: TextDecoration.underline)))
                  //   ],
                  // ),
                  // const Divider(color: Colors.white),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     fieldTitle('Email OTP (One Time Password)'),
                  //   ],
                  // ),
                  // Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: TextFormField(
                  //         enabled: true,
                  //         controller: emailOTP,
                  //         cursorColor: Colors.white,
                  //         style: const TextStyle(color: Colors.white),
                  //         decoration: const InputDecoration(
                  //           hintText: 'ex:- 123456',
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  height20(height * 0.01),
                  height20(height * 0.01),
                  height20(height * 0.01),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
      },
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
