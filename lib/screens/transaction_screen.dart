import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/models/transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ledger_provider.dart';

class TransactionScreen extends StatelessWidget {
  final int index;
  const TransactionScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final ledger = Provider.of<LedgerProvider>(context);
    final person = ledger.people[index];
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    void _addTransaction(bool isGiven) {
      final amount = double.tryParse(amountController.text);
      if (amount != null && amount > 0) {
        ledger.addTransaction(
          index,
          Transaction(
            amount: amount,
            isGiven: isGiven,
            date: DateTime.now(),
            note: noteController.text,
          ),
        );
        amountController.clear();
        noteController.clear();
      }
    }

    void _showAddTransactionDialog() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _addTransaction(true);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Given'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _addTransaction(false);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Taken'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            Expanded(
              child: ListView.builder(
                itemCount: person.transactions.length,
                itemBuilder: (ctx, i) {
                  final tx = person.transactions[i];
                  final formattedTime = DateFormat('hh:mm a').format(tx.date);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
