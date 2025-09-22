class ContactEntity {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final bool isRegistered;
  final String? linkedUserId;
  final num balance;

  ContactEntity({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.isRegistered = false,
    this.linkedUserId,
    this.balance = 0,
  });
}
