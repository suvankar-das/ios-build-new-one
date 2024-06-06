import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:native_in_flutter/api/api.dart';
import 'package:native_in_flutter/common/color_extension.dart';
import 'package:native_in_flutter/common_widgets/rounded_button.dart';
import 'package:native_in_flutter/common_widgets/rounded_text_field.dart';
import 'package:native_in_flutter/models/User.dart';
import 'package:native_in_flutter/splashScreen.dart';
import 'package:native_in_flutter/view/forgot_password/forgot_password_view.dart';
import 'package:native_in_flutter/view/main_tab/main_tab_bar_view.dart';
import 'package:readsms/readsms.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  final _plugin = Readsms();
  TextEditingController txtOtp = TextEditingController();
  bool isEmailSignupAndLogin = false;
  bool isSignIn = false;
  bool isShowOtpContainer = false;
  bool _isLoading = false;
  String countryCode = "+91";
  bool hasOtpSend = false;

  @override
  void initState() {
    super.initState();
    getPermission().then((value) {
      if (value) {
        _plugin.read();
        _plugin.smsStream.listen((event) {
          // String otpCode = event.body.substring(0, 6);
          RegExp regExp = RegExp(r'\b\d{4}\b');
          Match? match = regExp.firstMatch(event.body);
          String? verificationCode = match?.group(0);
          setState(() {
            txtOtp.text = verificationCode ?? '';
            //wait for 3 sec and then press _validateOtp submit
            var operation = isSignIn ? 'login' : 'signup';
            Future.delayed(Duration(seconds: 3), () {
              _performOperation(operation);
            });
          });
        });
      }
    });
  }

  Future<bool> getPermission() async {
    if (await Permission.sms.status == PermissionStatus.granted) {
      return true;
    } else {
      if (await Permission.sms.request() == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ApplicationColor.bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ApplicationColor.primaryColor,
        onPressed: () {
          ApplicationColor.themeModeDark = !ApplicationColor.themeModeDark;
          if (mounted) {
            setState(() {});
          }
        },
        child: Icon(
          ApplicationColor.themeModeDark ? Icons.light_mode : Icons.dark_mode,
          color: ApplicationColor.text,
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            width: media.width,
            height: media.width,
            child: ClipRect(
              child: Transform.scale(
                scale: 1.3,
                child: Image.asset(
                  "assets/images/login_top.png",
                  width: media.width,
                  height: media.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            width: media.width,
            height: media.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ApplicationColor.bgColor.withOpacity(0),
                  ApplicationColor.bgColor.withOpacity(0),
                  ApplicationColor.bgColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: media.width * 0.12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: media.width,
                    height: media.width * 0.75,
                    alignment: const Alignment(0, 0.5),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: ApplicationColor.themeModeDark
                            ? Colors.transparent
                            : ApplicationColor.bgColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: ApplicationColor.themeModeDark
                            ? null
                            : const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                )
                              ],
                      ),
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: media.width * 0.5,
                        height: media.width * 0.5,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  if (!isEmailSignupAndLogin)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RoundedTextField(
                                title: "Phone Number",
                                hintText: "",
                                keyboardType: TextInputType.phone,
                                controller: txtMobile,
                                left: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    countryCode,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (isShowOtpContainer)
                          RoundedTextField(
                            title: "OTP",
                            hintText: "",
                            keyboardType: TextInputType.number,
                            controller: txtOtp,
                          ),
                      ],
                    ),
                  if (isEmailSignupAndLogin) ...[
                    RoundedTextField(
                      title: "Email",
                      keyboardType: TextInputType.emailAddress,
                      controller: txtEmail,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RoundedTextField(
                      title: "Password",
                      obscureText: true,
                      controller: txtPassword,
                      right: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPassword(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot ?",
                          style: TextStyle(
                            color: ApplicationColor.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 30,
                  ),
                  RoundedButton(
                    onPressed: () {
                      _validateAndProceed();
                    },
                    title: isSignIn ? "Sign In" : "Sign Up",
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSignIn = !isSignIn;
                        isShowOtpContainer = false;
                        hasOtpSend = false;
                        txtOtp.text = "";
                      });
                    },
                    child: Text(
                      isSignIn
                          ? "New user? Sign Up instead"
                          : "Already registered? Sign In instead",
                      style: TextStyle(
                        color: ApplicationColor.subText,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: ApplicationColor.subText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Social Logins",
                          style: TextStyle(
                            color: ApplicationColor.subText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: ApplicationColor.subText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isEmailSignupAndLogin = !isEmailSignupAndLogin;
                          });
                        },
                        icon: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.yellow,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            !isEmailSignupAndLogin
                                ? "assets/images/email.png"
                                : "assets/images/mobile.png",
                            width: 45,
                            height: 45,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.yellow,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            "assets/images/facebook.png",
                            width: 45,
                            height: 45,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.yellow,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            "assets/images/google.png",
                            width: 45,
                            height: 45,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.yellow,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            "assets/images/apple.png",
                            width: 45,
                            height: 45,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _validateAndProceed() {
    setState(() {
      _isLoading = true;
    });

    if (isSignIn) {
      if (!isEmailSignupAndLogin) {
        if (txtMobile.text.isEmpty) {
          _showSnackBar("Please enter your phone number");
        } else {
          _signIn();
        }
      } else {
        if (txtEmail.text.isEmpty) {
          _showSnackBar("Please enter your email");
        } else if (txtPassword.text.isEmpty) {
          _showSnackBar("Please enter your password");
        } else {
          _signIn();
        }
      }
    } else {
      if (isEmailSignupAndLogin) {
        if (txtEmail.text.isEmpty) {
          _showSnackBar("Please enter your email");
        } else if (txtPassword.text.isEmpty) {
          _showSnackBar("Please enter your password");
        } else {
          _signUp();
        }
      } else {
        if (txtMobile.text.isEmpty) {
          _showSnackBar("Please enter your phone number");
        } else {
          _signUp();
        }
      }
    }
  }

  Future<void> _signIn() async {
    await _performOperation('login');
  }

  Future<void> _signUp() async {
    await _performOperation('signup');
  }

  Future<void> _performOperation(String operationType) async {
    try {
      Map<String, dynamic> userData = _prepareUserData();
      Map<String, dynamic> otpData = _prepareOtpData();
      String registerType = isEmailSignupAndLogin ? 'email' : 'phone';

      var response;
      if (registerType == 'phone') {
        response = hasOtpSend
            ? await Api().verifyOtp(otpData, operationType)
            : await Api()
                .userDataOperation(userData, registerType, operationType);
      } else {
        response = await Api()
            .userDataOperation(userData, registerType, operationType);
      }

      if (response.statusCode == 200) {
        if (registerType == 'phone') {
          if (!hasOtpSend) {
            setState(() {
              isShowOtpContainer = true;
              hasOtpSend = true;
              txtOtp.text = "";
            });
          } else {
            // handle for mobile
            var jsonResponse = jsonDecode(response.body);
            User user = User.fromJson(jsonResponse['result']['profile']);
            var box = await Hive.openBox<User>('userBox');
            await box.put('user', user);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          }
        } else {
          var jsonResponse = jsonDecode(response.body);
          // Handle success for email
          User user = User.fromJson(jsonResponse['result']['profile']);
          var box = await Hive.openBox<User>('userBox');
          await box.put('user', user);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        }
      } else {
        var jsonResponse = jsonDecode(response.body);
        _showSnackBar('Operation failed: ${jsonResponse['message']}');
      }
    } catch (e) {
      _showSnackBar("Operation failed: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _prepareUserData() {
    if (isEmailSignupAndLogin) {
      return {
        "username": txtEmail.text.trim(),
        "password": txtPassword.text.trim(),
      };
    } else {
      String countryCodeWithoutPlus = countryCode.substring(1);
      return {
        'username': countryCodeWithoutPlus + txtMobile.text.trim(),
      };
    }
  }

  Map<String, dynamic> _prepareOtpData() {
    String countryCodeWithoutPlus = countryCode.substring(1);
    return {
      'username': countryCodeWithoutPlus + txtMobile.text.trim(),
      'otp': txtOtp.text.trim(),
    };
  }
}
