import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Always show the account chooser by clearing any cached account
      await _googleSignIn.signOut();
      
      // Optionally revoke to ensure re-consent on some devices (ignore errors)
      try { 
        await _googleSignIn.disconnect(); 
      } catch (_) {}

      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User aborted the sign-in
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) return null;
      
      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Get current user
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  /// Stream of authentication state changes
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  // Firestore operations
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserFinancialDataStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  /// Create or update user profile information (excluding balance fields)
  Future<void> upsertUser(UserEntity user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phone': user.phone,
      // Note: totalGiven, totalTaken, and netBalance are managed server-side
      // and cannot be directly updated by client code per security rules
    }, SetOptions(merge: true));
  }

  /// Create initial user document with default balance values (for new users only)
  Future<void> createUserWithDefaults(UserEntity user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phone': user.phone,
      'totalGiven': 0.0,
      'totalTaken': 0.0,
      'netBalance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check if user document exists
  Future<bool> userExists(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }

  /// Smart upsert - creates new user with defaults or updates existing user profile
  Future<void> smartUpsertUser(UserEntity user) async {
    final exists = await userExists(user.uid);
    if (exists) {
      // User exists, just update profile info
      await upsertUser(user);
    } else {
      // New user, create with default balance values
      await createUserWithDefaults(user);
    }
  }
}