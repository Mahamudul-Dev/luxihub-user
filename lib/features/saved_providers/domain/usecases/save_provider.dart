import '../repositories/saved_providers_repository.dart';

class SaveProvider {
  final SavedProvidersRepository _repo;
  const SaveProvider(this._repo);

  Future<void> call(String userId, String providerId) =>
      _repo.saveProvider(userId, providerId);
}
