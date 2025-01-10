// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/theme/app_colors.dart';

class CreateNewPassword extends StatefulWidget {
  final String email;
  const CreateNewPassword(this.email);

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  late String email;
  final _formKey = GlobalKey<FormState>();

  final String _passwordPattern = r'^[A-Za-z0-9]{8,}$'; 
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordErrorVisible = false;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (!RegExp(_passwordPattern).hasMatch(value)) {
      return 'Must be at least 8 characters, contains letter & digit';
    }
    return null;
  }


  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
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
              padding: const EdgeInsets.only(top: 200),
              child: Image.asset(
                'assets/image/DDLOGO.png',
                height: height * 0.07,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height * 0.45,
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
                            'Create New Password',
                            style: TextStyle(
                                fontSize: height * 0.025,
                                color: AppColor.mainTextColor,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your new password must be different from previously used passwords.',
                            style: TextStyle(
                              fontSize: height * 0.0165,
                              color: AppColor.mainTextColor2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
         
                            TextFormField(
                              controller: passController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
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
                              validator: validatePassword,
                              onChanged: (value) {
                      
                                setState(() {
                                  _formKey.currentState?.validate();
                                  // _isConfirmPasswordErrorVisible = false;
                                });
                              },
                            ),
                            SizedBox(height: 15),
                            
              
                            TextFormField(
                              controller: confirmPassController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
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
                              validator: (value) {
                                String? error = validateConfirmPassword(value);
                                if (error != null) {
                                  setState(() {
                                    _isConfirmPasswordErrorVisible = true;
                                  });
                                } else {
                                  setState(() {
                                    _isConfirmPasswordErrorVisible = false;
                                  });
                                }
                                return error;
                              },
                              onChanged: (value) {
                                _formKey.currentState?.validate();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Submit Button
                      InkWell(
                        onTap: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await createNewPass(context, passController.text, widget.email);
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
                                'SUBMIT',
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
    );
  }
}
