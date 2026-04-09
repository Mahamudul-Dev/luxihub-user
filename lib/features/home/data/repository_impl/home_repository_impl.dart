import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/dummy/dummy.dart';
import '../../domain/repository/i_home_repository.dart';

class HomeRepositoryImpl implements IHomeRepository {
  const HomeRepositoryImpl();

  @override
  Future<List<ServiceProviderEntity>> getServiceProviders({
    int limit = 10,
  }) async {
    // TODO: replace with real remote/local data source call
    await Future.delayed(const Duration(milliseconds: 500));
    return Dummy.providers.take(limit).toList();
  }
}
