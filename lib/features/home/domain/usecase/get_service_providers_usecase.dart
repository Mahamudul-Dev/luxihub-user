import '../../../../core/domain/entities/service_provider_entity.dart';
import '../repository/i_home_repository.dart';

class GetServiceProvidersUseCase {
  final IHomeRepository _repository;

  const GetServiceProvidersUseCase(this._repository);

  Future<List<ServiceProviderEntity>> call({int limit = 10}) =>
      _repository.getServiceProviders(limit: limit);
}
