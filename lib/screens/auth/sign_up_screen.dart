import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/additional/signup_country_model.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../database/model/body/register_model.dart';
import '../../utils/color.dart';
import '../../utils/picture_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key, this.sponsor, this.placement})
      : super(key: key);
  static const String routeName = '/signup';
  final String? sponsor;
  final String? placement;
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _sUserNameController = TextEditingController();
  TextEditingController _pUserNameController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();

  FocusNode _userNameFocus = FocusNode();
  FocusNode _pUserNameFocus = FocusNode();
  FocusNode _fNameFocus = FocusNode();
  FocusNode _lNameFocus = FocusNode();
  FocusNode _emailFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  FocusNode _confirmPasswordFocus = FocusNode();
  FocusNode _sUserNameFocus = FocusNode();
  SignUpCountry? signUpCountry;

  RegisterModel register = RegisterModel();

  bool haveReferer = false;
  bool acceptedTerms = false;
  bool acceptedDisclaimer = false;
  bool above18 = false;

  var provider = sl.get<AuthProvider>();
  @override
  void initState() {
    super.initState();
    provider.getSignUpInitialData();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation =
        CurveTween(curve: Curves.fastOutSlowIn).animate(animationController!);
    countryOverlayFocus.addListener(() {
      ('countryOverlayFocus.hasFocus ${countryOverlayFocus.hasFocus}');

      if (!countryOverlayFocus.hasFocus) {
        this.countryOverlay = _showOverLay();
        Overlay.of(context).insert(this.countryOverlay!);
      } else {
        this.countryOverlay?.remove();
        this.countryOverlay = null;
      }
      setState(() {});
    });

    if (widget.sponsor != null) {
      _sUserNameController.text = widget.sponsor!;
    }
    if (widget.placement != null) {
      _pUserNameController.text = widget.placement!;
    }
    setState(() {});
  }

  @override
  void dispose() {
    animationController?.dispose();
    removeCountryOverlay();
    super.dispose();
  }

  AnimationController? animationController;
  Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    print('splash screen got #${widget.sponsor}   #${widget.placement}');
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        removeCountryOverlay();
        primaryFocus?.unfocus();
      },
      child: Scaffold(
          body: Container(
        height: height,
        width: double.maxFinite,
        color: mainColor,
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      height100(height * 0.1),
                      buildHeader(height, context),
                      height100(height * 0.05),
                      buildForm(height),
                      height20(height * 0.02),
                      buildSignUpButton(),
                      height20(height * 0.02),
                    ],
                  ),
                ),
              ),
              buildBackButton(),
            ],
          ),
        ),
      )),
    );
  }

  Positioned buildBackButton() {
    return Positioned(
      top: kToolbarHeight / 2 + 16,
      left: 16,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            gradient: buildButtonGradient(),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: assetSvg(Assets.arrowBack, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Row buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(text: "Already have an account? ", children: [
            TextSpan(
                text: ' Sign In',
                recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
                style: const TextStyle(
                    color: appLogoColor, fontWeight: FontWeight.bold)),
          ]),
        ),
      ],
    );
  }

  checkRestrictedText(String val) {
    var stringContainer = sl.get<AuthProvider>().restrictTexts;
    var result = stringContainer.any((element) =>
        RegExp(element, caseSensitive: false).hasMatch(val.toLowerCase()));
    print('$val is restricted - ${result} ');
    return result;
  }

  Widget buildForm(double height) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  titleLargeText('Create Account', context, fontSize: 32)
                ]),
                height5(height * 0.01),
                capText('Please sign in to continue.', context,
                    fontSize: 15,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold)
              ]),
              height20(height * 0.02),
              fieldTitle('Referer Id'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _sUserNameController,
                      focusNode: _sUserNameFocus,
                      textInputAction: TextInputAction.next,
                      enabled: !haveReferer,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: 'Referer Id', errorStyle: TextStyle()),
                      onChanged: (val) {
                        setState(() {
                          if (_pUserNameController.text.isEmpty) {
                            // _pUserNameController.text =
                            //     _sUserNameController.text;
                          }
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter referral Id';
                        } else if (!RegExp(r"^[a-zA-Z0-9]{6,15}$")
                            .hasMatch(val)) {
                          return "Must contain uppercase, lowercase and numeric letter,\nand at least 6 and max 15 characters";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                value: haveReferer,
                checkboxShape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(5)),
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(5)),
                checkColor: appLogoColor,
                activeColor: Colors.white,
                title: capText("I don't have sponsor", context),
                onChanged: (val) => setState(() {
                  haveReferer = !haveReferer;
                  if (!haveReferer) {
                    _sUserNameController.clear();
                  } else {
                    _sUserNameController.text =
                        sl.get<AuthProvider>().default_referral_id ?? '';
                  }
                  // if (_pUserNameController.text.isEmpty) {
                  //   _pUserNameController.text = _sUserNameController.text;
                  // }
                }),
                contentPadding: const EdgeInsets.all(0),
              ),
              height20(height * 0.01),

              //placement id
              /*
              fieldTitle('Placement Id'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _pUserNameController,
                      enabled: true,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: 'Placement Id'),
                      onEditingComplete: () => primaryFocus?.unfocus(),
                      validator: (val) {
                        if (val != null &&
                            val.length > 0 &&
                            !RegExp(r"^[a-zA-Z0-9]{6,15}$").hasMatch(val)) {
                          return "Must contain uppercase, lowercase and numeric letter,\nand at least 6 and max 15 characters";
                        } else if (checkRestrictedText(val ?? '')) {
                          return 'This input is restricted.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              height20(height * 0.01),
*/
              fieldTitle('Username'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _userNameController,
                      focusNode: _userNameFocus,
                      enabled: true,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Username'),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter username';
                        } else if (!RegExp(r"^[a-zA-Z0-9]{6,15}$")
                            .hasMatch(val)) {
                          return "Must contain uppercase, lowercase and numeric letter,\nand at least 6 and max 15 characters";
                        } else if (checkRestrictedText(val)) {
                          return 'This input is restricted.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              height20(height * 0.01),
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
                                controller: _firstNameController,
                                focusNode: _fNameFocus,
                                enabled: true,
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                    hintText: 'First Name'),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter first name';
                                  } else if (!RegExp(r"^[a-zA-Z]{2,15}$")
                                      .hasMatch(val)) {
                                    return "Must contain uppercase, lowercase,\nand at least 2 and max 15 characters";
                                  } else if (checkRestrictedText(val)) {
                                    return 'This input is restricted.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              height20(height * 0.01),
              //last name
              /*
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        fieldTitle('Last Name'),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                controller: _lastNameController,
                                focusNode: _lNameFocus,
                                enabled: true,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                decoration:
                                    InputDecoration(hintText: 'Last Name'),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter last name';
                                  } else if (!RegExp(r"^[a-zA-Z]{2,15}$")
                                      .hasMatch(val)) {
                                    return "Must contain uppercase, lowercase,\nand at least 2 and max 15 characters";
                                  } else if (checkRestrictedText(val)) {
                                    return 'This input is restricted.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        height20(height * 0.01),
                      
                      ],
                    ),
                  ),
                ],
              ),
              */
              fieldTitle('Password'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      enabled: true,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Password'),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your password';
                        } else if (val.length < 8 || val.length > 20) {
                          return 'Password should be at least 8 and max 20 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              height20(height * 0.01),
              //confirm password
              /*
              fieldTitle('Confirm Password'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      enabled: true,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: 'Confirm Password'),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm your password';
                        } else if (val.length < 8 || val.length > 20) {
                          return 'Password should be at least 8 and max 20 characters.';
                        } else if (_passwordController.text.isNotEmpty &&
                            val != _passwordController.text) {
                          return 'Confirm password mis-matched.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              height20(height * 0.01),
              */
              //country
              /*
              CompositedTransformTarget(
                link: this._layerLink,
                child: GestureDetector(
                  key: countryOverlayKey,
                  // onTap: _showOverLay,
                  child: Focus(
                    // focusNode: countryOverlayFocus,
                    child: Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      message:
                          'The country field is required to determine the user currency for his wallet balance throughout the application',
                      preferBelow: false,
                      verticalOffset: -30,
                      waitDuration: Duration(seconds: 3),
                      margin: EdgeInsets.only(left: 110, right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          fieldTitle('Country'),
                          width5(),
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.white70,
                                  shape: BoxShape.circle),
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.only(top: 2),
                              child:
                                  Icon(Icons.question_mark_rounded, size: 10))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _countryController,
                      enabled: true,
                      readOnly: true,
                      onTap: () {
                        showBottomSheet(
                            context: context,
                            backgroundColor: Colors.white10,
                            builder: (context) => ShowAppCountryPicker(
                                  callback: (country) {
                                    country != null
                                        ? _countryController.text =
                                            country.name ?? ''
                                        : _countryController.clear();
                                    setState(() => signUpCountry = country);
                                    Navigator.pop(context);
                                  },
                                ));
                      },
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: 'Select Country '),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please select your country code.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              height20(height * 0.01),
              */
              //phone
              /*
              fieldTitle('Mobile No.'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      enabled: true,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration:
                          InputDecoration(hintText: 'Mobile no. (Optional)'),
                    ),
                  ),
                ],
              ),
              height20(height * 0.01),
              */

              fieldTitle('Email'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocus,
                      enabled: true,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your email address.';
                        } else {
                          bool isValid = RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
                              .hasMatch(val);
                          if (!isValid) {
                            return 'Please enter a valid email address';
                          }
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: 'Email Id'),
                    ),
                  ),
                ],
              ),
              height20(height * 0.01),
              //terms and condition
              Row(
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(5)),
                    checkColor: appLogoColor,
                    activeColor: Colors.white,
                    onChanged: (val) =>
                        setState(() => acceptedTerms = !acceptedTerms),
                  ),
                  width10(),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(text: "I accept", children: [
                            TextSpan(
                                text: ' Terms & Conditions',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      launchTheLink(authProvider.term ?? ''),
                                style: const TextStyle(
                                    color: appLogoColor,
                                    fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' and'),
                            TextSpan(
                                text: ' Privacy Policy',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      launchTheLink(authProvider.privacy ?? ''),
                                style: const TextStyle(
                                    color: appLogoColor,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
              // disclaimer
              Row(
                children: [
                  Checkbox(
                    value: acceptedDisclaimer,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(5)),
                    checkColor: appLogoColor,
                    activeColor: Colors.white,
                    onChanged: (val) => setState(
                        () => acceptedDisclaimer = !acceptedDisclaimer),
                  ),
                  width10(),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(text: "I accept", children: [
                            TextSpan(
                                text: ' Disclaimer',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => launchTheLink(
                                      authProvider.cancellation_policy ?? ''),
                                style: const TextStyle(
                                    color: appLogoColor,
                                    fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' and'),
                            TextSpan(
                                text: ' Refund Policy',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => launchTheLink(
                                      authProvider.cancellation_policy ?? ''),
                                style: const TextStyle(
                                    color: appLogoColor,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ],
                  ))
                ],
              ),

              // above 18
              Row(
                children: [
                  Checkbox(
                    value: above18,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(5)),
                    checkColor: appLogoColor,
                    activeColor: Colors.white,
                    onChanged: (val) => setState(() => above18 = !above18),
                  ),
                  width10(),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                              text:
                                  "I am over 18 years old and I agree to the terms and conditions.",
                              children: []),
                        ),
                      ),
                    ],
                  ))
                ],
              ),

              //register button
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: Get.width / 2,
                            child: ElevatedButton.icon(
                              onPressed: acceptedTerms && acceptedDisclaimer
                                  ? () async {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        sl
                                            .get<AuthProvider>()
                                            .registration(RegisterModel(
                                              username: _userNameController.text
                                                  .trim(),
                                              fName: _firstNameController.text,
                                              lName: '',
                                              spassword:
                                                  _passwordController.text,
                                              confirm_password:
                                                  _confirmPasswordController
                                                      .text,
                                              phone: '',
                                              email: _emailController.text,
                                              sponser_username:
                                                  _sUserNameController.text,
                                              placement_username: '',
                                              country_code: '',
                                              device_id: '24wrr',
                                            ));
                                        // _formKey.currentState?.validate();
                                      }
                                    }
                                  : null,
                              icon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: titleLargeText('Register', context)),
                              style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              label: const Icon(Icons.arrow_forward,
                                  size: 22, weight: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (sl.get<AuthProvider>().companyInfo != null
                      //  &&
                      //     sl.get<AuthProvider>().companyInfo!.mobileIsSignup ==
                      //         '0'
                      )
                        Container(
                            color: Colors.transparent,
                            width: double.maxFinite,
                            height: 50)
                    ],
                  ),
                  if (sl.get<AuthProvider>().companyInfo != null
                  //  &&
                  //     sl.get<AuthProvider>().companyInfo!.mobileIsSignup == '0'
                  )
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.amber, size: 15),
                        width5(7),
                        capText('Registration process is temporary disabled.',
                            context,
                            color: Colors.grey[400])
                      ],
                    ),
                ],
              ),
              height30(),
            ],
          ),
        );
      },
    );
  }

  OverlayEntry? countryOverlay;
  final LayerLink _layerLink = LayerLink();
  GlobalKey countryOverlayKey = GlobalKey();
  FocusNode countryOverlayFocus = FocusNode();
  removeCountryOverlay() {
    countryOverlay?.remove();
    countryOverlay = null;
  }

  _showOverLay() async {
    RenderBox? renderBox =
        countryOverlayKey.currentContext!.findRenderObject() as RenderBox?;
    Offset offset = renderBox!.localToGlobal(Offset.zero);
    OverlayState? overlayState = Overlay.of(context);
    var size = renderBox.size;

    // primaryFocus?.requestFocus( countryOverlayFocus);
    // print('offset is $offset');
    countryOverlay?.remove();
    countryOverlay = null;
    countryOverlay = OverlayEntry(
        builder: (context) => Positioned(
              left: offset.dx + 120,
              top: offset.dy + 120,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: Offset(size.width + 10, -15.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white70),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.red,
                        width: 200,
                      ),
                    ],
                  ),
                ),
              ),
            ));
    animationController!.addListener(() {
      overlayState.setState(() {});
    });
    animationController!.forward();
    overlayState.insert(countryOverlay!);
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

  Column buildHeader(double height, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // color: Colors.red,
          child: assetImages(
            Assets.appWebLogoWhite,
            width: double.maxFinite,
            height: height * 0.1,
            fit: BoxFit.contain,
          ),
        ),
        // height50(height * 0.02),
      ],
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path()
      ..addOval(Rect.fromPoints(const Offset(0, 0), const Offset(60, 60)))
      ..addOval(Rect.fromLTWH(0, size.height - 50, 100, 50))
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: 20))
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    throw false;
  }
}
