import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/contact_remote_datasource.dart';
import '../data/models/contact_model.dart';
import '../data/repositories/contacts_repository_impl.dart';
import '../domain/entities/contact_entity.dart';
import '../domain/repositories/contacts_repository.dart';

// Low-level dependencies
final _firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final _authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Data source
final _remoteDataSourceProvider = Provider<ContactRemoteDataSource>((ref) {
  return ContactRemoteDataSource(
    firestore: ref.watch(_firestoreProvider),
    auth: ref.watch(_authProvider),
  );
});

// Repository
final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepositoryImpl(remoteDataSource: ref.watch(_remoteDataSourceProvider));
});

// Stream of contacts for the current user (kept as a Stream for live updates)
final contactsProvider = StreamProvider<List<ContactEntity>>((ref) {
  final auth = ref.watch(_authProvider);
  final user = auth.currentUser;
  if (user == null) {
    return Stream.value(<ContactEntity>[]);
  }

  final firestore = ref.watch(_firestoreProvider);
  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('contacts')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data(), doc.id).toEntity())
          .toList());
});

// Get a specific contact by ID
final contactByIdProvider = StreamProvider.family<ContactEntity?, String>((ref, contactId) {
  final auth = ref.watch(_authProvider);
  final user = auth.currentUser;
  if (user == null) {
    return Stream.value(null);
  }

  final firestore = ref.watch(_firestoreProvider);
  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('contacts')
      .doc(contactId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return null;
        }
        return ContactModel.fromMap(snapshot.data()!, snapshot.id).toEntity();
      });
});

// Commands: simple helpers for UI actions
final deleteContactCommandProvider = FutureProvider.family<void, String>((ref, contactId) async {
  await ref.read(contactsRepositoryProvider).deleteContact(contactId);
});

final updateContactCommandProvider = FutureProvider.family<void, ContactEntity>((ref, contact) async {
  await ref.read(contactsRepositoryProvider).updateContact(contact);
});
