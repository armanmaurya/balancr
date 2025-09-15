class Transaction {
  double amount;
  bool isGiven;
  DateTime date;
  String note;
  String id;

  Transaction({
    required this.amount,
    required this.isGiven,
    required this.date,
    this.note = '',
    required this.id,
  });

  factory Transaction.fromMap(Map<String, dynamic> map, {required String id}) {
    final dynamic dateVal = map['date'];
    DateTime parsedDate;
    if (dateVal is DateTime) {
      parsedDate = dateVal;
    } else if (dateVal is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
    } else if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else {
      // For Firestore Timestamp, the provider will pass a DateTime already
      parsedDate = DateTime.now();
    }
    return Transaction(
      amount: (map['amount'] as num).toDouble(),
      isGiven: map['isGiven'] as bool,
      date: parsedDate,
      note: (map['note'] as String?) ?? '',
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'isGiven': isGiven,
      'date': date,
      'note': note,
    };
  }

  @override
  String toString() {
    return 'Transaction(amount: $amount, isGiven: $isGiven, date: $date, note: $note, id: $id)';
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedAmount {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
