import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsSearchProvider extends ChangeNotifier {
  ContactsSearchProvider();

  final TextEditingController nameController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact> get filteredContacts => _filteredContacts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasPermission = true;
  bool get hasPermission => _hasPermission;

  Timer? _debounce;

  void init() {
    // Focus as soon as screen opens
    searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    nameController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _ensureContactsLoaded() async {
    if (_allContacts.isNotEmpty || !_hasPermission) return;
    final permission = await FlutterContacts.requestPermission();
    if (!permission) {
      _hasPermission = false;
      _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: false,
        withPhoto: false,
      );
      _allContacts = contacts;
    } catch (e) {
      debugPrint('Failed to load contacts: $e');
      _isLoading = false;
    }
  }

  void onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      _filteredContacts = List.from(_allContacts);
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await _ensureContactsLoaded();
        if (_hasPermission) {
          final q = value.toLowerCase();
          _filteredContacts = _allContacts
              .where((c) => c.displayName.toLowerCase().contains(q))
              .toList();
        } else {
          _filteredContacts = [];
        }
      } catch (e) {
        debugPrint('Search filtering failed: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }
}
