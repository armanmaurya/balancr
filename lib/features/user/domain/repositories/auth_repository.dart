import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> authStateChanges();
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserFinancialDataStream(String userId);
}