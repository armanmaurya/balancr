import 'transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class People {
  late String name;
  String? phone;
  String id;

  People({
    required this.name,
    this.phone,
    required this.id,
  });

  factory People.fromMap(Map<String, dynamic> map, {required String id}) {
    return People(
      name: map['name'] as String,
      phone: map['phone'] as String?,
      // Transactions will be populated separately from subcollection
      id: id,
    );
  }

  // Create a People from a Firestore document
  factory People.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return People(
      id: doc.id,
      // Prefer 'name', fall back to common alternatives if present
      name: (data['name'] as String?) ?? (data['displayName'] as String?) ?? '',
      phone: data['phone'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}
