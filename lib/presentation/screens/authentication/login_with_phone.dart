

import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/screens/authentication/login_otp.dart';
import 'package:flutter/material.dart';

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({super.key});

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.bgColor,
 
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Image.asset(
              'assets/image/DDLOGO.png',
              height: height * 0.07,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.6,
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
                    SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        Text(
                          'Sign in Phone',
                          style: TextStyle(
                              fontSize: height * 0.035,                  color: AppColor.mainTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Sign in to my account',
                          style: TextStyle(
                              fontSize: height * 0.02,
                                          color: AppColor.mainTextColor2,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.07,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginOtp()));
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
                           Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                      
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                width: 1,
                                color: AppColor.primaryThemeColor,)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: AppColor.primaryThemeColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Sign in with Username',
                                style: TextStyle(
                                    color: AppColor.primaryThemeColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
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
