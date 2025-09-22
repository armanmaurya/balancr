import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource remoteDatasource;

  TransactionRepositoryImpl({required this.remoteDatasource});

  @override
  Future<void> addTransaction(TransactionEntity transaction, String contactId) async {
    final model = TransactionModel.fromEntity(transaction);
    await remoteDatasource.addTransaction(model, contactId);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final models = await remoteDatasource.getTransactions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction, String contactId) async {
    final model = TransactionModel.fromEntity(transaction);
    await remoteDatasource.updateTransaction(model, contactId);
  }

  @override
  Future<void> deleteTransaction(String id, String contactId) async {
    await remoteDatasource.deleteTransaction(id, contactId);
  }
}
