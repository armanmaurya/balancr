import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/features/contacts/presentation/widgets/contact_card.dart';

import '../../../../core/router/routes.dart';
import '../../../../screens/search_person.dart';
import '../../providers/contact_provider.dart';

class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Balancr'),
            centerTitle: true,
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),

          contacts.when(
            data: (contacts) {
              if (contacts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No contacts found.\nPlease add contacts to get started.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final contact = contacts[index];
                    return ContactCard(
                      contact: contact,
                    );
                  },
                  childCount: contacts.length,
                ),
              );
            },
            loading:
                () => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color?>(Colors.blue),
                    ),
                  ),
                ),
            error:
                (error, stack) {
                  print('Error loading contacts: $error $stack');
                  
                  // Check if it's a permission error
                  final isPermissionError = error.toString().contains('permission-denied');
                  
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPermissionError ? Icons.lock_outline : Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isPermissionError 
                                ? 'Authentication Required'
                                : 'Error Loading Contacts',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              isPermissionError
                                  ? 'Please wait while we verify your authentication.\nIf this persists, try signing out and back in.'
                                  : 'Failed to load your contacts.\nPlease check your internet connection and try again.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Refresh the provider
                              ref.invalidate(contactsProvider);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (context) => const SearchPersonPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
