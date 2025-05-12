import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/models/person.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.person});

  final Person person;

  double calculateBalance() {
    return person.transactions.fold(
      0.0,
      (sum, tx) => tx.isGiven ? sum - tx.amount : sum + tx.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200, // subtle border for depth
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Balance Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₹${calculateBalance().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: calculateBalance() >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: calculateBalance() >= 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                calculateBalance() >= 0
                    ? 'You will receive ₹${calculateBalance().toStringAsFixed(2)}'
                    : 'You owe ₹${(-calculateBalance()).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: calculateBalance() >= 0
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
