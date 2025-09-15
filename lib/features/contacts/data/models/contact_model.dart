import '../../domain/entities/contact_entity.dart';

class ContactModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final bool isRegistered;
  final String? linkedUserId;

  ContactModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.isRegistered = false,
    this.linkedUserId,
  });

  /// Convert Firestore document to ContactModel
  factory ContactModel.fromMap(Map<String, dynamic> map, String docId) {
    return ContactModel(
      id: docId,
      name: map['name'] ?? '',
      phone: map['phone'],
      email: map['email'],
      isRegistered: (map['isRegistered'] as bool?) ?? false,
      linkedUserId: map['linkedUserId'] as String?,
    );
  }

  /// Convert ContactModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'isRegistered': isRegistered,
      'linkedUserId': linkedUserId,
    };
  }

  /// Convert ContactModel to domain entity
  ContactEntity toEntity() {
    return ContactEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
      isRegistered: isRegistered,
      linkedUserId: linkedUserId,
    );
  }

  /// Convert domain entity to ContactModel
  factory ContactModel.fromEntity(ContactEntity entity) {
    return ContactModel(
      id: entity.id ?? '',
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      isRegistered: entity.isRegistered,
      linkedUserId: entity.linkedUserId,
    );
  }
}
