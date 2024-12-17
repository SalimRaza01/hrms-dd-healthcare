// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/screens/home/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key});

  @override
  State<LoginOtp> createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  TextEditingController pinController = TextEditingController();
  late final FocusNode focusNode;
  bool showerror = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    Color? focusedBorderColor =     Color(0xFFA787FF);
    Color? fillColor = Color.fromARGB(0, 68, 93, 252);
    Color? borderColor = Color.fromRGBO(172, 172, 172, 1);
    Color? errorfocusedBorderColor = Colors.redAccent;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: Color.fromARGB(255, 49, 49, 49),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:  AppColor.bgColor,
      // ignore: avoid_unnecessary_containers
      body: Stack(
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
            heightFactor: height * .08,
            child: Stack(
              clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: height * 0.5,
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
                            height: 25,
                          ),
                          Column(
                            children: [
                              Text(
                                'Sign in',
                                style: TextStyle(
                                    fontSize: height * 0.035,
                                                  color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Sign in code has been sent to +91 7272092415, check your inbox to continue the sign in process.',
                                style: TextStyle(
                                    fontSize: height * 0.017,
                                              color: AppColor.mainTextColor2,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Pinput(
                              controller: pinController,

                              focusNode: focusNode,
                              defaultPinTheme: defaultPinTheme,

                              separatorBuilder: (index) =>
                                  const SizedBox(width: 8),
                              hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                              onCompleted: (pin) async {},
                              onChanged: (value) {
                                debugPrint('onChanged: $value');
                              },
                              cursor: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 9),
                                    width: 22,
                                    height: 1,
                                    color: focusedBorderColor,
                                  ),
                                ],
                              ),
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: showerror
                                          ? errorfocusedBorderColor
                                          : focusedBorderColor),
                                ),
                              ),
                              submittedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                      color: showerror
                                          ? errorfocusedBorderColor
                                          : focusedBorderColor),
                                ),
                              ),
                              // errorPinTheme: showerror ? defaultPinTheme.copyBorderWith(
                              //   border: Border.all(color: Colors.redAccent),
                              // ) : null
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Haven't received OTP? ",
                                style: TextStyle(
                                    fontSize: height * 0.017,
                                                   color: AppColor.mainTextColor2,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                ' Resend OTP.',
                                style: TextStyle(
                                    color:     AppColor.secondaryThemeColor2,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          InkWell(
                
                                         onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> BottomNavigation()));
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
                                // color: Color.fromARGB(255, 38, 56, 255),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 52, vertical: 12),
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
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
                  Positioned(
                    top: -45,
                    child: Image.asset(
                      'assets/image/OTPLOGO.png',
                      height: height * 0.13,
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
