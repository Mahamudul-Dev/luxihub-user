import '../repositories/job_repository.dart';

class CancelJob {
  final JobRepository _repository;
  const CancelJob(this._repository);

  Future<void> call(String jobId) => _repository.deleteJob(jobId);
}
