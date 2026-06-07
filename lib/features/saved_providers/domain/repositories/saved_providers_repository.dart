import '../../../../core/domain/entities/service_provider_entity.dart';

abstract interface class SavedProvidersRepository {
  Future<Set<String>> getSavedProviderIds(String userId);
  Future<List<ServiceProviderEntity>> getSavedProviders(String userId);
  Future<void> saveProvider(String userId, String providerId);
  Future<void> unsaveProvider(String userId, String providerId);
}
