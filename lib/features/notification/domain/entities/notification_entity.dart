class NotificationEntity {
  final String id;
  final String type; // transaction | reminder | contact | system | group
  final String title;
  final String? body;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId; // e.g., transaction ID, contact ID, group ID
  final String? relatedType; // tells frontend what kind of relatedId it is
  final Map<String, dynamic>? extra; // free-form JSON for additional info

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
    this.relatedType,
    this.extra,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationEntity(id: $id, type: $type, title: $title, isRead: $isRead, createdAt: $createdAt)';
  }

  NotificationEntity copyWith({
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
    return NotificationEntity(
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

/// Notification types
class NotificationType {
  static const String transaction = 'transaction';
  static const String reminder = 'reminder';
  static const String contact = 'contact';
  static const String system = 'system';
  static const String group = 'group';
}