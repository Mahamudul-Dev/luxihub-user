import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../domain/repositories/saved_providers_repository.dart';
import '../datasources/saved_providers_datasource.dart';

class SavedProvidersRepositoryImpl implements SavedProvidersRepository {
  final SavedProvidersDatasource _datasource;
  const SavedProvidersRepositoryImpl(this._datasource);

  @override
  Future<Set<String>> getSavedProviderIds(String userId) =>
      _datasource.getSavedProviderIds(userId);

  @override
  Future<List<ServiceProviderEntity>> getSavedProviders(String userId) =>
      _datasource.getSavedProviders(userId);

  @override
  Future<void> saveProvider(String userId, String providerId) =>
      _datasource.saveProvider(userId, providerId);

  @override
  Future<void> unsaveProvider(String userId, String providerId) =>
      _datasource.unsaveProvider(userId, providerId);
}
