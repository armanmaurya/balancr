import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/models/transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.tx,
    required this.formattedTime,
    required this.onEdit,
  });

  final Transaction tx;
  final String formattedTime;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          '${tx.isGiven ? 'Given' : 'Taken'} ₹${tx.amount}',
          style: TextStyle(
            color: tx.isGiven ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$formattedTime \n${tx.note}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: onEdit, // Fixed to use the provided callback
        ),
      ),
    );
  }
}
