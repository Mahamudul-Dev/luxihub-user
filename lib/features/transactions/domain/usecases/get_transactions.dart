import '../entities/transaction_entity.dart';
import '../repositories/transactions_repository.dart';

class GetTransactions {
  final TransactionsRepository _repository;
  const GetTransactions(this._repository);

  Future<List<TransactionEntity>> call(String clientId) =>
      _repository.getTransactions(clientId);
}
