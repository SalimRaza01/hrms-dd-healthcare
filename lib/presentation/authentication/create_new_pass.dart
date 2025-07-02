// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import '../../core/api/api.dart';

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

  final String _passwordPattern = r'^[A-Za-z0-9]{8,}\$';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordErrorVisible = false;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    final pattern = RegExp(r'^[A-Za-z0-9]{8,}$');
    if (!pattern.hasMatch(value)) {
      return 'Must be at least 8 characters (letters and digits only)';
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                    'Create New Password',
                    style: TextStyle(
                      fontSize: height * 0.032,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your new password must be different from previously used passwords.',
                    style: TextStyle(
                      fontSize: height * 0.017,
                      color: Colors.white70,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: passController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white70),
                          errorStyle: TextStyle(color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
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
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: confirmPassController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.white70),
                          errorStyle: TextStyle(color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
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
                          setState(() {
                            _isConfirmPasswordErrorVisible = error != null;
                          });
                          return error;
                        },
                        onChanged: (value) {
                          _formKey.currentState?.validate();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await createNewPass(
                          context, passController.text, widget.email);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
