import 'package:flutter/material.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/screens/bottom_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardItem> onboardingData = [
    _OnboardItem(
      image: 'assets/image/onboard_calendar.png',
      title: 'Attendance Monitoring',
      description:
          'View daily, weekly, and monthly attendance at a glance. Never miss a day with detailed attendance history and insights.',
    ),
    _OnboardItem(
      image: 'assets/image/onboard_leave.png',
      title: 'Effortless Leave Management',
      description:
          'Apply, track, and manage your leaves with just a few taps. Stay updated on your leave balance and approval status in real-time.',
    ),
    _OnboardItem(
      image: 'assets/image/onboard_clock.png',
      title: 'One-Tap Clock In & Out',
      description:
          'Punch in from anywhere using your location and selfie. Get accurate work hours logged instantly and hassle-free.',
    ),
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
         Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNavigation()),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.primaryThemeColor,
              AppColor.secondaryThemeColor2,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
               Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNavigation()),
    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(onboardingData[index]);
                  },
                ),
              ),
              _buildDotIndicator(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _nextPage,
                  child: Text(
                    "NEXT",
                    style: TextStyle(
                        color: AppColor.mainThemeColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(item.image, height: 280),
        const SizedBox(height: 40),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(onboardingData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentIndex == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _OnboardItem {
  final String image;
  final String title;
  final String description;

  const _OnboardItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
