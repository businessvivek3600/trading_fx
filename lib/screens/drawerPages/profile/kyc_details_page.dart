import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class KycDetailsPage extends StatefulWidget {
  const KycDetailsPage({Key? key}) : super(key: key);

  @override
  State<KycDetailsPage> createState() => _KycDetailsPageState();
}

class _KycDetailsPageState extends State<KycDetailsPage> {
  TextEditingController bankName = TextEditingController();
  TextEditingController acNo = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  TextEditingController bank = TextEditingController();
  TextEditingController bankBranch = TextEditingController();

  /// aadharNo, panNo,nomineeName, nomineeRelation,dob
  TextEditingController aadharNo = TextEditingController();
  TextEditingController panNo = TextEditingController();
  TextEditingController nomineeName = TextEditingController();
  TextEditingController nomineeRelation = TextEditingController();
  TextEditingController dob = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  initiate() {
    var provider = sl.get<AuthProvider>();
    provider.commissionWithdrawal(type: 'kyc').then((value) {
      setState(() {
        bankName = TextEditingController(text: provider.bank);
        acNo = TextEditingController(text: provider.account_number);
        ifscCode = TextEditingController(text: provider.ifsc_code);
        bank = TextEditingController(text: provider.bank);
        bankBranch = TextEditingController(text: provider.branch);
        aadharNo = TextEditingController(text: provider.aadharNumber);
        panNo = TextEditingController(text: provider.panNumber);
        nomineeName = TextEditingController(text: provider.nomineeName);
        nomineeRelation = TextEditingController(text: provider.nomineeRelation);
        dob = TextEditingController(text: provider.dob);
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
      appBar: AppBar(title: titleLargeText('Customer KYC Form', context)),
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
                  if (_formKey.currentState?.validate() ?? false) {
                    var provider = sl.get<AuthProvider>();
                    provider.paymentMethodSubmit(
                      null,
                      acNo.text,
                      ifscCode.text,
                      bank.text,
                      bankBranch.text,
                      null,
                      type: 'kyc',
                      aadharNumber: aadharNo.text,
                      panNumber: panNo.text,
                      nomineeName: nomineeName.text,
                      nomineeRelation: nomineeRelation.text,
                      dob: dob.text,
                    );
                  }
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
            ? Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    /// Bank Name
                    fieldTitle('Bank Name*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: bank,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                                const InputDecoration(hintText: 'Bank Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Bank Name';
                              }
                              return null;
                            },
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
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: bankBranch,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                                const InputDecoration(hintText: 'Bank Branch'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Bank Branch';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    height20(height * 0.01),

                    /// Account Number
                    fieldTitle('Account Number*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: acNo,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: 'Account Number'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Account Number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    height20(height * 0.01),

                    /// IFSC Code
                    fieldTitle('IFSC Code*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: ifscCode,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                                const InputDecoration(hintText: 'IFSC Code'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter IFSC Code';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    height20(height * 0.01),

                    /// aaadhar Number
                    fieldTitle('Aadhar Number*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: aadharNo,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: 'Aadhar Number'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Aadhar Number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    height20(height * 0.01),

                    /// PAN Number
                    fieldTitle('PAN Number*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: panNo,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                                const InputDecoration(hintText: 'PAN Number'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter PAN Number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    height20(height * 0.01),

                    /// Nominee Name
                    fieldTitle('Nominee Name*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: nomineeName,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                                const InputDecoration(hintText: 'Nominee Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Nominee Name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    height20(height * 0.01),

                    /// Nominee Relation
                    fieldTitle('Nominee Relation*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            controller: nomineeRelation,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: 'Nominee Relation'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Nominee Relation';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    height20(height * 0.01),

                    /// Date of Birth
                    fieldTitle('Date of Birth*'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: dob,
                            cursorColor: Colors.white,
                            readOnly: true,
                            style: GoogleFonts.ubuntu(
                                textStyle:
                                    const TextStyle(color: Colors.white)),
                            decoration: InputDecoration(
                              hintText: 'ex:- 01-02-2003',
                              suffixIcon: IconButton(
                                  onPressed: () async {
                                    print(dob.text);
                                    var lastDate = DateTime.now()
                                        .subtract(const Duration(days: 365));
                                    var initialDate =
                                        (DateTime.tryParse(dob.text)
                                                    ?.isAfter(DateTime(1970)) ??
                                                false)
                                            ? DateTime.tryParse(dob.text)
                                            : lastDate;
                                            print(initialDate);
                                    DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate:initialDate??lastDate,
                                        firstDate: DateTime(1970),
                                        lastDate: lastDate);
                                    if (date != null) {
                                      setState(() {
                                        dob.text = DateFormat('yyyy-MM-dd')
                                            .format(date);
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_month,
                                      color: Colors.white70)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    height20(height * 0.01),
                  ],
                ),
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
