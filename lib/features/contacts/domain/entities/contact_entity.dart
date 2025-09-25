class ContactEntity {
  final String? id;
  final String name;
  final String? phone;
  final num balance;

  ContactEntity({
    this.id,
    required this.name,
    this.phone,
    this.balance = 0,
  });
}
