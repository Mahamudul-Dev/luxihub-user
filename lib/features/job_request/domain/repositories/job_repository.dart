import '../../../../core/domain/entities/job_request.dart';

abstract interface class JobRepository {
  Future<JobRequest> postJob({
    required String clientId,
    required String providerId,
    required String category,
    required String description,
    required double clientLat,
    required double clientLng,
    double? offerPrice,
  });

  Future<List<JobRequest>> getMyJobs(String clientId);

  Stream<String> watchJobStatus(String jobId);

  Future<void> updateJobStatus(String jobId, String status);

  Future<void> deleteJob(String jobId);

  Future<void> saveTransaction({
    required String jobId,
    required String clientId,
    required String providerId,
    required double amount,
    required String paymentMethod,
    required String status,
    String? stripePaymentIntentId,
  });
}
