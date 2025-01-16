import 'dart:io';

import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/services.dart';
import 'package:hrms/presentation/authentication/login_screen.dart';
import 'package:flutter/material.dart';

final pages = [
  PageData(
    imagePath: 'assets/image/OnBoarding1.png',
    title: "Welcome",
    bgColor: Color(0xFF795FFC),
    textColor: Colors.white,
  ),
  PageData(
    imagePath: 'assets/image/OnBoarding2.png',
    title: "Easily log your work hours",
    bgColor: Color.fromARGB(255, 255, 255, 255),
    textColor: Color(0xFF795FFC),
  ),
  PageData(
      imagePath: 'assets/image/OnBoarding3.png',
      title: "View and track your attendance records",
      bgColor: Color(0xFF795FFC),
      textColor: Colors.white),
  PageData(
    imagePath: 'assets/image/OnBoarding4.png',
    title: "Create and manage tasks to stay organized",
    bgColor: Color.fromARGB(255, 255, 255, 255),
    textColor: Color(0xFF795FFC),
  )
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

@override
  void initState() {
    // TODO: implement initState
    super.initState();
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(

      onPopInvoked:(didPop) {
        // SystemNavigator.pop();
        exit(0);
      },
      child: Scaffold(
        body: ConcentricPageView(
          duration: Duration(milliseconds: 800),
          colors: pages.map((p) => p.bgColor).toList(),
          radius: screenWidth * 0.1,
          nextButtonBuilder: (context) => Padding(
            padding: const EdgeInsets.only(left: 3), 
            child: Icon(
              Icons.navigate_next,
              size: screenWidth * 0.08,
            ),
          ),
          scaleFactor: 2,
          itemBuilder: (index) {
            final page = pages[index % pages.length];
      
            
            if (index == pages.length) {
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              });
              return SizedBox(); 
            } else {
              return SafeArea(
                child: _Page(page: page),
              );
            }
          },
        ),
      ),
    );
  }
}

class PageData {
  final String? title;
  final String? imagePath;
  final Color bgColor;
  final Color textColor;

  PageData({
    this.title,
    this.imagePath,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(20.0),
          child: Image.asset(
            page.imagePath!,
            height: screenHeight * 0.12,
          ),
        ),
        SizedBox(
          width: screenWidth / 1.5,
          child: Text(
            page.title ?? "",
            style: TextStyle(
                color: page.textColor,
                fontSize: screenHeight * 0.022,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
