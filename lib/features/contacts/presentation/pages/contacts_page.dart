import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/features/contacts/presentation/widgets/contact_card.dart';
import 'package:ledger_book_flutter/features/contacts/presentation/widgets/financial_overview_slivers.dart';

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

          // Financial Overview Slivers
          const FinancialOverviewSlivers(),

          // Contacts Section Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contacts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 1,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          contacts.when(
            data: (contacts) {
              if (contacts.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No contacts yet',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add contacts to start tracking\nyour shared expenses',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push(AppRoutes.searchLocalContact);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Contact'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final contact = contacts[index];
                    return ContactCard(contact: contact);
                  }, childCount: contacts.length),
                ),
              );
            },
            loading:
                () => SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color?>(Colors.blue),
                      ),
                    ),
                  ),
                ),
            error: (error, stack) {
              print('Error loading contacts: $error $stack');

              // Check if it's a permission error
              final isPermissionError = error.toString().contains(
                'permission-denied',
              );

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPermissionError
                              ? Icons.lock_outline
                              : Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isPermissionError
                              ? 'Authentication Required'
                              : 'Error Loading Contacts',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Add space below the contacts list
          const SliverToBoxAdapter(
            child: SizedBox(height: 150), // Adjust the height as needed
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.searchLocalContact);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
