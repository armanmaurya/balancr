import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/person.dart';
import '../models/transaction.dart';

class LedgerProvider with ChangeNotifier {
  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;

  LedgerProvider({FirebaseFirestore? db, fb.FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? fb.FirebaseAuth.instance {
    _initListeners();
  }

  final List<People> _people = [];
  List<People> get people => List.unmodifiable(_people);
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _contactsSub;
  final Map<String, StreamSubscription> _txSubs = {};

  int _lastId = 0;
  final Map<String, int> _lastTxIdByPerson = {};

  People? getPersonById(String id) {
    final idx = _indexById(id);
    if (idx == null) return null;
    return _people[idx];
  }

  int? _indexById(String id) {
    final idx = _people.indexWhere((p) => p.id == id);
    return idx == -1 ? null : idx;
  }

  Future<void> _initListeners() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _contactsSub?.cancel();
    for (final sub in _txSubs.values) {
      sub.cancel();
    }
    _txSubs.clear();

    _contactsSub = _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            _errorMessage = null;
            _people.clear();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              final person = People.fromMap(data, id: doc.id);
              _people.add(person);
              // Track last id for deterministic id generation (if needed)
              final asInt = int.tryParse(doc.id) ?? 0;
              if (asInt > _lastId) _lastId = asInt;

              // Listen to transactions subcollection for each person
              _txSubs[doc.id]?.cancel();
              _txSubs[doc.id] = _db
                  .collection('users')
                  .doc(user.uid)
                  .collection('contacts')
                  .doc(doc.id)
                  .collection('transactions')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
                  .listen(
                    (txSnap) {
                      final idx = _indexById(doc.id);
                      if (idx == null) return;
                      final txs = <Transaction>[];
                      for (final t in txSnap.docs) {
                        final tData = t.data();
                        final dateField = tData['date'];
                        DateTime date;
                        if (dateField is Timestamp) {
                          date = dateField.toDate();
                        } else if (dateField is DateTime) {
                          date = dateField;
                        } else if (dateField is String) {
                          date = DateTime.tryParse(dateField) ?? DateTime.now();
                        } else {
                          date = DateTime.now();
                        }
                        txs.add(
                          Transaction(
                            amount: (tData['amount'] as num).toDouble(),
                            isGiven: tData['isGiven'] as bool,
                            date: date,
                            note: (tData['note'] as String?) ?? '',
                            id: t.id,
                          ),
                        );
                        final asTxInt = int.tryParse(t.id) ?? 0;
                        if (asTxInt > (_lastTxIdByPerson[doc.id] ?? 0)) {
                          _lastTxIdByPerson[doc.id] = asTxInt;
                        }
                      }
                      // _people[idx].transactions = txs;
                      notifyListeners();
                    },
                    onError: (Object e, StackTrace st) {
                      _errorMessage = e.toString();
                      notifyListeners();
                    },
                  );
            }
            notifyListeners();
          },
          onError: (Object e, StackTrace st) {
            _errorMessage = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> addPerson({
    required String name,
    String? contactId,
    String? phone,
  }) async {
    // Avoid duplicate by name and phone (if provided) locally
    final exists = _people.any(
      (p) =>
          p.name.trim().toLowerCase() == name.trim().toLowerCase() &&
          (phone == null || phone.isEmpty || p.phone == phone),
    );
    if (exists) return;

    final user = _auth.currentUser;
    if (user == null) return;

    // Auto-increment id logic (using numeric doc id to preserve old pattern)
    _lastId = _lastId + 1;
    final personId = _lastId.toString();
    final now = FieldValue.serverTimestamp();
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .doc(personId)
        .set({
          'name': name,
          'phone': phone,
          'contactId': contactId,
          'localId': personId,
          'createdAt': now,
          'updatedAt': now,
        });
  }

  // Update Person
  Future<void> updatePerson(String id, String name, String phone) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .doc(id)
        .update({
          'name': name,
          'phone': phone,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Delete Person
  Future<void> deletePerson(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .doc(id)
        .delete();
  }

  Future<void> addTransaction(String personId, Transaction tx) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // Auto-increment transaction id per person
    _lastTxIdByPerson[personId] = (_lastTxIdByPerson[personId] ?? 0) + 1;
    final txId = _lastTxIdByPerson[personId]!.toString();
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .doc(personId)
        .collection('transactions')
        .doc(txId)
        .set({
          'amount': tx.amount,
          'isGiven': tx.isGiven,
          'date': Timestamp.fromDate(tx.date),
          'note': tx.note,
          'localId': txId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Update Transaction
  Future<void> updateTransaction(
    String personId,
    String transactionId,
    Transaction tx,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .doc(personId)
        .collection('transactions')
        .doc(transactionId)
        .update({
          'amount': tx.amount,
          'isGiven': tx.isGiven,
          'date': Timestamp.fromDate(tx.date),
          'note': tx.note,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Delete Transaction
  Future<void> deleteTransaction(String personId, String transactionId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .doc(personId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  @override
  void dispose() {
    _contactsSub?.cancel();
    for (final sub in _txSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
