import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../services/firestore_user_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FirestoreUserService _firestoreUserService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required FirestoreUserService firestoreUserService,
  }) : _remoteDataSource = remoteDataSource,
       _firestoreUserService = firestoreUserService;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      if (userModel == null) return null;

      // Upsert user to Firestore
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await _firestoreUserService.upsertUser(firebaseUser);
      }

      return userModel.toEntity();
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = _remoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _remoteDataSource.authStateChanges().map((userModel) {
      return userModel?.toEntity();
    });
  }
}