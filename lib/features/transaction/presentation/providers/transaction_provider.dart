import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user/providers/user_provider.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

// Low-level dependencies
final _firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final _authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Data source
final _remoteDataSourceProvider = Provider<TransactionRemoteDatasource>((ref) {
  return TransactionRemoteDatasource(
    firestore: ref.watch(_firestoreProvider),
    auth: ref.watch(_authProvider),
  );
});

// Repository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    remoteDatasource: ref.watch(_remoteDataSourceProvider),
  );
});

// Stream of transactions for the current user (live updates)
final transactionsProvider = StreamProvider<List<TransactionEntity>>((ref) {
  // Wait for auth state to be properly initialized
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (userEntity) {
      if (userEntity == null) {
        return Stream.value(<TransactionEntity>[]);
      }

      final firestore = ref.watch(_firestoreProvider);
      return firestore
          .collection('users')
          .doc(userEntity.uid)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  // Robust parsing of date and amount types
                  final rawDate = data['date'];
                  DateTime parsedDate;
                  if (rawDate is Timestamp) {
                    parsedDate = rawDate.toDate();
                  } else if (rawDate is String) {
                    parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
                  } else {
                    parsedDate = DateTime.now();
                  }

                  final amount =
                      (data['amount'] is num)
                          ? (data['amount'] as num).toDouble()
                          : double.tryParse(data['amount']?.toString() ?? '') ??
                              0.0;

                  final model = TransactionModel(
                    id: doc.id,
                    amount: amount,
                    isGiven: (data['isGiven'] as bool?) ?? false,
                    date: parsedDate,
                    note: (data['note'] as String?) ?? '',
                    fromUserId: data['fromUserId'],
                    toUserId: data['toUserId'],
                    toContactId: data['toContactId'],
                  );
                  return model.toEntity();
                }).toList(),
          );
    },
    loading: () => Stream.value(<TransactionEntity>[]),
    error: (error, stack) => Stream.error(error, stack),
  );
});

// Stream of transactions for a specific contact (by linkedUserId)
final transactionsByContactProvider =
    StreamProvider.family<List<TransactionEntity>, String>((ref, contactId) {
  // Wait for auth state to be properly initialized
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (userEntity) {
      if (userEntity == null) {
        return Stream.value(<TransactionEntity>[]);
      }

      final firestore = ref.watch(_firestoreProvider);
      return firestore
          .collection('users')
          .doc(userEntity.uid)
          .collection('transactions')
          .where('toContactId', isEqualTo: contactId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  final rawDate = data['date'];
                  DateTime parsedDate;
                  if (rawDate is Timestamp) {
                    parsedDate = rawDate.toDate();
                  } else if (rawDate is String) {
                    parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
                  } else {
                    parsedDate = DateTime.now();
                  }

                  final amount =
                      (data['amount'] is num)
                          ? (data['amount'] as num).toDouble()
                          : double.tryParse(data['amount']?.toString() ?? '') ??
                              0.0;

                  final model = TransactionModel(
                    id: doc.id,
                    amount: amount,
                    isGiven: (data['isGiven'] as bool?) ?? false,
                    date: parsedDate,
                    note: (data['note'] as String?) ?? '',
                    fromUserId: data['fromUserId'],
                    toUserId: data['toUserId'],
                    toContactId: data['toContactId'],
                  );
                  return model.toEntity();
                }).toList(),
          );
    },
    loading: () => Stream.value(<TransactionEntity>[]),
    error: (error, stack) => Stream.error(error, stack),
  );
});

// Commands: simple helpers for UI actions (using Dart records for params)
// add: param = (tx: TransactionEntity, contactId: String)
final addTransactionCommandProvider =
    FutureProvider.family<void, ({TransactionEntity tx, String contactId})>(
        (ref, param) async {
  await ref
      .read(transactionRepositoryProvider)
      .addTransaction(param.tx, param.contactId);
});

// update: param = (tx: TransactionEntity, contactId: String)
final updateTransactionCommandProvider =
    FutureProvider.family<void, ({TransactionEntity tx, String contactId})>(
        (ref, param) async {
  await ref
      .read(transactionRepositoryProvider)
      .updateTransaction(param.tx, param.contactId);
});

// delete: param = (id: String, contactId: String)
final deleteTransactionCommandProvider =
    FutureProvider.family<void, ({String id, String contactId})>((ref, param) async {
  await ref
      .read(transactionRepositoryProvider)
      .deleteTransaction(param.id, param.contactId);
});
