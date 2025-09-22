import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../features/user/data/models/user_model.dart';
import '../features/user/domain/entities/user_entity.dart';

class FirestoreUserService {
  FirestoreUserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Future<void> upsertUser(fb.User user) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    final userModel = UserModel.fromFirebaseUser(user);
    
    final data = snap.exists 
        ? userModel.toFirestoreForUpdate()
        : userModel.toFirestoreForCreate();
    
    await ref.set(data, SetOptions(merge: true));
  }

  /// Get user by UID
  Future<UserEntity?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserModel.fromFirestore(doc.data()!).toEntity();
  }

  /// Get current user
  Future<UserEntity?> getCurrentUser() async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    return getUserById(currentUser.uid);
  }

  /// Update user profile
  Future<void> updateUser(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    await _users.doc(user.uid).update(userModel.toFirestoreForUpdate());
  }

  /// Delete user
  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }
}
