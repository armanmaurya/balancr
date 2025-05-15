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
  Timer? _debounce;

  void _searchContacts(String value) async {
    // Debounce logic: wait for user to stop typing before searching
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
              .where((c) =>
                  (c.displayName)
                      .toLowerCase()
                      .contains(value.toLowerCase()))
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Person')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Search or Enter Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: _searchContacts,
            ),
            const SizedBox(height: 16),
            if (isLoading)
              SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filteredContacts.isNotEmpty)
              SizedBox(
                height: 180,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (ctx, i) {
                      final contact = filteredContacts[i];
                      final displayName = contact.displayName;
                      if (displayName.isEmpty) return const SizedBox.shrink();
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.account_circle, color: Colors.grey),
                        title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => AddPersonPage(initialName: displayName, phone: contact.phones.isNotEmpty ? contact.phones.first.number : null),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
