import 'package:flutter/material.dart';

class PrimarySearchBar extends StatelessWidget {
  final TextEditingController nameController;
  final FocusNode searchFocusNode;
  final void Function(String) onSearchContacts;
  final String hintText;

  const PrimarySearchBar({
    super.key,
    required this.nameController,
    required this.searchFocusNode,
    required this.onSearchContacts,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        // color: Colors.,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: nameController,
        focusNode: searchFocusNode,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          suffixIcon: nameController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    nameController.clear();
                    onSearchContacts('');
                  },
                )
              : null,
        ),
        textCapitalization: TextCapitalization.words,
        onChanged: onSearchContacts,
      ),
    );
  }
}