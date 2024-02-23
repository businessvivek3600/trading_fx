import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '/database/model/response/additional/signup_country_model.dart';
import '/database/model/response/states_model.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/widgets/app_country_picker.dart';
import '/widgets/app_state_picker.dart';
import 'package:provider/provider.dart';

import '../../../utils/picture_utils.dart';
import '../../../utils/sizedbox_utils.dart';
import '../../../utils/text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //personal
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nextOfKinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pUserNameController = TextEditingController();

  //address
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _address1sController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _adhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _nomineeNameController = TextEditingController();
  final TextEditingController _nomineeRelationController =
      TextEditingController();

  ///social media links
  final TextEditingController _ytLinkController = TextEditingController();
  final TextEditingController _fbLinkController = TextEditingController();
  final TextEditingController _zoomLinkController = TextEditingController();
  final TextEditingController _instaLinkController = TextEditingController();
  final TextEditingController _twitterLinkController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  SignUpCountry? signUpCountry;
  States? selectedState;
  bool initializing = false;
  var authProvider = sl.get<AuthProvider>();
  initialiseFields() async {
    var u = authProvider.userData;

    await Future(() async {
      //personal
      _firstNameController.text = u.firstName ?? '';
      _lastNameController.text = u.lastName ?? '';
      _nextOfKinController.text = u.firstName ?? '';
      _emailController.text = u.customerEmail ?? '';
      _phoneController.text = u.customerMobile ?? '';
      _whatsappController.text = u.fatherName ?? '';
      _pUserNameController.text = u.placementUsername ?? '';
      try {
        _dobController.text = u.dateOfBirth == null
            ? ''
            : DateTime.parse(u.dateOfBirth!)
                    .isAfter(DateTime.parse('1970-01-01'))
                ? DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(u.dateOfBirth ?? ''))
                : '';
      } catch (e) {
        _dobController.text = '';
      }

      //address
      _companyNameController.text = u.company ?? '';
      _countryController.text = u.countryText ?? '';
      if (u.countryCode != null) {
        // print('country code is ${authProvider.countriesList}');
        signUpCountry = sl
            .get<AuthProvider>()
            .countriesList
            .firstWhere((element) => element.phonecode == u.countryCode);
        await authProvider.getStates(signUpCountry?.id ?? '');

        setState(() {});
        // authProvider.countriesList.forEach((element) =>
        //     print('${element.id?.length}   ' + '  ${u.country?.length}'));
        print('country code is ${u.countryCode}');
        print('country code is ${signUpCountry?.phonecode}');
      }
      if (u.state != null) {
        selectedState = sl.get<AuthProvider>().states.firstWhereOrNull(
            (element) => element.name?.trim() == u.state?.trim());
      }

      _stateController.text = u.state ?? '';
      _cityController.text = u.city ?? '';
      _houseNoController.text = u.customerShortAddress ?? '';
      _address1sController.text = u.customerAddress1 ?? '';
      _address2Controller.text = u.customerAddress2 ?? '';
      _postCodeController.text = u.zip ?? '';
      _panController.text = u.panCard ?? '';
      _adhaarController.text = u.aadharCard ?? '';

      ///social media links
      _ytLinkController.text = u.socialYoutube ?? '';
      _fbLinkController.text = u.socialFacebook ?? '';
      _zoomLinkController.text = u.socialZoom ?? '';
      _instaLinkController.text = u.socialInstagram ?? '';
      _twitterLinkController.text = u.socialTwitter ?? '';
      _nomineeNameController.text = u.nomineeName ?? '';
      _nomineeRelationController.text = u.nomineeRelation ?? '';
    }).then((value) => setState(() {
          initializing = false;
        }));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() => initializing = true);
      authProvider.userInfo().then((value) => initialiseFields());
    });
    super.initState();
  }

  @override
  void dispose() {
    var u = authProvider;
    u.states.clear();
    super.dispose();
  }

  AnimatedContainer buildVerifyEmailSuffix(AuthProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: provider.loadingVerifyEmail ? 60 : 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
            colors: textGradiantColors.map((e) => e.withOpacity(0.4)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: TextButton(
        onPressed:
            provider.loadingVerifyEmail ? null : () => provider.verifyemail(),
        child: provider.loadingVerifyEmail
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 25,
                      height: 25,
                      child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)))
                ],
              )
            : const Text(
                'verify',
                style: TextStyle(color: Colors.white),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(builder: (context, authProvider, _) {
      return Scaffold(
        key: _scaffoldKey,
        body: DefaultTabController(
          length: 2,
          child: Stack(
            children: [
              Scaffold(
                  backgroundColor: mainColor,
                  appBar: buildAppBar(),
                  body: Stack(
                    children: [
                      Container(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: userAppBgImageProvider(context),
                                  fit: BoxFit.cover,
                                  opacity: 1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: !initializing
                            ? Form(
                                key: _formKey,
                                child: TabBarView(
                                  children: <Widget>[
                                    buildPersonalForm(
                                        size.height, authProvider),
                                    buildAddressForm(size.height),
                                    // buildSocialMediaLinkForm(size.height),
                                    // buildPositionedForm(size.height),
                                  ],
                                ),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white)),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
    });
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: titleLargeText('Edit Profile', context),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: TabBar(
              // isScrollable: true,
              unselectedLabelColor: Colors.white.withOpacity(0.3),
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                    child: Text(
                  'Personal',
                  style: GoogleFonts.ubuntu(),
                )),
                Tab(
                    child: Text(
                  'Address',
                  style: GoogleFonts.ubuntu(),
                )),
                // Tab(
                //     child: Text(
                //   'Social Media Links (Optional)',
                //   style: GoogleFonts.ubuntu(),
                // )),
                // Tab(
                //     child: Text(
                //   'Position',
                //   style: GoogleFonts.ubuntu(),
                // )),
              ])),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  var data = {
                    'first_name': _firstNameController.text,
                    'last_name': _lastNameController.text,
                    'whatsapp_no': _whatsappController.text,
                    'customer_email': _emailController.text,
                    'customer_mobile': _phoneController.text,
                    'date_of_birth': _dobController.text,
                    'company': _companyNameController.text,
                    'country': signUpCountry?.id ?? '',
                    'state': selectedState?.name ?? '',
                    'city': _cityController.text,
                    'customer_short_address': _houseNoController.text,
                    'customer_address_1': _address1sController.text,
                    'customer_address_2': _address2Controller.text,
                    'zip': _postCodeController.text,
                    'aadhaar_no': _adhaarController.text,
                    'pan_no': _panController.text,
                    'nominee_name': _nomineeNameController.text,
                    'nominee_relation': _nomineeRelationController.text,
                  };
                  print(data);
                  authProvider.updateProfile(data);
                }
              },
              icon: const Icon(Icons.done)),
        ),
      ],
    );
  }

  Widget buildPositionedForm(double height) {
    bool emailVerified = authProvider.userData.verifyEmail == "1";
    bool kycDone = authProvider.userData.kyc == '1';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      physics: const BouncingScrollPhysics(),
      children: [
        height20(height * 0.01),
        fieldTitle('Placement Id'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                controller: _pUserNameController,
                enabled: true,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Placement Id'),
                onEditingComplete: () => primaryFocus?.unfocus(),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
      ],
    );
  }

  Widget buildPersonalForm(double height, AuthProvider authProvider) {
    bool emailVerified = authProvider.userData.verifyEmail == "1";
    bool kycDone = authProvider.userData.kyc == '1';
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      physics: const BouncingScrollPhysics(),
      children: [
        height10(height * 0.01),
        titleLargeText('Update Account', context, fontSize: 32),
        height5(height * 0.01),
        fieldTitle('Username: ${authProvider.userData.username ?? ''}'),
        height5(height * 0.02),
        if (kycDone)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bodyLargeText(
                  'Your details cannot be changed after the KYC approval.',
                  context,
                  color: Colors.red),
              height5(height * 0.02),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  fieldTitle('First Name'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          enabled: !kycDone,
                          controller: _firstNameController,
                          cursorColor: Colors.white,
                          style: GoogleFonts.ubuntu(
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                          decoration:
                              const InputDecoration(hintText: 'First Name'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            width5(),
            Expanded(
              child: Column(
                children: [
                  fieldTitle('Last Name'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          enabled: !kycDone,
                          controller: _lastNameController,
                          cursorColor: Colors.white,
                          style: GoogleFonts.ubuntu(
                              textStyle: const TextStyle(color: Colors.white)),
                          decoration:
                              const InputDecoration(hintText: 'Last Name'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        height20(height * 0.01),
        // fieldTitle('Next of Kin (Optional)'),
        // Row(
        //   children: <Widget>[
        //     Expanded(
        //       child: TextFormField(
        // textInputAction:TextInputAction.next,
        //         enabled: !kycDone,
        //         controller: _nextOfKinController,
        //         cursorColor: Colors.white,
        //         style: GoogleFonts.ubuntu(
        //           textStyle: const TextStyle(color: Colors.white),
        //         ),
        //         decoration: const InputDecoration(hintText: 'Next of Kin'),
        //       ),
        //     ),
        //   ],
        // ),
        // height20(height * 0.01),
        fieldTitle('Email'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                enabled: !emailVerified && !kycDone,
                cursorColor: Colors.white,
                controller: _emailController,
                style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(color: Colors.white),
                ),
                decoration: InputDecoration(
                  hintText: 'Email Id',
                  suffixIcon: emailVerified
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: bodyMedText('Verified', context,
                                    color: Colors.green))
                          ],
                        )
                      : buildVerifyEmailSuffix(authProvider),
                ),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
        fieldTitle('Phone Number'),
        IntlPhoneField(
          // enabled: !kycDone,
          cursorColor: Colors.white,
          flagsButtonMargin: const EdgeInsets.only(left: 10),
          style: GoogleFonts.ubuntu(
              textStyle: const TextStyle(color: Colors.white)),
          decoration: const InputDecoration(hintText: 'Phone Number'),
          onChanged: (phone) => print(phone.completeNumber),
          controller: _phoneController,
          dropdownIconPosition: IconPosition.trailing,
          dropdownTextStyle: const TextStyle(color: Colors.white70),
          dropdownIcon:
              const Icon(Icons.arrow_drop_down, color: Colors.white70),
          initialCountryCode: signUpCountry?.sortname,
          textInputAction: TextInputAction.next,
          pickerDialogStyle: PickerDialogStyle(
              listTilePadding: EdgeInsets.zero,
              // backgroundColor: bColor(),
              // countryCodeStyle: TextStyle(color: Colors.white70),
              // countryNameStyle: TextStyle(color: Colors.white70),
              // searchFieldCursorColor: Colors.white,
              listTileDivider: const Divider(height: 0),
              searchFieldInputDecoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide()),
                hintText: 'Search Country',
                hintStyle: TextStyle(color: Colors.black),
                // labelStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                // border: Theme.of(context).inputDecorationTheme.border,
                enabledBorder: OutlineInputBorder(borderSide: BorderSide()),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide()),
                // fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                // filled: Theme.of(context).inputDecorationTheme.filled,
              )),
          onCountryChanged: (country) =>
              print('Country changed to: ' + country.name),
        ),

        ///Whatsapp Number (Optional)
        height20(height * 0.01),
        fieldTitle('Whatsapp Number (Optional)'),
        IntlPhoneField(
          // enabled: !kycDone,
          cursorColor: Colors.white,
          textInputAction: TextInputAction.next,
          flagsButtonMargin: const EdgeInsets.only(left: 10),
          style: GoogleFonts.ubuntu(
              textStyle: const TextStyle(color: Colors.white)),
          decoration: const InputDecoration(hintText: 'Whatsapp Number'),
          onChanged: (phone) => print(phone.completeNumber),
          controller: _whatsappController,
          dropdownIconPosition: IconPosition.trailing,
          dropdownTextStyle: const TextStyle(color: Colors.white70),
          dropdownIcon:
              const Icon(Icons.arrow_drop_down, color: Colors.white70),
          initialCountryCode: signUpCountry?.sortname,
          pickerDialogStyle: PickerDialogStyle(
              listTilePadding: EdgeInsets.zero,
              // backgroundColor: bColor(),
              // countryCodeStyle: TextStyle(color: Colors.white70),
              // countryNameStyle: TextStyle(color: Colors.white70),
              // searchFieldCursorColor: Colors.white,
              listTileDivider: const Divider(height: 0),
              searchFieldInputDecoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide()),
                hintText: 'Search Country',
                hintStyle: TextStyle(color: Colors.black),
                // labelStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                // border: Theme.of(context).inputDecorationTheme.border,
                enabledBorder: OutlineInputBorder(borderSide: BorderSide()),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide()),
                // fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                // filled: Theme.of(context).inputDecorationTheme.filled,
              )),
          onCountryChanged: (country) =>
              print('Country changed to: ' + country.name),
        ),
        height20(height * 0.01),
        fieldTitle('Date Of Birth'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                // enabled: !kycDone,
                controller: _dobController,
                cursorColor: Colors.white,
                readOnly: true,
                style: GoogleFonts.ubuntu(
                    textStyle: const TextStyle(color: Colors.white)),
                decoration: InputDecoration(
                  hintText: 'ex:- 01-02-2003',
                  suffixIcon: IconButton(
                      onPressed: kycDone
                          ? null
                          : () async {
                              print(_dobController.text);
                              var lastDate = DateTime.now()
                                  .subtract(const Duration(days: 365));
                              DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: _dobController.text.isNotEmpty
                                      ? DateTime.parse(_dobController.text)
                                      : lastDate,
                                  firstDate: DateTime(1970),
                                  lastDate: lastDate);
                              if (date != null) {
                                setState(() {
                                  _dobController.text =
                                      DateFormat('yyyy-MM-dd').format(date);
                                });
                              }
                            },
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white70,
                      )),
                ),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
      ],
    );
  }

  Widget buildAddressForm(double height) {
    bool kycDone = authProvider.userData.kyc != '1';
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return ListView(
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 50),
          physics: const BouncingScrollPhysics(),
          children: [
            height20(height * 0.03),
            fieldTitle('Company (Optional)'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    enabled: !kycDone,
                    controller: _companyNameController,
                    cursorColor: Colors.white,
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    decoration: const InputDecoration(hintText: 'Company Name'),
                  ),
                ),
              ],
            ),
            height20(height * 0.01),
            fieldTitle('Country'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    enabled: false,
                    readOnly: true,
                    onTap: () => _scaffoldKey.currentState?.showBottomSheet(
                      (context) => ShowAppCountryPicker(
                        callback: (country) async {
                          if (country != null) {
                            provider.getStates(country.id ?? "");
                          }
                          country != null
                              ? _countryController.text = country.name ?? ''
                              : _countryController.clear();
                          if (country != signUpCountry) {
                            _stateController.clear();
                            selectedState = null;
                          }
                          setState(() => signUpCountry = country);

                          Navigator.pop(context);
                        },
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    controller: _countryController,
                    cursorColor: Colors.white,
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    decoration: const InputDecoration(
                        hintText: 'Select Country', fillColor: Colors.white30),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a country';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            height20(height * 0.01),
            // Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Skeleton(
            //             textColor: Colors.white30,
            //             width: 40,
            //             height: 10,
            //             borderRadius: BorderRadius.circular(5),
            //           ),
            //           height10()
            //         ],
            //       )
            //     :
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                fieldTitle('State'),
                if (provider.loadingStates)
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                        width: 10,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      height10()
                    ],
                  )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    enabled: !provider.loadingStates && !kycDone,
                    readOnly: true,
                    onTap: () => _scaffoldKey.currentState?.showBottomSheet(
                      (context) => ShowAppStatePicker(
                        callback: (state) async {
                          state != null
                              ? _stateController.text = state.name ?? ''
                              : _stateController.clear();
                          setState(() => selectedState = state);
                          Navigator.pop(context);
                        },
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    controller: _stateController,
                    cursorColor: Colors.white,
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a state';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Select State',
                        fillColor:
                            !provider.loadingStates ? null : Colors.black12),
                  ),
                ),
              ],
            ),
            height20(height * 0.01),
            fieldTitle('City'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    enabled: !kycDone,
                    controller: _cityController,
                    cursorColor: Colors.white,
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    decoration: const InputDecoration(hintText: 'Select City'),
                  ),
                ),
              ],
            ),
            height20(height * 0.01),
            fieldTitle('House/Flat No. *'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    enabled: !kycDone,
                    controller: _houseNoController,
                    cursorColor: Colors.white,
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    decoration: const InputDecoration(
                        hintText: 'ex:- 25 B, Park, Street no. 11, London'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter House/Flat No.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            height20(height * 0.01),
            fieldTitle('Address 1*'),
            TextFormField(
              textInputAction: TextInputAction.next,
              enabled: !kycDone,
              cursorColor: Colors.white,
              controller: _address1sController,
              style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(color: Colors.white)),
              decoration: const InputDecoration(
                  hintText: 'ex:- 25 B, Park, Street no. 11, London'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            height20(height * 0.01),
            fieldTitle('Address 2 (Optional)'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    enabled: !kycDone,
                    controller: _address2Controller,
                    cursorColor: Colors.white,
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    decoration: const InputDecoration(
                        hintText: 'ex:- 25 B, Park, Street no. 11, London'),
                  ),
                ),
              ],
            ),
            height20(height * 0.01),
            fieldTitle('Post Code/ Zip *'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _postCodeController,
                    enabled: !kycDone,
                    cursorColor: Colors.white,
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                    decoration: const InputDecoration(hintText: 'ex:-XYZq11'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Post Code/ Zip';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            height20(height * 0.01),

            /// adhaar and pan * with validation
            Column(
              children: [
                fieldTitle('Adhaar Number *'),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  enabled: !kycDone,
                  controller: _adhaarController,
                  cursorColor: Colors.white,
                  style: GoogleFonts.ubuntu(
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  decoration: const InputDecoration(hintText: 'Adhaar Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Adhaar Number';
                    }
                    return null;
                  },
                ),
              ],
            ),

            height20(height * 0.01),
            Column(
              children: [
                fieldTitle('Pan Number *'),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  enabled: !kycDone,
                  controller: _panController,
                  cursorColor: Colors.white,
                  style: GoogleFonts.ubuntu(
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  decoration: const InputDecoration(hintText: 'Pan Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Pan Number';
                    }
                    return null;
                  },
                ),
              ],
            ),

            height20(height * 0.01),

            ///Nominee Name and Relation
            fieldTitle('Nominee Name *'),
            TextFormField(
              textInputAction: TextInputAction.next,
              enabled: !kycDone,
              controller: _nomineeNameController,
              cursorColor: Colors.white,
              style: GoogleFonts.ubuntu(
                textStyle: const TextStyle(color: Colors.white),
              ),
              decoration: const InputDecoration(hintText: 'Nominee Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Nominee Name';
                }
                return null;
              },
            ),

            height20(height * 0.01),
            fieldTitle('Nominee Relation *'),
            TextFormField(
              textInputAction: TextInputAction.next,
              enabled: !kycDone,
              controller: _nomineeRelationController,
              cursorColor: Colors.white,
              style: GoogleFonts.ubuntu(
                textStyle: const TextStyle(color: Colors.white),
              ),
              decoration: const InputDecoration(hintText: 'Nominee Relation'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Nominee Relation';
                }
                return null;
              },
            ),
            height20(height * 0.01),
          ],
        );
      },
    );
  }

  Widget buildSocialMediaLinkForm(double height) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      physics: const BouncingScrollPhysics(),
      children: [
        height20(height * 0.03),
        fieldTitle('Youtube Link'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                enabled: true,
                controller: _ytLinkController,
                cursorColor: Colors.white,
                style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(color: Colors.white),
                ),
                decoration: const InputDecoration(hintText: 'Youtube Link'),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
        fieldTitle('Facebook Link'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                enabled: true,
                controller: _fbLinkController,
                cursorColor: Colors.white,
                style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(color: Colors.white),
                ),
                decoration: const InputDecoration(hintText: 'Facebook Link'),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
        fieldTitle('Zoom Link'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                enabled: true,
                controller: _zoomLinkController,
                cursorColor: Colors.white,
                style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(color: Colors.white),
                ),
                decoration: const InputDecoration(hintText: 'Zoom Link'),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
        fieldTitle('Instagram Link'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                enabled: true,
                controller: _instaLinkController,
                cursorColor: Colors.white,
                style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(color: Colors.white),
                ),
                decoration: const InputDecoration(hintText: 'Instagram Link'),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
        fieldTitle('Twitter Link'),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                enabled: true,
                controller: _twitterLinkController,
                cursorColor: Colors.white,
                style: GoogleFonts.ubuntu(
                  textStyle: const TextStyle(color: Colors.white),
                ),
                decoration: const InputDecoration(hintText: 'Twitter Link'),
              ),
            ),
          ],
        ),
        height20(height * 0.01),
      ],
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
