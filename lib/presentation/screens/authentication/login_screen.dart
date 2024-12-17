// ignore_for_file: prefer_const_constructors

import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/screens/authentication/login_with_phone.dart';
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
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Image.asset(
              'assets/image/DDLOGO.png',
              height: height * 0.07,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.7,
              width: width,
              decoration: BoxDecoration(
                  color: Colors.white,
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
                      children: [
                        SizedBox(
                          height: height * 0.07,
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: height * 0.07,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: Icon(Icons.remove_red_eye),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(value: false, onChanged: null),
                                Text('Remember Me')
                              ],
                            ),
                            TextButton(
                                onPressed: () {},
                                child: Text('Forgot Password'))
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                          if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                            print('sign in button');
                            await authProvider.login(
                                _emailController.text.toString(), _passwordController.text.toString(), context);
                     
                          } else {
                            setState(() {
                              showError = true;
                            });
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey[350],
                    ),
                    InkWell(
                      onTap: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginWithPhone()),
                          );
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1,
                              color: AppColor.primaryThemeColor,
                            )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                color: AppColor.primaryThemeColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Sign in with phone',
                                style: TextStyle(
                                    color: AppColor.primaryThemeColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
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
    );
  }
}
