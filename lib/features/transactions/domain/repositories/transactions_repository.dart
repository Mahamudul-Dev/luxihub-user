import 'dart:typed_data';

import '../entities/transaction_entity.dart';

abstract interface class TransactionsRepository {
  Future<List<TransactionEntity>> getTransactions(String clientId);

  Future<Uint8List> getInvoicePdf(String transactionId);
}
