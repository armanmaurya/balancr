import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      if (userModel == null) return null;

      // Upsert user to Firestore using data source
      final userEntity = userModel.toEntity();
      await _remoteDataSource.upsertUser(userEntity);

      return userEntity;
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

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserFinancialDataStream(String userId) {
    return _remoteDataSource.getUserFinancialDataStream(userId);
  }
}