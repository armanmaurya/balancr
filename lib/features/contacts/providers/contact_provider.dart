import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/contact_remote_datasource.dart';
import '../data/models/contact_model.dart';
import '../data/repositories/contacts_repository_impl.dart';
import '../domain/entities/contact_entity.dart';
import '../domain/repositories/contacts_repository.dart';
import '../../auth/providers/auth_provider.dart';

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
  // Wait for auth state to be properly initialized
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (userEntity) {
      if (userEntity == null) {
        return Stream.value(<ContactEntity>[]);
      }

      final firestore = ref.watch(_firestoreProvider);
      return firestore
          .collection('users')
          .doc(userEntity.uid)
          .collection('contacts')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ContactModel.fromMap(doc.data(), doc.id).toEntity())
              .toList());
    },
    loading: () => Stream.value(<ContactEntity>[]),
    error: (error, stack) => Stream.error(error, stack),
  );
});

// Get a specific contact by ID
final contactByIdProvider = StreamProvider.family<ContactEntity?, String>((ref, contactId) {
  // Wait for auth state to be properly initialized
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (userEntity) {
      if (userEntity == null) {
        return Stream.value(null);
      }

      final firestore = ref.watch(_firestoreProvider);
      return firestore
          .collection('users')
          .doc(userEntity.uid)
          .collection('contacts')
          .doc(contactId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists || snapshot.data() == null) {
              return null;
            }
            return ContactModel.fromMap(snapshot.data()!, snapshot.id).toEntity();
          });
    },
    loading: () => Stream.value(null),
    error: (error, stack) => Stream.error(error, stack),
  );
});

// Commands: simple helpers for UI actions
final deleteContactCommandProvider = FutureProvider.family<void, String>((ref, contactId) async {
  await ref.read(contactsRepositoryProvider).deleteContact(contactId);
});

final updateContactCommandProvider = FutureProvider.family<void, ContactEntity>((ref, contact) async {
  await ref.read(contactsRepositoryProvider).updateContact(contact);
});
