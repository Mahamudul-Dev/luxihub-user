import '../../../../core/domain/entities/job_request.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource _dataSource;
  const JobRepositoryImpl(this._dataSource);

  @override
  Future<JobRequest> postJob({
    required String clientId,
    required String providerId,
    required String category,
    required String description,
    required double clientLat,
    required double clientLng,
    double? offerPrice,
    List<dynamic> attachments = const [],
  }) =>
      _dataSource.postJob(
        clientId: clientId,
        providerId: providerId,
        category: category,
        description: description,
        clientLat: clientLat,
        clientLng: clientLng,
        offerPrice: offerPrice,
        attachments: attachments,
      );

  @override
  Future<List<JobRequest>> getMyJobs(String clientId) =>
      _dataSource.getMyJobs(clientId);

  @override
  Stream<String> watchJobStatus(String jobId) =>
      _dataSource.watchJobStatus(jobId);

  @override
  Future<void> updateJobStatus(String jobId, String status) =>
      _dataSource.updateJobStatus(jobId, status);

  @override
  Future<void> deleteJob(String jobId) => _dataSource.deleteJob(jobId);

  @override
  Future<void> saveTransaction({
    required String jobId,
    required String clientId,
    required String providerId,
    required double amount,
    required String paymentMethod,
    required String status,
    String? stripePaymentIntentId,
  }) =>
      _dataSource.saveTransaction(
        jobId: jobId,
        clientId: clientId,
        providerId: providerId,
        amount: amount,
        paymentMethod: paymentMethod,
        status: status,
        stripePaymentIntentId: stripePaymentIntentId,
      );
}
