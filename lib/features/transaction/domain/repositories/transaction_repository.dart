import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> addTransaction(TransactionEntity transaction, String contactId);
  Future<void> updateTransaction(TransactionEntity transaction, String contactId);
  Future<void> deleteTransaction(String id, String contactId);
}
