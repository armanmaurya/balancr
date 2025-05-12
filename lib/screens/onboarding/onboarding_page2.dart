import 'package:flutter/material.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            'Manage Your Transactions',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Inbuilt Icon
          Icon(
            Icons.account_balance_wallet_outlined,
            size: size.height * 0.2,
            color: Colors.deepPurple.shade400,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Easily add, edit, and categorize your transactions to keep your records organized.',
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