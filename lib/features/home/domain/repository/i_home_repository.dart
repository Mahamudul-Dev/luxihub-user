import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';

abstract interface class IHomeRepository {
  Future<List<ServiceProviderEntity>> getServiceProviders({int limit = 10});
  Future<List<CategoryEntity>> getCategories();
}
