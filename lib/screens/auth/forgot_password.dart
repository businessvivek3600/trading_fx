import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/theme.dart';
import '/constants/assets_constants.dart';
import '/myapp.dart';
import '/providers/auth_provider.dart';
import '/screens/auth/login_screen.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  static const String routeName = '/ForgotPasswordScreen';
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const NUM_BOXES = 6;
  final _boxControllers = <TextEditingController>[];
  final _boxFocusNodes = <FocusNode>[];
  List<String> _myVars = <String>[];
  final emailController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  final sendOtpFocus = FocusNode();
  final newPassFocus = FocusNode();
  final confirmPassFocus = FocusNode();
  final passFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();
  final newFormKey = GlobalKey<FormState>();
  final confFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < NUM_BOXES; i++) {
      final controller = TextEditingController();
      controller.addListener(() => _onTextChanged(i));
      _boxControllers.add(controller);
      _boxFocusNodes.add(FocusNode());
    }
  }

  void _onTextChanged(int index) {
    String value = _boxControllers[index].text;
    if (_myVars[index] == value) return;
    _myVars[index] = value;
    print('_myVars[index] ${_myVars[index]}');
    print(_myVars.join(''));
    if (value.isEmpty) {
      // request focus for the previous "box"
      primaryFocus?.previousFocus();
      FocusScope.of(context).previousFocus();
      return;
    }
    // request focus for the next "box"
    FocusScope.of(context).nextFocus();
  }

  @override
  void dispose() {
    sl.get<AuthProvider>().setOtpSent(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        primaryFocus?.unfocus();
      },
      child: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return WillPopScope(
            onWillPop: () async {
              bool willBack = false;
              if (provider.otpSent) {
                setState(() {
                  provider.setOtpSent(false);
                  _boxControllers.forEach((element) => element.clear());
                  newPassController.clear();
                  confirmPassController.clear();
                });
                willBack = false;
              } else {
                willBack = true;
              }
              return willBack;
            },
            child: Scaffold(
              body: Container(
                height: height,
                width: double.maxFinite,
                color: mainColor,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: assetImageProvider(provider.otpSent
                              ? Assets.forgotPass
                              : Assets.sendEmail),
                          fit: provider.otpSent
                              ? BoxFit.contain
                              : BoxFit.contain)),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 30,
                                  // color: Colors.red,
                                  child: Stack(
                                    children: [
                                      Center(
                                          child: titleLargeText(
                                              'Forgot Password', context,
                                              fontSize: 20)),
                                      buildBackButton(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!provider.otpSent) buildEmailField(provider),
                        if (provider.otpSent) buildPasswordField(provider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Expanded buildPasswordField(AuthProvider provider) {
    return Expanded(
      child: DraggableScrollableSheet(
          minChildSize: 0.6,
          maxChildSize: 0.6,
          initialChildSize: 0.6,
          builder: (context, controller) {
            return Form(
              key: passFormKey,
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        titleLargeText('Enter verification code', context,
                            color: Colors.black, fontSize: 20),
                      ],
                    ),
                    height20(),
                    Row(
                      children: [
                        ..._boxControllers.map((e) {
                          var i = _boxControllers.indexOf(e);
                          return Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: e,
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      if (e.text.isNotEmpty) {
                                        primaryFocus?.nextFocus();
                                      }
                                    },
                                    maxLength: 1,
                                    focusNode: _boxFocusNodes[i],
                                    style: GoogleFonts.ubuntu(
                                        textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    )),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val.isEmpty) {
                                          primaryFocus?.previousFocus();
                                        }
                                        if (val.isNotEmpty) {
                                          primaryFocus?.nextFocus();
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintStyle: GoogleFonts.ubuntu(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                      hintText: '#',
                                      counterText: "",
                                      contentPadding: EdgeInsets.only(left: 20),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                width5(),
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                    height20(),
                    bodyMedText('New Password', context, color: Colors.black),
                    height10(),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: newPassController,
                          focusNode: newPassFocus,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onEditingComplete: () {
                            passFormKey.currentState?.validate();
                            primaryFocus?.nextFocus();
                          },
                          style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87)),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            hintStyle: GoogleFonts.ubuntu(
                                textStyle: TextStyle(color: Colors.grey)),
                            hintText: 'ex:- 12345678',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(30)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(30)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(30)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'This field should not be empty';
                            } else {
                              if (val.length < 8) {
                                return 'Password must be at least 8 characters';
                              } else {
                                return null;
                              }
                            }
                          },
                        ))
                      ],
                    ),
                    height20(),
                    bodyMedText('Confirm Password', context,
                        color: Colors.black),
                    height10(),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          // key: confFormKey,
                          controller: confirmPassController,
                          focusNode: confirmPassFocus,
                          onEditingComplete: () {
                            passFormKey.currentState?.validate();
                            primaryFocus?.nextFocus();
                          },
                          style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87)),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            hintStyle: GoogleFonts.ubuntu(
                                textStyle: TextStyle(color: Colors.grey)),
                            hintText: 'ex:- 12345678',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(30)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(30)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(30)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'This field should not be empty';
                            } else {
                              if (val.length < 8) {
                                return 'Password must be at least 8 characters';
                              } else if (newPassController.text !=
                                  confirmPassController.text) {
                                return 'Password should match the new password';
                              } else {
                                return null;
                              }
                            }

                            return null;
                          },
                        ))
                      ],
                    ),
                    height20(),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () => provider.forgetPasswordSubmit(
                              email: emailController.text,
                              otp: _boxControllers
                                  .map((e) => e.text)
                                  .toList()
                                  .join(''),
                              newPass: newPassController.text,
                              confirmPass: confirmPassController.text),
                          child: bodyMedText('Verify & Submit', context),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ))
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: OutlinedButton(
                          onPressed: () => MyApp
                              .navigatorKey.currentState
                              ?.pushNamedAndRemoveUntil(
                                  LoginScreen.routeName, (route) => false),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: bodyMedText('Back to Login', context,
                                color: appLogoColor),
                          ),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ))
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget buildEmailField(AuthProvider provider) {
    return Expanded(
      child: Stack(
        children: [
          DraggableScrollableSheet(
              minChildSize: 0.5,
              maxChildSize: 0.5,
              initialChildSize: 0.5,
              builder: (context, controller) {
                return Form(
                  key: emailFormKey,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: ListView(
                      controller: controller,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            titleLargeText('Enter email address', context,
                                color: Colors.black, fontSize: 20),
                          ],
                        ),
                        height20(),
                        Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              controller: emailController,
                              onEditingComplete: () {
                                bool? validate =
                                    emailFormKey.currentState?.validate();
                                if (validate != null && validate) {
                                  primaryFocus?.nextFocus();
                                }
                              },
                              style: GoogleFonts.ubuntu(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87)),
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.email_outlined, size: 18),
                                hintStyle: GoogleFonts.ubuntu(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey)),
                                hintText: 'example@gmail.com',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(30)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(30)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(30)),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your email address';
                                } else {
                                  var regex = new RegExp(
                                      r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
                                  if (!regex.hasMatch(val)) {
                                    return 'Please enter a valid email address';
                                  } else {
                                    return null;
                                  }
                                }
                              },
                            ))
                          ],
                        ),
                        height20(),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: ElevatedButton(
                              focusNode: sendOtpFocus,
                              onPressed: () async {
                                primaryFocus?.unfocus();
                                bool? validate =
                                    emailFormKey.currentState?.validate();
                                if (validate != null && validate) {
                                  bool otpSent =
                                      await provider.getForgotPassEmailOtp(
                                          emailController.text);
                                  if (otpSent) {
                                    provider.setOtpSent(true);
                                  }
                                }
                              },
                              child: bodyMedText(
                                  'Send Verification Code', context),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ))
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: TextButton(
                              onPressed: () {
                                bool? validate =
                                    emailFormKey.currentState?.validate();
                                if (validate != null && validate) {
                                  setState(() {
                                    provider.setOtpSent(true);
                                    _boxControllers.forEach((element) {
                                      element.clear();
                                    });
                                    newPassController.clear();
                                    confirmPassController.clear();
                                  });
                                }
                              },
                              child: bodyMedText(
                                  'Already have an OTP?', context,
                                  color: Colors.grey),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          // assetImages(Assets.sendEmail)
        ],
      ),
    );
  }

  Widget buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          gradient: buildButtonGradient(),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: assetSvg(Assets.arrowBack, color: Colors.white),
        ),
      ),
    );
  }
}
