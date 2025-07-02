import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/api/api.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  final Box _authBox = Hive.box('authBox');
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _authBox.put('FreshInstall', false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      onPopInvoked: (didPop) {
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF7B9EB1),
                Color.fromARGB(255, 32, 52, 62),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: height * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                     Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter your email and password to log in",
                      style: TextStyle(
                        fontSize: height * 0.018,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  TextField(
                    style: TextStyle(
                      color: const Color.fromARGB(255, 201, 201, 201),
                    ),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 201, 201, 201),
                      ),
                      errorStyle: TextStyle(
                        color: const Color.fromARGB(255, 201, 201, 201),
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: const Color.fromARGB(255, 201, 201, 201),
                      ),
                      labelText: "Email/Employee Code",
                      errorText: _emailErrorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
onChanged: (value) {
  setState(() {
    bool isDigit = int.tryParse(value) != null;

    if (isDigit) {
      final employeeCode = RegExp(r'^\d{1,5}$');
      if (value.isEmpty) {
        _emailErrorText = 'Employee Code is required';
      } else if (!employeeCode.hasMatch(value)) {
        _emailErrorText = 'Invalid Employee Code';
      } else {
        _emailErrorText = null;
      }
    } else {
      final hasEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      final hasSpace = RegExp(r'\s');
      final containsDomain = RegExp(r'@agvahealthtech\.com$');

      if (value.isEmpty) {
        _emailErrorText = null;
      } else if (!hasEmail.hasMatch(value)) {
        _emailErrorText = 'Invalid Email';
      } else if (hasSpace.hasMatch(value)) {
        _emailErrorText = "Email can't contain spaces";
      } else if (!containsDomain.hasMatch(value)) {
        _emailErrorText = 'Email must belong to agvahealthtech.com';
      } else {
        _emailErrorText = null;
      }
    }
  });
}

                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    style: TextStyle(
                      color: const Color.fromARGB(255, 201, 201, 201),
                    ),
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 201, 201, 201),
                      ),
                      errorStyle: TextStyle(
                        color: const Color.fromARGB(255, 201, 201, 201),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: const Color.fromARGB(255, 201, 201, 201),
                      ),
                      labelText: "Password",
                      errorText: notfilledpass
                          ? 'Please enter password'
                          : _passwordErrorText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromARGB(255, 201, 201, 201),
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
                          _passwordErrorText = "Password can't contain space";
                        } else {
                          _passwordErrorText = null;
                        }
                      });
                    },
                  ),
                  SizedBox(height: height * 0.015),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (_emailController.text.isNotEmpty) {
                            await sendPasswordOTP(context,
                                _emailController.text.toString(), 'LOGIN');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please Enter Email'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 201, 201, 201),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: height * 0.015),
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
                        setState(() {
                          isloading = true;
                        });
                        await authProvider.login(
                          _emailController.text.toString(),
                          _passwordController.text.toString(),
                          context,
                        );
                        setState(() {
                          isloading = false;
                        });
                      }
                      Future.delayed(Duration(seconds: 4),(){
                                  setState(() {
                          isloading = false;
                        });
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 14),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: isloading
                          ? Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: Colors.blueGrey,
                                size: height * 0.03,
                              ),
                            )
                          : const Center(
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ),
                     SizedBox(height: height * 0.06),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
