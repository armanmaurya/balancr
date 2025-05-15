import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Hero(
            tag: 'onboarding1',
            child: SvgPicture.asset(
              'assets/illustrations/money_tracking.svg',
              height: size.height * 0.4,
              semanticsLabel: 'Money Tracking Illustration',
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Track Money Given & Received',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Easily record how much you have given to others and how much others have given to you. Stay organized and never forget any transaction.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
