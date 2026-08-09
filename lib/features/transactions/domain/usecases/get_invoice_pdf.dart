import 'dart:typed_data';

import '../repositories/transactions_repository.dart';

class GetInvoicePdf {
  final TransactionsRepository _repository;
  const GetInvoicePdf(this._repository);

  Future<Uint8List> call(String transactionId) =>
      _repository.getInvoicePdf(transactionId);
}
