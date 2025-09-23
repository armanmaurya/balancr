import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    super.body,
    required super.createdAt,
    super.isRead,
    super.relatedId,
    super.relatedType,
    super.extra,
  });

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return NotificationModel(
      id: documentId, // Use document ID as the notification ID
      type: data['type'] as String,
      title: data['title'] as String,
      body: data['body'] as String?,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      relatedId: data['relatedId'] as String?,
      relatedType: data['relatedType'] as String?,
      extra: data['extra'] as Map<String, dynamic>?,
    );
  }

  /// Convert NotificationModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'extra': extra,
    };
  }

  /// Convert NotificationModel to domain entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead,
      relatedId: relatedId,
      relatedType: relatedType,
      extra: extra,
    );
  }

  /// Create NotificationModel from domain entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
      relatedId: entity.relatedId,
      relatedType: entity.relatedType,
      extra: entity.extra,
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
  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? extra,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      extra: extra ?? this.extra,
    );
  }
}