import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/screens/onboarding/onboarding_page1.dart';
import 'package:ledger_book_flutter/screens/onboarding/onboarding_page2.dart';
import 'package:ledger_book_flutter/screens/onboarding/onboarding_page3.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller for the PageView
  final PageController _pageController = PageController();

  // Variable to check if the last page is reached
  bool _isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _isLastPage = index == 2;
          });
        },
        children: [
          // Add your onboarding pages here
          const OnboardingPage1(),
          const OnboardingPage2(),
          const OnboardingPage3(),
        ],
      ),
      bottomSheet: _isLastPage
          ? Container(
              height: 70,
              color: Colors.white,
              child: Center(
                child: TextButton(
                  onPressed: () async {
                    // Navigate to the dashboard or home screen
                    Navigator.pushReplacementNamed(context, '/dashboard');

                    // Save the onboarding completion status
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('onboarding_completed', true);
                  },
                  child: const Text('Get Started'),
                ),
              ),
            )
          : Container(
              height: 70,
              color: Colors.white,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: const Text('Next'),
                ),
              ),
            ),
    );
  }
}