import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/screens/onboarding/onboarding_page1.dart';
import 'package:ledger_book_flutter/screens/onboarding/onboarding_page2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  // Custom page transitions
  void _animateToNextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Use theme background color
      body: Stack(
        children: [
          // PageView with custom physics
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _isLastPage = index == 1;
              });
            },
            children: const [
              OnboardingPage1(),
              OnboardingPage2(),
            ],
          ),

          // Skip button (only visible on first page)
          if (!_isLastPage)
            Positioned(
              top: 50,
              right: 24,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary.withOpacity(0.8), // Updated color
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onBackground.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Next/Get Started button
                SizedBox(
                  width: size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: _isLastPage
                        ? () async {
                            await SharedPreferences.getInstance()
                              ..setBool('onboarding_completed', true);
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          }
                        : _animateToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2, // Slight elevation for better visibility
                    ),
                    child: Text(
                      _isLastPage ? 'Get Started' : 'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}