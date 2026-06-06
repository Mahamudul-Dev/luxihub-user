import '../../../../core/domain/entities/category_entity.dart';

class CategoryModel {
  static CategoryEntity fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      serviceCount: json['service_count'] as int?,
    );
  }
}
