import '../repositories/job_repository.dart';

class SaveTransactionParams {
  final String jobId;
  final String clientId;
  final String providerId;
  final double amount;
  final String paymentMethod; // 'stripe' | 'cash'
  final String status; // 'pending' | 'completed' | 'failed'
  final String? stripePaymentIntentId;

  const SaveTransactionParams({
    required this.jobId,
    required this.clientId,
    required this.providerId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.stripePaymentIntentId,
  });
}

class SaveTransaction {
  final JobRepository _repository;
  const SaveTransaction(this._repository);

  Future<void> call(SaveTransactionParams params) =>
      _repository.saveTransaction(
        jobId: params.jobId,
        clientId: params.clientId,
        providerId: params.providerId,
        amount: params.amount,
        paymentMethod: params.paymentMethod,
        status: params.status,
        stripePaymentIntentId: params.stripePaymentIntentId,
      );
}
