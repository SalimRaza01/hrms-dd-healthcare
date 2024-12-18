

import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/theme/app_colors.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Image.asset(
                  'assets/image/group.png',
                  height: height * 0.07,
                ),
              ),
            ),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  height: height * 0.06,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: height * 0.06,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: Icon(Icons.remove_red_eye),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                    TextButton(onPressed: () {}, child: Text('Forgot Password'))
                  ],
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                if (_emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  print('sign in button');
                  await authProvider.login(_emailController.text.toString(),
                      _passwordController.text.toString(), context);
                } else {
                  setState(() {
                    showError = true;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.mainThemeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 52, vertical: 12),
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: height * 0.02),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
