import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/user_remote_datasource.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';

// Low-level dependencies
final _firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final _googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());
final _firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Data source
final _authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    firebaseAuth: ref.watch(_firebaseAuthProvider),
    googleSignIn: ref.watch(_googleSignInProvider),
    firestore: ref.watch(_firestoreProvider),
  );
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(_authRemoteDataSourceProvider),
  );
});

// Auth state stream provider
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

// Current user provider
final currentUserProvider = FutureProvider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getCurrentUser();
});

// Sign in command
final signInWithGoogleProvider = FutureProvider<UserEntity?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.signInWithGoogle();
});

// Sign out command
final signOutProvider = FutureProvider<void>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.signOut();
});