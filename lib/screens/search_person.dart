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
  bool isLoading = false;
  bool hasPermission = true;
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
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
    
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          filteredContacts = contacts
              .where((c) => c.displayName.toLowerCase().contains(value.toLowerCase()))
              .toList();
          isLoading = false;
          hasPermission = true;
        });
      } else {
        setState(() {
          filteredContacts = [];
          isLoading = false;
          hasPermission = false;
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
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (!hasPermission) {
      return Column(
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
      );
    }

    if (filteredContacts.isEmpty && nameController.text.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No contacts found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different name or add a new contact',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filteredContacts.length,
      itemBuilder: (ctx, i) {
      final contact = filteredContacts[i];
      final displayName = contact.displayName;
      if (displayName.isEmpty) return const SizedBox.shrink();

      return Card(
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (contact.phones.isNotEmpty)
                Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  contact.phones.first.number,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    ),
                ),
                ),
              ],
            ),
            ),
            Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
            ),
          ],
          ),
        ),
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Person'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                // color: Colors.,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
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
                  suffixIcon: nameController.text.isNotEmpty
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
            const SizedBox(height: 16),
            // Info text when empty
            if (nameController.text.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search your contacts',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start typing to find contacts',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Results section
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildContactList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}