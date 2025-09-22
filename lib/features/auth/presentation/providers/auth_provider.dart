import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledger_book_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:ledger_book_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:ledger_book_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ledger_book_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ledger_book_flutter/services/firestore_user_service.dart';

// Data source providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final firestoreUserServiceProvider = Provider<FirestoreUserService>((ref) {
  return FirestoreUserService();
});

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    firestoreUserService: ref.watch(firestoreUserServiceProvider),
  );
});

// Auth state provider - streams the current user
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// Current user provider (sync access to current auth state)
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});