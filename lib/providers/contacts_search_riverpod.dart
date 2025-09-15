import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactsSearchState {
  final List<Contact> filteredContacts;
  final bool isLoading;
  final bool hasPermission;

  const ContactsSearchState({
    required this.filteredContacts,
    required this.isLoading,
    required this.hasPermission,
  });

  ContactsSearchState copyWith({
    List<Contact>? filteredContacts,
    bool? isLoading,
    bool? hasPermission,
  }) => ContactsSearchState(
        filteredContacts: filteredContacts ?? this.filteredContacts,
        isLoading: isLoading ?? this.isLoading,
        hasPermission: hasPermission ?? this.hasPermission,
      );
}

class ContactsSearchNotifier extends StateNotifier<ContactsSearchState> {
  ContactsSearchNotifier()
      : _allContacts = const [],
        super(
          ContactsSearchState(
            filteredContacts: const [],
            isLoading: false,
            hasPermission: true,
          ),
        );

  List<Contact> _allContacts;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _ensureContactsLoaded() async {
    if (_allContacts.isNotEmpty || !state.hasPermission) return;
    final permission = await FlutterContacts.requestPermission();
    if (!permission) {
      state = state.copyWith(hasPermission: false, isLoading: false);
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
      state = state.copyWith(isLoading: false);
    }
  }

  void onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      state = state.copyWith(
        filteredContacts: List.from(_allContacts),
        isLoading: false,
      );
      return;
    }
    state = state.copyWith(isLoading: true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await _ensureContactsLoaded();
        if (state.hasPermission) {
          final q = value.toLowerCase();
          final results = _allContacts
              .where((c) => c.displayName.toLowerCase().contains(q))
              .toList();
          state = state.copyWith(
            filteredContacts: results,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            filteredContacts: const [],
            isLoading: false,
          );
        }
      } catch (e) {
        debugPrint('Search filtering failed: $e');
        state = state.copyWith(isLoading: false);
      }
    });
  }
}

final contactsSearchProvider =
    StateNotifierProvider<ContactsSearchNotifier, ContactsSearchState>((ref) {
  return ContactsSearchNotifier();
});
