import '../repositories/saved_providers_repository.dart';

class UnsaveProvider {
  final SavedProvidersRepository _repo;
  const UnsaveProvider(this._repo);

  Future<void> call(String userId, String providerId) =>
      _repo.unsaveProvider(userId, providerId);
}
