import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  bool isGiven;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String note;

  Transaction({
    required this.amount,
    required this.isGiven,
    required this.date,
    this.note = '',
  });

  @override
  String toString() {
    return 'Transaction(amount: $amount, isGiven: $isGiven, date: $date, note: $note)';
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedAmount {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
