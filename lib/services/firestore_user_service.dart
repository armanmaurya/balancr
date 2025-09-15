import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class FirestoreUserService {
  FirestoreUserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Future<void> upsertUser(fb.User user) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'provider': user.providerData.isNotEmpty ? user.providerData.first.providerId : 'unknown',
      'lastSignIn': now,
    };
    if (!snap.exists) {
      data['createdAt'] = now;
    }
    await ref.set(data, SetOptions(merge: true));
  }
}
