import 'package:hive/hive.dart';
import 'transaction.dart';

part 'person.g.dart';

@HiveType(typeId: 1)
class Person extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late List<Transaction> transactions;

  // Add optional contactId and phone fields for contacts integration
  @HiveField(2)
  String? contactId;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String id;

  Person({
    required this.name,
    List<Transaction>? transactions,
    this.contactId,
    this.phone,
    required this.id,
  }) : transactions = transactions ?? [];

  double get balance {
    return transactions.fold(0.0, (sum, tx) {
      return tx.isGiven ? sum - tx.amount : sum + tx.amount;
    });
  }

  double get totalGiven {
    return transactions
        .where((tx) => tx.isGiven)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalReceived {
    return transactions
        .where((tx) => !tx.isGiven)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
}
