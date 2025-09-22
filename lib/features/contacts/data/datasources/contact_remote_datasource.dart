import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_model.dart';

class ContactRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ContactRemoteDataSource({required this.firestore, required this.auth});

  String get _uid {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  /// Add a new contact
  Future<void> addContact(ContactModel contact) async {
    final colRef = firestore
        .collection('users')
        .doc(_uid)
        .collection('contacts');
    // Only set user-editable fields at creation from the client; let Firestore assign the ID
    await colRef.add({
      'name': contact.name,
      'phone': contact.phone,
      'email': contact.email,
      'createdAt': FieldValue.serverTimestamp(),
      'balance': contact.balance, // Initialize balance to 0
      'isRegistered': contact.isRegistered,
      'linkedUserId': contact.linkedUserId,
    });
  }

  /// Get all contacts for the current user
  Future<List<ContactModel>> getContacts() async {
    final snapshot = await firestore
        .collection('users')
        .doc(_uid)
        .collection('contacts')
        .get();

    return snapshot.docs
        .map((doc) => ContactModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Search contacts by name (current user)
  Future<List<ContactModel>> searchContacts(String query) async {
    final snapshot = await firestore
        .collection('users')
        .doc(_uid)
        .collection('contacts')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => ContactModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Update a contact
  Future<void> updateContact(ContactModel contact) async {
    final docRef = firestore
        .collection('users')
        .doc(_uid)
        .collection('contacts')
        .doc(contact.id);
    // Only allow updating user-editable fields; protect system fields
    await docRef.update({
      'name': contact.name,
      'phone': contact.phone,
      'email': contact.email,
    });
  }

  /// Delete a contact
  Future<void> deleteContact(String contactId) async {
    final docRef = firestore
        .collection('users')
        .doc(_uid)
        .collection('contacts')
        .doc(contactId);
    await docRef.delete();
  }
}
