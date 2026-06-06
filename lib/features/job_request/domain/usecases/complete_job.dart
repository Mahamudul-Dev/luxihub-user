import '../repositories/job_repository.dart';

class CompleteJob {
  final JobRepository _repository;
  const CompleteJob(this._repository);

  Future<void> call(String jobId) =>
      _repository.updateJobStatus(jobId, 'completed');
}
