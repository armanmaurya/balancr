class UserEntity {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phone;
  final String provider;
  final DateTime? createdAt;
  final DateTime? lastSignIn;
  final double totalGiven;
  final double totalTaken;
  final double netBalance;

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phone,
    required this.provider,
    this.createdAt,
    this.lastSignIn,
    this.totalGiven = 0.0,
    this.totalTaken = 0.0,
    this.netBalance = 0.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, displayName: $displayName, phone: $phone, provider: $provider, netBalance: $netBalance)';
  }

  UserEntity copyWith({
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
    return UserEntity(
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
