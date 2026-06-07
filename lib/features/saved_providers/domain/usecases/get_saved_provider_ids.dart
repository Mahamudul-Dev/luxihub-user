import '../repositories/saved_providers_repository.dart';

class GetSavedProviderIds {
  final SavedProvidersRepository _repo;
  const GetSavedProviderIds(this._repo);

  Future<Set<String>> call(String userId) => _repo.getSavedProviderIds(userId);
}
