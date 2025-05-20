import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:ledger_book_flutter/screens/add_person.dart';
import 'package:ledger_book_flutter/widgets/cards/person_contact_card.dart';

class ContactListWidget extends StatelessWidget {
  final bool isLoading;
  final bool hasPermission;
  final List<Contact> filteredContacts;
  final TextEditingController nameController;
  final BuildContext parentContext;

  const ContactListWidget({
    super.key,
    required this.isLoading,
    required this.hasPermission,
    required this.filteredContacts,
    required this.nameController,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }

    if (!hasPermission) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Contacts permission denied',
              style: Theme.of(parentContext).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please enable contacts permission in settings to search your contacts',
              style: Theme.of(parentContext).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (filteredContacts.isEmpty && nameController.text.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No contacts found',
                style: Theme.of(parentContext).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different name or add a new contact',
                style: Theme.of(parentContext).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: Text('Create "${nameController.text}"'),
                onPressed: () {
                  Navigator.of(parentContext).push(
                    MaterialPageRoute(
                      builder: (context) => AddPersonPage(initialName: nameController.text),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final contact = filteredContacts[i];
          final displayName = contact.displayName;
          if (displayName.isEmpty) return const SizedBox.shrink();

          return PersonContactCard(displayName: displayName, contact: contact);
        },
        childCount: filteredContacts.length,
      ),
    );
  }
}
