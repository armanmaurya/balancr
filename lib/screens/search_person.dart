import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ledger_book_flutter/widgets/inputs/search_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledger_book_flutter/providers/contacts_search_riverpod.dart';
import 'package:ledger_book_flutter/features/contacts/presentation/widgets/person_contact_card.dart';

class SearchPersonPage extends ConsumerStatefulWidget {
  const SearchPersonPage({super.key});

  @override
  ConsumerState<SearchPersonPage> createState() => _SearchPersonPageState();
}

class _SearchPersonPageState extends ConsumerState<SearchPersonPage> {
  late final TextEditingController _nameController = TextEditingController();
  late final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactsSearchProvider);
    final notifier = ref.read(contactsSearchProvider.notifier);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Add New Person"),
            centerTitle: true,
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: PrimarySearchBar(
              nameController: _nameController,
              searchFocusNode: _searchFocusNode,
              onSearchContacts: notifier.onQueryChanged,
              hintText: "Search Contacts...",
            ),
          ),
          if (state.isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            )
          else if (_nameController.text.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Search your contacts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start typing to find people or create a new person',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Create new person'),
                    onPressed: () {
                      context.push('/add_contact');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            )
          else if (!state.hasPermission)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Contacts permission denied',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enable contacts permission in settings to search your contacts',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (state.filteredContacts.isEmpty && _nameController.text.isNotEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different name or add a new contact',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: Text('Create "${_nameController.text}"'),
                    onPressed: () {
                      context.push('/add_contact?name=${Uri.encodeComponent(_nameController.text)}');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final contact = state.filteredContacts[i];
                  final displayName = contact.displayName;
                  if (displayName.isEmpty) return const SizedBox.shrink();
                  return PersonContactCard(
                    key: ValueKey(contact.id),
                    displayName: displayName,
                    contact: contact,
                  );
                },
                childCount: state.filteredContacts.length,
              ),
            ),
        ],
      ),
    );
  }
}
