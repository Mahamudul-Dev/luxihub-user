import '../repositories/job_repository.dart';

class UpdateJobStatus {
  final JobRepository _repository;
  const UpdateJobStatus(this._repository);

  Future<void> call(String jobId, String status) =>
      _repository.updateJobStatus(jobId, status);
}
