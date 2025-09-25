import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDatasource {
  TransactionRemoteDatasource({required this.firestore, required this.auth});

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  String get _uid {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      firestore.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _transactionRef(
    String uid,
    String transactionId,
  ) =>
      _userRef(uid).collection('transactions').doc(transactionId);

  DocumentReference<Map<String, dynamic>> _contactRef(
    String uid,
    String contactId,
  ) =>
      _userRef(uid).collection('contacts').doc(contactId);

  String? _normalizeId(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  double _signedAmount(double amount, bool isGiven) => isGiven ? amount : -amount;

  Future<void> addTransaction(
    TransactionModel transaction,
    String contactId,
  ) async {
    final uid = _uid;
    final normalizedContactId =
        _normalizeId(transaction.toContactId ?? contactId);
    final userRef = _userRef(uid);
    final transactionsCol = userRef.collection('transactions');
    final newTransactionRef = transactionsCol.doc();

    final amount = transaction.amount;
    final isGiven = transaction.isGiven;
    final signedAmount = _signedAmount(amount, isGiven);

    await firestore.runTransaction((txn) async {
      txn.set(newTransactionRef, {
        'amount': amount,
        'isGiven': isGiven,
        'date': transaction.date.toIso8601String(),
        'note': transaction.note,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'fromUserId': transaction.fromUserId,
        'toUserId': transaction.toUserId,
        'toContactId': normalizedContactId,
      });

      if (normalizedContactId != null) {
        final contactRef = _contactRef(uid, normalizedContactId);
        txn.set(contactRef, {
          'balance': FieldValue.increment(signedAmount),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      txn.set(userRef, {
        'totalGiven': FieldValue.increment(isGiven ? amount : 0.0),
        'totalTaken': FieldValue.increment(isGiven ? 0.0 : amount),
        'netBalance': FieldValue.increment(signedAmount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<List<TransactionModel>> getTransactions() async {
    final snapshot = await firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<void> updateTransaction(
    TransactionModel transaction,
    String contactId,
  ) async {
    final uid = _uid;
    final transactionId = transaction.id;
    if (transactionId == null) {
      throw ArgumentError('Transaction ID is required for updates');
    }

    final newContactId = _normalizeId(transaction.toContactId ?? contactId);
    final userRef = _userRef(uid);
    final transactionRef = _transactionRef(uid, transactionId);

    await firestore.runTransaction((txn) async {
      final snapshot = await txn.get(transactionRef);
      if (!snapshot.exists) {
        throw StateError('Transaction not found');
      }

      final data = snapshot.data()!;

      final previousAmount = _parseAmount(data['amount']);
      final previousIsGiven = (data['isGiven'] as bool?) ?? false;
      final previousContactId =
          _normalizeId(data['toContactId'] as String?);

      final previousBalance = _signedAmount(previousAmount, previousIsGiven);
      final newAmount = transaction.amount;
      final newIsGiven = transaction.isGiven;
      final newBalance = _signedAmount(newAmount, newIsGiven);

      final givenChange =
          (newIsGiven ? newAmount : 0.0) - (previousIsGiven ? previousAmount : 0.0);
      final takenChange =
          (!newIsGiven ? newAmount : 0.0) - (!previousIsGiven ? previousAmount : 0.0);
      final netBalanceChange = newBalance - previousBalance;

      txn.update(transactionRef, {
        'amount': newAmount,
        'isGiven': newIsGiven,
        'date': transaction.date.toIso8601String(),
        'note': transaction.note,
        'updatedAt': FieldValue.serverTimestamp(),
        'fromUserId': transaction.fromUserId,
        'toUserId': transaction.toUserId,
        'toContactId': newContactId,
      });

      if (previousContactId != newContactId) {
        if (previousContactId != null) {
          final oldContactRef = _contactRef(uid, previousContactId);
          txn.set(oldContactRef, {
            'balance': FieldValue.increment(-previousBalance),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        if (newContactId != null) {
          final newContactRef = _contactRef(uid, newContactId);
          txn.set(newContactRef, {
            'balance': FieldValue.increment(newBalance),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } else if (newContactId != null && netBalanceChange != 0.0) {
        final contactRef = _contactRef(uid, newContactId);
        txn.set(contactRef, {
          'balance': FieldValue.increment(netBalanceChange),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (givenChange != 0.0 || takenChange != 0.0 || netBalanceChange != 0.0) {
        txn.set(userRef, {
          'totalGiven': FieldValue.increment(givenChange),
          'totalTaken': FieldValue.increment(takenChange),
          'netBalance': FieldValue.increment(netBalanceChange),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        txn.set(userRef, {
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> deleteTransaction(String id, String contactId) async {
    final uid = _uid;
    final userRef = _userRef(uid);
    final transactionRef = _transactionRef(uid, id);

    await firestore.runTransaction((txn) async {
      final snapshot = await txn.get(transactionRef);
      if (!snapshot.exists) {
        return;
      }

      final data = snapshot.data()!;
      final amount = _parseAmount(data['amount']);
      final isGiven = (data['isGiven'] as bool?) ?? false;
      final existingContactId =
          _normalizeId(data['toContactId'] as String? ?? contactId);
      final signedAmount = _signedAmount(amount, isGiven);

      txn.delete(transactionRef);

      if (existingContactId != null) {
        final contactRef = _contactRef(uid, existingContactId);
        txn.set(contactRef, {
          'balance': FieldValue.increment(-signedAmount),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      txn.set(userRef, {
        'totalGiven': FieldValue.increment(isGiven ? -amount : 0.0),
        'totalTaken': FieldValue.increment(isGiven ? 0.0 : -amount),
        'netBalance': FieldValue.increment(-signedAmount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
