class TransactionEntity {
  final String? id;
  final double amount;
  final bool isGiven;
  final DateTime date;
  final String note;
  final String fromUserId;
  final String? toUserId;
  final String? toContactId;

  TransactionEntity({

    this.id,
    required this.amount,
    required this.isGiven,
    required this.date,
    this.note = '',
    required this.fromUserId,
    this.toUserId,
    this.toContactId,
  });
}
