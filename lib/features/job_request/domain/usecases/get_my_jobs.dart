import '../../../../core/domain/entities/job_request.dart';
import '../repositories/job_repository.dart';

class GetMyJobs {
  final JobRepository _repository;
  const GetMyJobs(this._repository);

  Future<List<JobRequest>> call(String clientId) =>
      _repository.getMyJobs(clientId);
}
