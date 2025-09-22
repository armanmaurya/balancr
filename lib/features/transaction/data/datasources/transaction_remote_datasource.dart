import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TransactionRemoteDatasource({required this.firestore, required this.auth});

  String get _uid {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  /// Add a new transaction
  Future<void> addTransaction(
    TransactionModel transaction,
    String contactId,
  ) async {
    final colRef = firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions');
    // Only set user-editable fields at creation from the client; let Firestore assign the ID
    await colRef.add({
      'amount': transaction.amount,
      'isGiven': transaction.isGiven,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
      'createdAt': FieldValue.serverTimestamp(),
      'fromUserId': transaction.fromUserId,
      'toUserId': transaction.toUserId,
      'toContactId': transaction.toContactId,
    });
  }

  /// Get all transactions for the current user
  Future<List<TransactionModel>> getTransactions() async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(_uid)
            .collection('transactions')
            .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  /// Update a transaction
  Future<void> updateTransaction(TransactionModel transaction, String contactId) async {
    final docRef = firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .doc(transaction.id);

    await docRef.update({
      'amount': transaction.amount,
      'isGiven': transaction.isGiven,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
      'updatedAt': FieldValue.serverTimestamp(),
      'fromUserId': transaction.fromUserId,
      'toUserId': transaction.toUserId,
      'toContactId': transaction.toContactId,
    });
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id, String contactId) async {
    final docRef = firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .doc(id);
    await docRef.delete();
  }
}
