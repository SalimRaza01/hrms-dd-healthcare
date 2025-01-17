
import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool notfilledemail = false;
  bool notfilledpass = false;
  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return PopScope(

      onPopInvoked:(didPop) {
        SystemNavigator.pop();
  
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                AppColor.secondaryThemeColor2,
                AppColor.primaryThemeColor,
              ],
            ),
          ),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 160),
                child: Image.asset(
                  'assets/image/DDLOGO.png',
                  height: height * 0.07,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: height * 0.5,
                  width: width,
                  decoration: BoxDecoration(
                      color: AppColor.mainFGColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 5),
                        Column(
                          children: [
                            Text(
                              'Sign in',
                              style: TextStyle(
                                  fontSize: height * 0.035,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Sign in to my account',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: height * 0.08,
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  errorText: _emailErrorText,
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    final hasEmail = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    final hasSpace = RegExp(r'\s');
                                    final containsDomain =
                                        RegExp(r'@agvahealthtech.com$');
      
                                    if (value.isEmpty) {
                                      _emailErrorText = null;
                                    } else if (!hasEmail.hasMatch(value)) {
                                      _emailErrorText = 'Invalid Email';
                                    } else if (hasSpace.hasMatch(value)) {
                                      _emailErrorText =
                                          "Email can't contain spaces";
                                    } else if (!containsDomain.hasMatch(value)) {
                                      _emailErrorText = 'Invalid Email';
                                    } else {
                                      _emailErrorText = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              height: height * 0.07,
                              child: TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  errorText: notfilledpass
                                      ? 'Please enter password'
                                      : _passwordErrorText,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColor.mainTextColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    final hasSpace = RegExp(r'\s');
                                    if (value.isEmpty) {
                                      _passwordErrorText = null;
                                    } else if (hasSpace.hasMatch(value)) {
                                      _passwordErrorText =
                                          "Password can't cantain space";
                                    } else {
                                      _passwordErrorText = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            TextButton(
                                onPressed: () async {
                                  if (_emailController.text.isNotEmpty) {
                                    await sendPasswordOTP(
                                        context,
                                        _emailController.text.toString(),
                                        'LOGIN');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please Enter Email'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Text('Forgot Password ?'))
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            if (_emailController.text.isEmpty &&
                                _passwordController.text.isEmpty) {
                              setState(() {
                                _emailErrorText = "Please Enter Email";
                                _passwordErrorText = "Please Enter Password";
                              });
                            } else if (_emailController.text.isEmpty) {
                              setState(() {
                                _emailErrorText = "Please Enter Email";
                              });
                            } else if (_passwordController.text.isEmpty) {
                              setState(() {
                                _passwordErrorText = "Please Enter Password";
                              });
                            } else {
                              print('sign in button');
                              await authProvider.login(
                                  _emailController.text.toString(),
                                  _passwordController.text.toString(),
                                  context);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColor.primaryThemeColor,
                                    AppColor.secondaryThemeColor2,
                                  ]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 52, vertical: 12),
                              child: Center(
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                      color: AppColor.mainFGColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
