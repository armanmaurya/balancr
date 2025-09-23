class FCMTokenEntity {
  final String token;
  final String platform;
  final DateTime createdAt;
  final String? deviceId;

  const FCMTokenEntity({
    required this.token,
    required this.platform,
    required this.createdAt,
    this.deviceId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FCMTokenEntity && other.token == token;
  }

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() {
    return 'FCMTokenEntity(token: $token, platform: $platform, createdAt: $createdAt, deviceId: $deviceId)';
  }

  FCMTokenEntity copyWith({
    String? token,
    String? platform,
    DateTime? createdAt,
    String? deviceId,
  }) {
    return FCMTokenEntity(
      token: token ?? this.token,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}