import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';
import 'add_person.dart';

class SearchPersonPage extends StatefulWidget {
  const SearchPersonPage({super.key});

  @override
  State<SearchPersonPage> createState() => _SearchPersonPageState();
}

class _SearchPersonPageState extends State<SearchPersonPage> {
  final TextEditingController nameController = TextEditingController();
  List<Contact> filteredContacts = [];
  List<Contact> allContacts = []; // Store all contacts
  bool isLoading = false;
  bool hasPermission = true;
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _fetchContactsOnOpen();
  }

  Future<void> _fetchContactsOnOpen() async {
    setState(() {
      isLoading = true;
    });
    // Always fetch contacts and show them on page push
    final permission = await FlutterContacts.requestPermission();
    print('Permission granted: $permission');
    if (permission) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);

      setState(() {
        allContacts = contacts;
        filteredContacts = contacts; // Show all contacts immediately
        hasPermission = true;
        isLoading = false;
      });
    } else {
      setState(() {
        allContacts = [];
        filteredContacts = [];
        hasPermission = false;
        isLoading = false;
      });
    }
  }

  void _searchContacts(String value) async {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        filteredContacts = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (hasPermission) {
        setState(() {
          filteredContacts =
              allContacts
                  .where(
                    (c) => c.displayName.toLowerCase().contains(
                      value.toLowerCase(),
                    ),
                  )
                  .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          filteredContacts = [];
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    nameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildContactList() {
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different name or add a new contact',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: Text('Create "${nameController.text}"'),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder:
                          (context) =>
                              AddPersonPage(initialName: nameController.text),
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => AddPersonPage(
                        initialName: displayName,
                        phone: contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : null,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (contact.phones.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  contact.phones.first.number,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: filteredContacts.length, // <-- Fix: set childCount
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Add New Person'),
      //   elevation: 0,
      //   centerTitle: true,
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Add New Person"),
            centerTitle: true,
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: AnimatedContainer(
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
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search contacts or enter name...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  suffixIcon:
                      nameController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              nameController.clear();
                              _searchContacts('');
                            },
                          )
                          : null,
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: _searchContacts,
              ),
            ),
          ),
          _buildContactList(),
        ],
      ),

      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       const SizedBox(height: 16),
      //       // Info text when empty
      //       if (nameController.text.isEmpty && filteredContacts.isEmpty && !isLoading)
      //         Expanded(
      //           child: Center(
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Icon(
      //                   Icons.contacts,
      //                   size: 64,
      //                   color: Colors.grey[300],
      //                 ),
      //                 const SizedBox(height: 16),
      //                 Text(
      //                   'No contacts found',
      //                   style: Theme.of(context)
      //                       .textTheme
      //                       .titleMedium
      //                       ?.copyWith(color: Colors.grey),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         )
      //       else
      //         // Results section
      //         Expanded(
      //           child: AnimatedSwitcher(
      //             duration: const Duration(milliseconds: 300),
      //             child: _buildContactList(),
      //           ),
      //         ),
      //     ],
      //   ),
      // ),
    );
  }
}
