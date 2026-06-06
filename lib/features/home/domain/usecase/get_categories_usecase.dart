import '../../../../core/domain/entities/category_entity.dart';
import '../repository/i_home_repository.dart';

class GetCategoriesUseCase {
  final IHomeRepository _repository;
  const GetCategoriesUseCase(this._repository);

  Future<List<CategoryEntity>> call() => _repository.getCategories();
}
