import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/models/transaction.dart';
import 'package:ledger_book_flutter/widgets/buttons/delete_button.dart';
import 'package:ledger_book_flutter/widgets/buttons/update_button.dart';
import 'package:ledger_book_flutter/widgets/cards/balance_card.dart';
import 'package:ledger_book_flutter/widgets/cards/transaction_card.dart';
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
      builder:
          (ctx) => Padding(
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
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
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
                              final amount = double.tryParse(
                                amountController.text,
                              );
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
                              final amount = double.tryParse(
                                amountController.text,
                              );
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
                          child: UpdateButton(
                            onPressed: () {
                              final updatedAmount = double.tryParse(
                                amountController.text,
                              );
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
                          child: DeleteButton(
                            onPressed: () {
                              ledger.deleteTransaction(
                                index,
                                transactionIndex!,
                              );
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

    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BalanceCard(person: person),
            Expanded(
              child:
                  person.transactions.isEmpty
                      ? buildEmptyTransaction()
                      : buildTransactionList(
                        person.transactions,
                        (transactionIndex) => _showTransactionDialog(
                          context: context,
                          transactionIndex: transactionIndex,
                        ),
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

  Widget buildEmptyTransaction() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            'No Transactions Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add a transaction to get started!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildTransactionList(
    List<Transaction> transactions,
    Function(int) onEdit,
  ) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, i) {
        final tx = transactions[i];
        final formattedTime = DateFormat('hh:mm a').format(tx.date);
        return TransactionCard(
          tx: tx,
          formattedTime: formattedTime,
          onEdit: () => onEdit(i),
        );
      },
    );
  }
}
