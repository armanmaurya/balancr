import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddPersonDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Person'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Name')),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Provider.of<LedgerProvider>(context, listen: false)
                    .addPerson(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledger = Provider.of<LedgerProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('LedgerBook')),
      body: ListView.builder(
        itemCount: ledger.people.length,
        itemBuilder: (ctx, i) {
          final person = ledger.people[i];
          return ListTile(
            title: Text(person.name),
            subtitle: Text(
              'Balance: ₹${person.balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: person.balance < 0 ? Colors.red : Colors.green,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionScreen(index: i),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
