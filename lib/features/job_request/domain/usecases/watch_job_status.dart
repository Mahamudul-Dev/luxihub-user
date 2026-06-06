import '../repositories/job_repository.dart';

class WatchJobStatus {
  final JobRepository _repository;
  const WatchJobStatus(this._repository);

  Stream<String> call(String jobId) => _repository.watchJobStatus(jobId);
}
