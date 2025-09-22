import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    String? id,
    required double amount,
    required bool isGiven,
    required DateTime date,
    String note = '',
    required String fromUserId,
    String? toUserId,
    String? toContactId,
  }) : super(
         id: id,
         amount: amount,
         isGiven: isGiven,
         date: date,
         note: note,
         fromUserId: fromUserId,
         toUserId: toUserId,
         toContactId: toContactId,
       );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // amount can be num or String
    final amount =
        json['amount'] is num
            ? (json['amount'] as num).toDouble()
            : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0;

    // date can be String ISO, Timestamp, or DateTime
    final rawDate = json['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: json['id'] as String?,
      amount: amount,
      isGiven: (json['isGiven'] as bool?) ?? false,
      date: parsedDate,
      note: json['note'] as String? ?? '',
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      toContactId: json['toContactId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'isGiven': isGiven,
      'date': date.toIso8601String(),
      'note': note,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'toContactId': toContactId,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      fromUserId: entity.fromUserId,
      toUserId: entity.toUserId,
      toContactId: entity.toContactId,
      id: entity.id,
      amount: entity.amount,
      isGiven: entity.isGiven,
      date: entity.date,
      note: entity.note,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      isGiven: isGiven,
      date: date,
      note: note,
      fromUserId: fromUserId,
      toUserId: toUserId,
      toContactId: toContactId,
    );
  }
}
