import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Sin Nombre';
    return CategoryModel(
      id: name, // Usamos el nombre como ID para el filtro
      name: name,
    );
  }
}