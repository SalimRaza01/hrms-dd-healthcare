import 'dart:async';

import 'package:hrms/core/api/api.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';

class OTPScren extends StatefulWidget {
  final String emailController;
  const OTPScren(this.emailController);

  @override
  State<OTPScren> createState() => _OTPScrenState();
}

class _OTPScrenState extends State<OTPScren> {
  late String emailController;
  TextEditingController pinController = TextEditingController();
  late final FocusNode focusNode;
  bool showerror = false;
  bool resendOtp = false;
  late Timer _resendTimer;
  int remainingTime = 59;

  @override
  void initState() {
    super.initState();
    startResendTimer();
    focusNode = FocusNode();
  }

  startResendTimer() {
    print('time is running');
    remainingTime = 59;
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      print('time is running 1');
      setState(() {
        if (remainingTime > 0) {
          print('time is running 2');
          remainingTime--;
        } else if (remainingTime == 0) {
          resendOtp = true;
          _resendTimer.cancel();
          timer.cancel();
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? focusedBorderColor = Color(0xFFA787FF);
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
      backgroundColor: AppColor.bgColor,
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
                'assets/image/DDHRMS.png',
                height: height * 0.11,
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
                          color: AppColor.mainFGColor,
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
                                  remainingTime > 9
                                      ? "00:$remainingTime"
                                      : "00:0$remainingTime",
                                  style: TextStyle(
                                      fontSize: height * 0.035,
                                      color: AppColor.mainTextColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                // Text(
                                //   'OTP',
                                //   style: TextStyle(
                                //       fontSize: height * 0.035,
                                //       color: AppColor.mainTextColor,
                                //       fontWeight: FontWeight.bold),
                                // ),
                                SizedBox(
                                  height: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: height * 0.0165,
                                      color: AppColor.mainTextColor2,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: 'OTP has been sent to '),
                                      TextSpan(
                                          text: widget.emailController,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              ', check your inbox to continue the process.'),
                                    ],
                                  ),
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
                                onCompleted: (pin) async {
                                  await verifyPasswordOTP(
                                      context, pin, widget.emailController);
                                },
                                // onChanged: (value) {
                                //   debugPrint('onChanged: $value');
                                // },
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
                                InkWell(
                                  onTap: remainingTime == 0 ? () async {
                                    await sendPasswordOTP(
                                        context, widget.emailController, '');
                                          await startResendTimer();
                                  } : null,
                                  child: Text(
                                    ' Resend OTP.',
                                    style: TextStyle(
                                        color: remainingTime == 0 ? AppColor.secondaryThemeColor2 : Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () async {
                                await verifyPasswordOTP(
                                    context,
                                    pinController.text.toString(),
                                    widget.emailController);
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
                                      'Submit',
                                      style: TextStyle(
                                          color: AppColor.mainFGColor,
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
      ),
    );
  }
}
