import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/fcm_token_entity.dart';

class FCMTokenModel extends FCMTokenEntity {
  const FCMTokenModel({
    required String token,
    required String platform,
    required DateTime createdAt,
    String? deviceId,
  }) : super(
          token: token,
          platform: platform,
          createdAt: createdAt,
          deviceId: deviceId,
        );

  /// Create FCMTokenModel from Firestore document
  factory FCMTokenModel.fromFirestore(Map<String, dynamic> data) {
    return FCMTokenModel(
      token: data['token'] as String,
      platform: data['platform'] as String,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      deviceId: data['deviceId'] as String?,
    );
  }

  /// Convert FCMTokenModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'token': token,
      'platform': platform,
      'createdAt': Timestamp.fromDate(createdAt),
      'deviceId': deviceId,
    };
  }

  /// Convert FCMTokenModel to domain entity
  FCMTokenEntity toEntity() {
    return FCMTokenEntity(
      token: token,
      platform: platform,
      createdAt: createdAt,
      deviceId: deviceId,
    );
  }

  /// Create FCMTokenModel from domain entity
  factory FCMTokenModel.fromEntity(FCMTokenEntity entity) {
    return FCMTokenModel(
      token: entity.token,
      platform: entity.platform,
      createdAt: entity.createdAt,
      deviceId: entity.deviceId,
    );
  }

  /// Helper method to parse Firestore timestamps
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  @override
  FCMTokenModel copyWith({
    String? token,
    String? platform,
    DateTime? createdAt,
    String? deviceId,
  }) {
    return FCMTokenModel(
      token: token ?? this.token,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}