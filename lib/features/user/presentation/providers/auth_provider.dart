import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledger_book_flutter/features/user/domain/entities/user_entity.dart';
import 'package:ledger_book_flutter/features/user/domain/repositories/auth_repository.dart';
import 'package:ledger_book_flutter/features/user/data/repositories/user_repository_impl.dart';
import 'package:ledger_book_flutter/features/user/data/datasources/user_remote_datasource.dart';
import 'package:ledger_book_flutter/features/user/data/models/user_model.dart';

// Data source providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
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

// User financial data stream provider - streams real-time financial data from Firestore
final userFinancialDataProvider = StreamProvider<UserEntity?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value(null);
  }

  final authRepository = ref.watch(authRepositoryProvider);
  
  return authRepository
      .getUserFinancialDataStream(currentUser.uid)
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      // Return current user with default financial values if document doesn't exist
      return currentUser;
    }
    
    final data = snapshot.data()!;
    
    // Create UserModel from Firestore data with real-time financial updates
    final userModel = UserModel.fromFirestore({
      ...data,
      'uid': currentUser.uid, // Ensure UID is always present
    });
    
    return userModel.toEntity();
  });
});