import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/core/router/routes.dart';
import 'package:ledger_book_flutter/features/contacts/domain/entities/contact_entity.dart';
import 'package:ledger_book_flutter/features/contacts/providers/contact_provider.dart';

class AddContactPage extends ConsumerStatefulWidget {
  final String? initialName;
  final String? phone;
  final String? email;
  final String? id; // when provided, this page behaves as Edit
  final bool? isRegistered;
  final String? linkedUserId;

  const AddContactPage.addContactPage({
    super.key,
    this.initialName,
    this.phone,
    this.email,
    this.id,
    this.isRegistered,
    this.linkedUserId,
  });

  @override
  ConsumerState<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends ConsumerState<AddContactPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    phoneController = TextEditingController(text: widget.phone ?? '');
    emailController = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = (widget.id != null && widget.id!.isNotEmpty);
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Contact' : 'Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: 'Phone (optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a name')),
                          );
                          return;
                        }
                        setState(() => _saving = true);
                        try {
                          if (isEdit) {
                            final entity = ContactEntity(
                              id: widget.id!,
                              name: name,
                              phone: phone.isEmpty ? null : phone,
                            );
                            await ref.read(contactsRepositoryProvider).updateContact(entity);
                          } else {
                            final entity = ContactEntity(
                              id: "",
                              name: name,
                              phone: phone.isEmpty ? null : phone,
                            );
                            await ref.read(contactsRepositoryProvider).addContact(entity);
                          }
                          if (!mounted) return;
                          context.go(AppRoutes.contacts);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save contact: $e')),
                          );
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEdit ? 'Save Changes' : 'Add Person',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
