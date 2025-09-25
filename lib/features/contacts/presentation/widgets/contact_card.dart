import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/core/router/routes.dart';
import 'package:ledger_book_flutter/features/contacts/domain/entities/contact_entity.dart';
import 'package:ledger_book_flutter/features/contacts/providers/contact_provider.dart';
import 'package:ledger_book_flutter/widgets/modal_bottom_sheets/confirmation_bottom_sheet.dart';

class ContactCard extends ConsumerWidget {
  const ContactCard({super.key, required this.contact});

  final ContactEntity contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push(
            "${AppRoutes.transaction}/${contact.id}"
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: colorScheme.primary.withOpacity(0.1),
        highlightColor: colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Contact avatar/initials
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(contact.name),
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Contact details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBalanceText(contact.balance.toDouble()),
                      style: textTheme.bodySmall?.copyWith(
                        color: _getBalanceColor(contact.balance.toDouble(), colorScheme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Options menu button
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () => _showOptionsMenu(context, ref),
                splashRadius: 20,
                tooltip: 'Options',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.length > 1
        ? name.substring(0, 2).toUpperCase()
        : name.padRight(2, ' ').toUpperCase();
  }

  String _getBalanceText(double balance) {
    if (balance == 0) {
      return 'No pending balance';
    } else if (balance > 0) {
      return 'You will get ₹${balance.abs().toStringAsFixed(2)}';
    } else {
      return 'You give ₹${balance.abs().toStringAsFixed(2)}';
    }
  }

  Color _getBalanceColor(double balance, ColorScheme colorScheme) {
    if (balance == 0) {
      return colorScheme.onSurface.withOpacity(0.6);
    } else if (balance > 0) {
      return Colors.green.shade700;
    } else {
      return colorScheme.error;
    }
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = theme.brightness == Brightness.dark;
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22272B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    "Options",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Future.delayed(const Duration(milliseconds: 150), () {
                            context.push(
                              "/add_contact?name=${Uri.encodeComponent(contact.name)}&id=${Uri.encodeComponent(contact.id!)}&phone=${Uri.encodeComponent(contact.phone ?? '')} ?? '')}",
                            );
                          });
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        label: const Text('Edit Contact'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: colorScheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: colorScheme.primary,
                          backgroundColor: colorScheme.primary.withOpacity(0.05),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Future.delayed(const Duration(milliseconds: 150), () {
                            showDeleteBottomSheet(
                              context: context,
                              title: 'Delete Contact',
                              message:
                                  'Are you sure you want to delete ${contact.name}? This action cannot be undone.',
                              onConfirm: () async {
                                await ref
                                    .read(contactsRepositoryProvider)
                                    .deleteContact(contact.id!);
                              },
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
