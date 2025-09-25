import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phone,
    required String provider,
    DateTime? createdAt,
    DateTime? lastSignIn,
    double totalGiven = 0.0,
    double totalTaken = 0.0,
    double netBalance = 0.0,
  }) : super(
          uid: uid,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
          phone: phone,
          provider: provider,
          createdAt: createdAt,
          lastSignIn: lastSignIn,
          totalGiven: totalGiven,
          totalTaken: totalTaken,
          netBalance: netBalance,
        );

  /// Create UserModel from Firebase Auth User
  factory UserModel.fromFirebaseUser(fb.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      phone: user.phoneNumber,
      provider: user.providerData.isNotEmpty 
          ? user.providerData.first.providerId 
          : 'unknown',
      lastSignIn: DateTime.now(),
      totalGiven: 0.0,
      totalTaken: 0.0,
      netBalance: 0.0,
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      phone: data['phone'] as String?,
      provider: data['provider'] as String? ?? 'unknown',
      createdAt: _parseTimestamp(data['createdAt']),
      lastSignIn: _parseTimestamp(data['lastSignIn']),
      totalGiven: (data['totalGiven'] as num?)?.toDouble() ?? 0.0,
      totalTaken: (data['totalTaken'] as num?)?.toDouble() ?? 0.0,
      netBalance: (data['netBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert UserModel to Firestore document for creation
  Map<String, dynamic> toFirestoreForCreate() {
    final now = FieldValue.serverTimestamp();
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phone': phone,
      'provider': provider,
      'createdAt': now,
      'lastSignIn': now,
      'totalGiven': totalGiven,
      'totalTaken': totalTaken,
      'netBalance': netBalance,
    };
  }

  /// Convert UserModel to Firestore document for update
  /// Note: Balance fields are updated via transaction operations on the client
  Map<String, dynamic> toFirestoreForUpdate() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phone': phone,
      'provider': provider,
      'lastSignIn': FieldValue.serverTimestamp(),
      // Balance fields (totalGiven, totalTaken, netBalance) are excluded
      // as they cannot be updated by client code per security rules
    };
  }

  /// Convert UserModel to domain entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      phone: phone,
      provider: provider,
      createdAt: createdAt,
      lastSignIn: lastSignIn,
      totalGiven: totalGiven,
      totalTaken: totalTaken,
      netBalance: netBalance,
    );
  }

  /// Create UserModel from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoURL: entity.photoURL,
      phone: entity.phone,
      provider: entity.provider,
      createdAt: entity.createdAt,
      lastSignIn: entity.lastSignIn,
      totalGiven: entity.totalGiven,
      totalTaken: entity.totalTaken,
      netBalance: entity.netBalance,
    );
  }

  /// Helper method to parse Firestore timestamps
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }

  @override
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phone,
    String? provider,
    DateTime? createdAt,
    DateTime? lastSignIn,
    double? totalGiven,
    double? totalTaken,
    double? netBalance,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      totalGiven: totalGiven ?? this.totalGiven,
      totalTaken: totalTaken ?? this.totalTaken,
      netBalance: netBalance ?? this.netBalance,
    );
  }
}
