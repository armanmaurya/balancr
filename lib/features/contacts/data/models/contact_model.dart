  import '../../domain/entities/contact_entity.dart';

  class ContactModel {
    final String id;
    final String name;
    final String? phone;
    final num balance; // Default balance to 0

    ContactModel({
      required this.id,
      required this.name,
      this.phone,
      this.balance = 0,
    });

    /// Convert Firestore document to ContactModel
    factory ContactModel.fromMap(Map<String, dynamic> map, String docId) {
      return ContactModel(
        id: docId,
        name: map['name'] ?? '',
        phone: map['phone'],
        balance: map['balance'] ?? 0,
      );
    }

    /// Convert ContactModel to Firestore map
    Map<String, dynamic> toMap() {
      return {
        'name': name,
        'phone': phone,
      };
    }

    /// Convert ContactModel to domain entity
    ContactEntity toEntity() {
      return ContactEntity(
        id: id,
        name: name,
        phone: phone,
        balance: balance,
      );
    }

    /// Convert domain entity to ContactModel
    factory ContactModel.fromEntity(ContactEntity entity) {
      return ContactModel(
        id: entity.id ?? '',
        name: entity.name,
        phone: entity.phone,
        balance: entity.balance,
      );
    }
  }
