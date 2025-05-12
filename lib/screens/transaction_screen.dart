import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/models/transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ledger_provider.dart';

class TransactionScreen extends StatelessWidget {
  final int index;
  const TransactionScreen({super.key, required this.index});

  void _showTransactionDialog({
    required BuildContext context,
    int? transactionIndex,
  }) {
    final ledger = Provider.of<LedgerProvider>(context, listen: false);
    final person = ledger.people[index];
    final isEditing = transactionIndex != null;
    final transaction =
        isEditing ? person.transactions[transactionIndex!] : null;

    final amountController = TextEditingController(
      text: isEditing ? transaction!.amount.toString() : '',
    );
    final noteController = TextEditingController(
      text: isEditing ? transaction!.note : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Transaction Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (!isEditing) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.call_made, size: 20),
                        label: const Text('Given'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (amount != null && amount > 0) {
                            ledger.addTransaction(
                              index,
                              Transaction(
                                amount: amount,
                                isGiven: true,
                                date: DateTime.now(),
                                note: noteController.text,
                              ),
                            );
                            Navigator.of(ctx).pop();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.call_received, size: 20),
                        label: const Text('Taken'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (amount != null && amount > 0) {
                            ledger.addTransaction(
                              index,
                              Transaction(
                                amount: amount,
                                isGiven: false,
                                date: DateTime.now(),
                                note: noteController.text,
                              ),
                            );
                            Navigator.of(ctx).pop();
                          }
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.update, size: 20),
                        label: const Text('Update'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          final updatedAmount = double.tryParse(amountController.text);
                          if (updatedAmount != null && updatedAmount > 0) {
                            ledger.updateTransaction(
                              index,
                              transactionIndex!,
                              Transaction(
                                amount: updatedAmount,
                                isGiven: transaction!.isGiven,
                                date: transaction.date,
                                note: noteController.text,
                              ),
                            );
                            Navigator.of(ctx).pop();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete, size: 20),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          ledger.deleteTransaction(index, transactionIndex!);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledger = Provider.of<LedgerProvider>(context);
    final person = ledger.people[index];

    double calculateBalance() {
      return person.transactions.fold(
        0.0,
        (sum, tx) => tx.isGiven ? sum - tx.amount : sum + tx.amount,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
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
                        color:
                            calculateBalance() >= 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (calculateBalance() >= 0
                                ? Colors.green.shade50
                                : Colors.red.shade50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        calculateBalance() >= 0
                            ? 'You owe ₹${(calculateBalance()).toStringAsFixed(2)}'
                            : 'You will receive ₹${calculateBalance().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              calculateBalance() >= 0
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child:
                  person.transactions.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 100,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Transactions Yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Add a transaction to get started!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: person.transactions.length,
                        itemBuilder: (ctx, i) {
                          final tx = person.transactions[i];
                          final formattedTime = DateFormat(
                            'hh:mm a',
                          ).format(tx.date);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
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
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed:
                                    () => _showTransactionDialog(
                                      context: context,
                                      transactionIndex: i,
                                    ),
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
        onPressed: () => _showTransactionDialog(context: context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
