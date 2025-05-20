import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:ledger_book_flutter/widgets/inputs/search_bar.dart';
import 'dart:async';
import 'package:ledger_book_flutter/widgets/lists/contact_list_widget.dart';

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
        filteredContacts = List.from(allContacts); // Show all contacts if search is empty
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

  @override
  Widget build(BuildContext context) {
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
              nameController: nameController,
              searchFocusNode: _searchFocusNode,
              onSearchContacts: _searchContacts,
              hintText: "Search Contacts...",
            ),
          ),
          ContactListWidget(
            isLoading: isLoading,
            hasPermission: hasPermission,
            filteredContacts: filteredContacts,
            nameController: nameController,
            parentContext: context,
          ),
        ],
      ),
    );
  }
}
