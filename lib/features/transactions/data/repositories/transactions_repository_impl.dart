import 'dart:typed_data';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_datasource.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsDatasource _datasource;
  const TransactionsRepositoryImpl(this._datasource);

  @override
  Future<List<TransactionEntity>> getTransactions(String clientId) =>
      _datasource.getTransactions(clientId);

  @override
  Future<Uint8List> getInvoicePdf(String transactionId) =>
      _datasource.getInvoicePdf(transactionId);
}
