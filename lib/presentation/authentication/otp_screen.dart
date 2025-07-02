import 'dart:async';
import '../../core/api/api.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

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
    remainingTime = 59;
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
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
    Color focusedBorderColor = Colors.white;
    Color fillColor = Color.fromARGB(0, 68, 93, 252);
    Color borderColor = const Color.fromARGB(255, 173, 173, 173);
    Color errorfocusedBorderColor = Colors.redAccent;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
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
                    "OTP Verification",
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
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: height * 0.018,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'OTP has been sent to '),
                        TextSpan(
                            text: widget.emailController,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ', check your inbox.'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
                Pinput(
                  controller: pinController,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) async {
                    await verifyPasswordOTP(context, pin, widget.emailController);
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
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: showerror
                            ? errorfocusedBorderColor
                            : focusedBorderColor,
                      ),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: showerror
                            ? errorfocusedBorderColor
                            : focusedBorderColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      remainingTime > 9 ? "00:$remainingTime" : "00:0$remainingTime",
                      style: TextStyle(
                        fontSize: height * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Haven't received OTP? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    InkWell(
                      onTap: remainingTime == 0
                          ? () async {
                              await sendPasswordOTP(
                                  context, widget.emailController, '');
                              await startResendTimer();
                            }
                          : null,
                      child: Text(
                        'Resend OTP.',
                        style: TextStyle(
                          color: remainingTime == 0
                              ? Colors.greenAccent
                              : Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: height * 0.03),
                InkWell(
                  onTap: () async {
                    await verifyPasswordOTP(context, pinController.text, widget.emailController);
                  },
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
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
    );
  }
}