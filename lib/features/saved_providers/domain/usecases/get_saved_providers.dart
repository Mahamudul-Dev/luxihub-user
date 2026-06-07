import '../../../../core/domain/entities/service_provider_entity.dart';
import '../repositories/saved_providers_repository.dart';

class GetSavedProviders {
  final SavedProvidersRepository _repo;
  const GetSavedProviders(this._repo);

  Future<List<ServiceProviderEntity>> call(String userId) =>
      _repo.getSavedProviders(userId);
}
