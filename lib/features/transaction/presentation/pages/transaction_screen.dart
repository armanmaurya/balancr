import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/core/router/routes.dart';
import 'package:ledger_book_flutter/widgets/cards/transaction_card.dart';
import 'package:ledger_book_flutter/features/contacts/providers/contact_provider.dart';
import '../providers/transaction_provider.dart';
import 'transaction_form_page.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  final String contactId;
  const TransactionScreen({super.key, required this.contactId});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch both contact and transactions
    final contactAsync = ref.watch(contactByIdProvider(widget.contactId));
    final txAsync = ref.watch(transactionsByContactProvider(widget.contactId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          // Contact Overview Section
          contactAsync.when(
            data: (contact) {
              if (contact == null) {
                return const SizedBox.shrink();
              }
              return _buildContactOverview(contact);
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text('Failed to load contact: $e')),
            ),
          ),
          
          // Transactions List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: txAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) return buildEmptyTransaction();
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (ctx, i) {
                      final tx = transactions[i];
                      return TransactionCard(
                        tx: tx,
                        onEdit: () {
                          context.push(
                            "${AppRoutes.transactionForm}/${widget.contactId}",
                            extra: tx,
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Failed to load transactions: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push("${AppRoutes.transactionForm}/${widget.contactId}");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactOverview(contact) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final balance = contact.balance.toDouble();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contact Header
          Row(
            children: [
              // Contact Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(contact.name),
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Contact Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (contact.phone != null && contact.phone!.isNotEmpty)
                      Text(
                        contact.phone!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Balance Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBalanceText(balance),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getBalanceColor(balance).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${balance.abs().toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      color: _getBalanceColor(balance),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      return 'You will get';
    } else {
      return 'You owe';
    }
  }

  Color _getBalanceColor(double balance) {
    final colorScheme = Theme.of(context).colorScheme;
    if (balance == 0) {
      return colorScheme.onSurface.withOpacity(0.6);
    } else if (balance > 0) {
      return Colors.green.shade700;
    } else {
      return colorScheme.error;
    }
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
}
