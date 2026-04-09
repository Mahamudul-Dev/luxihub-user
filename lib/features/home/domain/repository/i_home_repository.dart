import '../../../../core/domain/entities/service_provider_entity.dart';

abstract interface class IHomeRepository {
  /// Returns up to [limit] service providers.
  Future<List<ServiceProviderEntity>> getServiceProviders({int limit = 10});
}
