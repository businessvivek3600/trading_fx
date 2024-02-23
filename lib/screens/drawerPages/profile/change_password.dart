import 'package:flutter/material.dart';
import 'package:mycarclub/providers/auth_provider.dart';
import '../../../sl_container.dart';
import '../../../utils/picture_utils.dart';

/// screen for changing password with current password and password and confirm password
/// add textfield for current password, password and confirm password
/// add button for changing password
/// use validator for checking password and confirm password and use a regex for password

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  var authProvider = sl.get<AuthProvider>();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  /// global key for form
  final _formKey = GlobalKey<FormState>();

  /// controller for current password
  final TextEditingController _currentPasswordController =
      TextEditingController();

  /// controller for password
  final TextEditingController _passwordController = TextEditingController();

  /// controller for confirm password
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// variable for password visibility
  bool _passwordVisible = false;

  /// variable for confirm password visibility
  bool _confirmPasswordVisible = false;

  /// variable for current password visibility
  bool _currentPasswordVisible = false;

  /// variable for current password focus node
  final FocusNode _currentPasswordFocusNode = FocusNode();

  /// variable for password focus node
  final FocusNode _passwordFocusNode = FocusNode();

  /// variable for confirm password focus node
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  /// regex for password length  at least 6 characters long
  static RegExp passwordRegExp = RegExp(r'.{6,}');

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }

    /// check password does not match contain space
    if (value.contains(' ')) {
      return 'Password should not contain space';
    }

    ///length at least 6
    if (value.length < 6) {
      return 'Password should be at least 6 characters';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _confirmPasswordVisible = false;
    _currentPasswordVisible = false;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// function for changing password
  void _changePassword() async {
    FocusScope.of(context).unfocus();
    _isLoading.value = true;

    if (!_formKey.currentState!.validate()) {
      setState(() {});
      _isLoading.value = false;
      return;
    }
    setState(() => _formKey.currentState!.save());

    // const successSnackBar = SnackBar(
    //     content: Text('Password updated successfully! 🎉'),
    //     backgroundColor: Colors.green);
    await authProvider
        .changePassword(_currentPasswordController.text,
            _passwordController.text, _confirmPasswordController.text)
        .then((value) {
      FocusScope.of(context)
        ..nextFocus()
        ..unfocus();
      if (value) {
        // ScaffoldMessenger.of(context)
        //   ..hideCurrentSnackBar()
        //   ..showSnackBar(successSnackBar);

        if (mounted) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pop(context);
          });
        }
      }
    });
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (_, isLoading, c) {
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                    title: const Text('Change Password'), centerTitle: true),
                body: Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: userAppBgImageProvider(context),
                        fit: BoxFit.cover,
                        opacity: 1),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: <Widget>[
                        /// current password textfield
                        TextFormField(
                          enabled: !isLoading,
                          controller: _currentPasswordController,
                          focusNode: _currentPasswordFocusNode,
                          obscureText: !_currentPasswordVisible,
                          cursorColor: Colors.white,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _currentPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentPasswordVisible =
                                      !_currentPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter current password';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                        ),
                        const SizedBox(height: 16.0),

                        /// password textfield
                        TextFormField(
                          enabled: !isLoading,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: !_passwordVisible,
                          cursorColor: Colors.white,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            errorMaxLines: 3,
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator: validatePassword,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocusNode);
                          },
                        ),
                        const SizedBox(height: 16.0),

                        /// confirm password textfield
                        TextFormField(
                          enabled: !isLoading,
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: !_confirmPasswordVisible,
                          cursorColor: Colors.white,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _confirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Confirm password does not match';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            _changePassword();
                          },
                        ),
                        const SizedBox(height: 16.0),

                        /// button for changing password
                        ElevatedButton(
                          onPressed: _changePassword,
                          child: const Text('Change Password'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // LoaderWidget().visible(isLoading),
            ],
          );
        });
  }
}
