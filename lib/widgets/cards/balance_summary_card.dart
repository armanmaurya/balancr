import 'package:flutter/material.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double totalGive;
  final double totalTake;

  const BalanceSummaryCard({
    super.key,
    required this.totalGive,
    required this.totalTake,
  });

  // Reusable balance indicator widget
  static Widget buildBalanceIndicator(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color.withOpacity(0.9)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade800,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildBalanceIndicator(
            context,
            label: 'To Give',
            amount: totalGive,
            icon: Icons.arrow_upward,
            color: Colors.red.shade400,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade700,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          buildBalanceIndicator(
            context,
            label: 'To Take',
            amount: totalTake,
            icon: Icons.arrow_downward,
            color: Colors.green.shade400,
          ),
        ],
      ),
    );
  }
}