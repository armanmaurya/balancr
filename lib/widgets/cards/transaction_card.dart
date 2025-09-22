import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.tx,
    required this.onEdit,
  });

  final TransactionEntity tx;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(tx.date);
    final formattedTime = DateFormat('hh:mm a').format(tx.date);

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
          '$formattedDate  $formattedTime\n${tx.note}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
