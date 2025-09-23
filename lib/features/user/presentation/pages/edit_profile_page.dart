import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledger_book_flutter/features/user/presentation/providers/auth_provider.dart';
import 'package:ledger_book_flutter/services/firestore_user_service.dart';
import 'package:ledger_book_flutter/l10n/app_localizations.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _photoController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _photoController = TextEditingController(text: user?.photoURL ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final current = ref.read(currentUserProvider);
    if (current == null) return;

    setState(() => _saving = true);
    try {
      final updated = current.copyWith(
        displayName: _nameController.text.trim().isEmpty
            ? current.displayName
            : _nameController.text.trim(),
        photoURL: _photoController.text.trim(),
      );
      final service = FirestoreUserService();
      await service.updateUser(updated);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${t.profileTitle} • Edit'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              maxLength: 50,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Name cannot be empty';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: 'Photo URL (optional)',
                prefixIcon: Icon(Icons.photo_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
