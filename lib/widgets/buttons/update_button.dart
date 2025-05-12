import 'package:flutter/material.dart';

class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.update, size: 20),
      label: const Text('Update'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
    );
  }
}
