import 'package:flutter/material.dart';
import 'package:ledger_book_flutter/models/person.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key, 
    required this.person, 
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onMenu,
  });

  final Person person;
  final Function()? onTap;
  final Function()? onEdit;
  final Function()? onDelete;
  final Function()? onMenu; // Add this callback

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance: ₹${person.balance.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: person.balance < 0 ? Colors.red : Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Replace PopupMenuButton with a three dots IconButton that calls onMenu
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}