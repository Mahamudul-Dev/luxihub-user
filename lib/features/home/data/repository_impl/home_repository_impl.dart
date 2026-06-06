import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../domain/repository/i_home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements IHomeRepository {
  final HomeRemoteDataSource _dataSource;
  const HomeRepositoryImpl(this._dataSource);

  @override
  Future<List<ServiceProviderEntity>> getServiceProviders({int limit = 10}) =>
      _dataSource.getServiceProviders(limit: limit);

  @override
  Future<List<CategoryEntity>> getCategories() =>
      _dataSource.getCategories();
}
