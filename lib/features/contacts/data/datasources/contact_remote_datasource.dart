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
      'createdAt': FieldValue.serverTimestamp(),
      'balance': contact.balance, // Maintained through transaction operations
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
      // Balance updates occurs via transaction operations to keep totals consistent.
    });
  }

  /// Delete a contact
  Future<void> deleteContact(String contactId) async {
    final uid = _uid;
    final trimmedContactId = contactId.trim();
    final userRef = firestore.collection('users').doc(uid);
    final contactRef = userRef.collection('contacts').doc(trimmedContactId);
    final transactionsQuery = await userRef
        .collection('transactions')
        .where('toContactId', isEqualTo: trimmedContactId)
        .get();

    double totalGivenDelta = 0.0;
    double totalTakenDelta = 0.0;
    double netBalanceDelta = 0.0;

    WriteBatch batch = firestore.batch();
    int opsInBatch = 0;

    Future<void> flushBatch() async {
      if (opsInBatch == 0) return;
      await batch.commit();
      batch = firestore.batch();
      opsInBatch = 0;
    }

    Future<void> queueDelete(DocumentReference<Map<String, dynamic>> ref) async {
      if (opsInBatch >= 450) {
        await flushBatch();
      }
      batch.delete(ref);
      opsInBatch++;
    }

    await queueDelete(contactRef);

    for (final doc in transactionsQuery.docs) {
      await queueDelete(doc.reference);

      final data = doc.data();
      final rawAmount = data['amount'];
      final amount = rawAmount is num
          ? rawAmount.toDouble()
          : double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;
      final isGiven = (data['isGiven'] as bool?) ?? false;
      final signedAmount = isGiven ? amount : -amount;

      if (isGiven) {
        totalGivenDelta -= amount;
      } else {
        totalTakenDelta -= amount;
      }
      netBalanceDelta -= signedAmount;
    }

    final userUpdate = <String, dynamic>{
      'lastUpdated': FieldValue.serverTimestamp(),
      if (totalGivenDelta != 0.0)
        'totalGiven': FieldValue.increment(totalGivenDelta),
      if (totalTakenDelta != 0.0)
        'totalTaken': FieldValue.increment(totalTakenDelta),
      if (netBalanceDelta != 0.0)
        'netBalance': FieldValue.increment(netBalanceDelta),
    };

    if (opsInBatch >= 450) {
      await flushBatch();
    }
    batch.set(userRef, userUpdate, SetOptions(merge: true));
    opsInBatch++;

    await flushBatch();
  }
}
