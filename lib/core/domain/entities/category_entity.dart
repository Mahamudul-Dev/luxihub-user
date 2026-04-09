class CategoryEntity {
  final String id;
  final String name;
  final String imageUrl; // URL to category icon/image
  final int? serviceCount; // Number of service providers in this category
  
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.serviceCount,

  });
}