import 'dart:async';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/utils/default_logger.dart';
import '/utils/my_logger.dart';
import '/database/functions.dart';
import '/constants/assets_constants.dart';
import '/database/model/body/login_model.dart';
import '/myapp.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/screens/auth/forgot_password.dart';
import '/screens/auth/sign_up_screen.dart';
import '/sl_container.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/utils/toasts.dart';
import 'package:provider/provider.dart';

import '../../utils/color.dart';
import '../../utils/picture_utils.dart';
import '../dashboard/main_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String routeName = '/LoginScreen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController =
      TextEditingController(text: '');
  // TextEditingController(text: 'vivekmalik2466m');
  // TextEditingController(text: 'BIZZ3800074');
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  // TextEditingController(text: 'India@151');
  bool isFinished = false;
  bool showPassword = false;
  Map<String, dynamic> savedCredentials = {};
  @override
  void initState() {
    sl.get<AuthProvider>().getSignUpInitialData();
    super.initState();
    _loadSavedCredentials();
    OverlayState? overlayState = Overlay.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate(context);
    });
    _focusNode.addListener(() {
      warningLog('Has focus: ${_focusNode.hasFocus}', 'LoginScreen');
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlay();
        if (_overlayEntry != null) overlayState.insert(_overlayEntry!);
      } else {
        if (_overlayEntry != null) {
          _overlayEntry?.remove();
        }
      }
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Load saved credentials
  Future<void> _loadSavedCredentials() async =>
      savedCredentials = await sl.get<AuthProvider>().getSavedCredentials();

  Future<void> saveCredentials() async => await sl
      .get<AuthProvider>()
      .saveCredentials(_userNameController.text, _passwordController.text);

  @override
  Widget build(BuildContext context) {
    // logger.e('LoginScreen', tag: 'LoginScreen', error: 'error');
    // checkForUpdate(context);
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Center(
        child: AutofillGroup(
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              height: height,
              width: double.maxFinite,
              color: mainColor,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 350,
                              // constraints: BoxConstraints(maxWidth: 500),
                              child: Form(
                                key: _formKey,
                                child: AutofillGroup(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      height100(height * 0.1),
                                      buildHeader(height, context),
                                      height100(height * 0.05),
                                      buildForm(height),
                                      height10(),
                                      buildLoginButton2(context),
                                      height10(),
                                      height10(),
                                      height10(),
                                      height10(),
                                      buildSignUpButton(),
                                      // height20(height * 0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column buildLoginButton(BuildContext context) {
    bool isLoginDisabled = sl.get<AuthProvider>().companyInfo != null;
    //  &&
    //     sl.get<AuthProvider>().companyInfo!.mobile == '0';
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _login(context),
              // label: !isLoginDisabled
              //     ? loaderWidget(radius: 8)
              //     : Icon(Icons.arrow_forward_rounded,
              //         color: Colors.white, size: 20),
              child: assetImages(Assets.loginToMWC, width: 250),
              // child: titleLargeText(
              //   'Login',
              //   context,
              //   color: Colors.white,
              //   useGradient: false,
              // ),
            ),
            // buildLoginButton2(context),
            if (isLoginDisabled)
              Container(
                  color: Colors.transparent,
                  width: double.maxFinite,
                  height: 50)
          ],
        ),
        height10(),
        if (isLoginDisabled)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 15),
              width5(7),
              capText('Login process is temporary disabled.', context,
                  color: Colors.grey[400])
            ],
          )
      ],
    );
  }

  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  GlobalKey globalKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry _createOverlay() {
    _loadSavedCredentials();
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    print('renderBox ${renderBox.size}');
    print('renderBox ${renderBox.localToGlobal(Offset.zero)}');
    print('renderBox ${renderBox.localToGlobal(Offset.zero).dy}');
    print('Saved Credentials $savedCredentials');
    var size = renderBox.size;
    return OverlayEntry(
        builder: (context) => Positioned(
              width: _layerLink.leaderSize?.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0.0, 50.0),
                child: BuildAutoFillCredentialsContainer(
                    savedCredentials: savedCredentials,
                    onTap: (Map<String, dynamic>? val) {
                      if (val != null) {
                        _userNameController.text = val.keys.first;
                        _passwordController.text = val.values.first;
                      }
                      primaryFocus?.unfocus();
                    }),
              ),
            ));
  }

  ActionSlider buildLoginButton2(BuildContext context) {
    double iconSize = 40;
    return ActionSlider.standard(
      sliderBehavior: SliderBehavior.stretch,
      rolling: true,
      height: iconSize + 10,
      backgroundColor: Colors.white,
      toggleColor: appLogoColor.withOpacity(0.8),
      iconAlignment: Alignment.center,
      loadingIcon: SizedBox(
          width: iconSize,
          child: const Center(
              child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.0, color: Colors.white)))),
      successIcon: SizedBox(
          width: iconSize,
          child: const Center(
              child: Icon(Icons.check_rounded, color: Colors.white))),
      failureIcon: SizedBox(
          width: iconSize,
          child: const Center(
              child: Icon(Icons.warning_amber_rounded, color: Colors.red))),
      icon: SizedBox(
          width: iconSize,
          child: const Center(
              child:
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white))),
      action: (controller) async {
        if (_formKey.currentState?.validate() ?? false) {
          controller.loading(); //starts loading animation
          //--- trigger Password Save
          TextInput.finishAutofillContext();
          try {
            await sl
                .get<AuthProvider>()
                .login(LoginModel(
                  username: _userNameController.text,
                  password: _passwordController.text,
                  device_id: '',
                ))
                .then((value) async {
              if (value) {
                sl.get<DashBoardProvider>().getCustomerDashboard();
                controller.success();
                Future.delayed(const Duration(milliseconds: 100), () {
                  controller.reset();
                  Get.offAll(MainPage(
                    loginModel: LoginModel(
                      username: _userNameController.text,
                      password: _passwordController.text,
                      device_id: '',
                    ),
                  ));
                });
              } else {
                controller.failure();
                await Future.delayed(const Duration(seconds: 1));
                controller.reset();
              }
            });
          } catch (e) {
            Toasts.showErrorNormalToast('Something went wrong!');
            controller.failure();
            await Future.delayed(const Duration(seconds: 1));
            controller.reset();
          }
          //starts success animation
          // await Future.delayed(const Duration(seconds: 1));
          // controller.reset(); //resets the slider
        }
      },
      child: bodyLargeText('SWIPE TO LOGIN', context,
          color: Colors.black, useGradient: false),
    );
  }

  Row buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(text: "Don't have an account? ", children: [
            TextSpan(
                text: 'Sign Up',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.to(const SignUpScreen()),
                style: const TextStyle(
                    color: appLogoColor, fontWeight: FontWeight.bold)),
          ]),
        ),
      ],
    );
  }

  Widget buildForm(double height) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            titleLargeText('Login', context, fontSize: 32),
            height5(height * 0.01),
            capText('Please sign in to continue.', context,
                fontSize: 15,
                color: Colors.white54,
                fontWeight: FontWeight.bold),
            height20(height * 0.05),
            Row(
              children: <Widget>[
                Expanded(
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: TextFormField(
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.name,
                        AutofillHints.email,
                      ],
                      focusNode: _focusNode,
                      controller: _userNameController,
                      enabled: true,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Username'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            height10(height * 0.02),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    autofillHints: const [AutofillHints.password],
                    enabled: true,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    obscureText: !showPassword,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: GestureDetector(
                            onTap: () {
                              primaryFocus?.unfocus();
                              setState(() => showPassword = !showPassword);
                            },
                            child: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off_rounded,
                              color: Colors.white,
                            ))),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onFieldSubmitted: (val) => _login(context),
                  ),
                ),
              ],
            ),
            height20(height * 0.01),
            // buildCaptcha(),
            // height20(height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => MyApp.navigatorKey.currentState
                      ?.pushNamed(ForgotPasswordScreen.routeName),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: capText('Forgot Password?', context,
                        color: appLogoColor),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Column buildHeader(double height, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: assetImages(
            Assets.appWebLogoWhite,
            width: double.maxFinite,
            height: height * 0.1,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  void _login(BuildContext context) async {
    primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      //--- trigger Password Save
      TextInput.finishAutofillContext();
      try {
        await sl
            .get<AuthProvider>()
            .login(LoginModel(
              username: _userNameController.text,
              password: _passwordController.text,
              device_id: '',
            ))
            .then((value) {
          if (value) {
            sl.get<DashBoardProvider>().getCustomerDashboard();
            // Future.delayed(
            //     const Duration(seconds: 3),
            //     () => Toasts.showSuccessNormalToast(
            //         'You have logged in Successfully',
            //         title:
            //             'Welcome ${sl.get<AuthProvider>().userData.customerName ?? ''}'));
            Future.delayed(
                const Duration(milliseconds: 000),
                () => Get.offAll(MainPage(
                      loginModel: LoginModel(
                          username: _userNameController.text.trim(),
                          password: _passwordController.text.trim(),
                          device_id: ''),
                    )));
          }
        });
      } catch (e) {
        Get.back();
        Toasts.showErrorNormalToast('Something went wrong!');
      }
    }
  }
}

class BuildAutoFillCredentialsContainer extends StatefulWidget {
  const BuildAutoFillCredentialsContainer(
      {super.key, required this.savedCredentials, required this.onTap});

  final Map<String, dynamic> savedCredentials;
  final Function(Map<String, dynamic>?) onTap;

  @override
  State<BuildAutoFillCredentialsContainer> createState() =>
      _BuildAutoFillCredentialsContainerState();
}

class _BuildAutoFillCredentialsContainerState
    extends State<BuildAutoFillCredentialsContainer> {
  Map<String, dynamic> savedCredentials = {};
  @override
  void initState() {
    super.initState();
    setState(() => savedCredentials = widget.savedCredentials);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.savedCredentials.entries.length > 2
          ? 200
          : widget.savedCredentials.entries.length * 70.0,
      child: Material(
        elevation: 2.0,
        type: MaterialType.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        // color: Color.fromARGB(255, 43, 77, 87),
        color: bColor(1),
        shadowColor: Colors.white,

        child: ListView(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20, vertical: 5),
          children: [
            ...savedCredentials.entries.map(
              (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                      backgroundColor: appLogoColor,
                      child: Icon(Icons.person, color: Colors.white)),
                  title: titleLargeText(e.key, context,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: capText(
                      e.value.toString().split('').map((e) => '*').join(''),
                      context,
                      style: const TextStyle(color: Colors.white70)),
                  onTap: () => widget.onTap({e.key: e.value}),
                  trailing: TextButton(
                    child: bodyMedText('Remove', context,
                        color: CupertinoColors.link),
                    onPressed: () async {
                      //show alert dialog to confirm
                      showDialog(
                          context: context,
                          barrierColor: Colors.white.withOpacity(0.1),
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              backgroundColor: Colors.black87,
                              elevation: 10,
                              title: titleLargeText(
                                  'Remove Credentials', context,
                                  useGradient: true),
                              content: capText(
                                  'Are you sure you want to remove this credentials?',
                                  context),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: capText('Cancel', context)),
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await sl
                                          .get<AuthProvider>()
                                          .removeCredentials(e.key)
                                          .then((value) => setState(() =>
                                              savedCredentials =
                                                  widget.savedCredentials));
                                    },
                                    child: capText('Remove', context,
                                        color: Colors.red)),
                              ],
                            );
                          });

                      // await sl
                      //     .get<AuthProvider>()
                      //     .removeCredentials(e.key)
                      //     .then((value) => setState(() =>
                      //         savedCredentials = widget.savedCredentials));
                    },
                  )),
            ),
            if (widget.savedCredentials.entries.length > 2) height100()
          ],
        ),
      ),
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
