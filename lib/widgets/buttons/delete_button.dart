import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.delete, size: 20),
      label: const Text('Delete'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed, // Fixed to call the provided callback
    );
  }
}
