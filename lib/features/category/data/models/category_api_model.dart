import 'package:lost_n_found/features/category/domain/entities/category_entity.dart';

class CategoryApiModel {
  final String? id;
  final String name;
  final String? description;
  final String? status;

  CategoryApiModel({
    this.id,
    required this.name,
    this.description,
    this.status,
  });

  // From JSON
  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }

  // To Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: id,
      name: name,
      description: description,
      status: status,
    );
  }

  // From Entity
  factory CategoryApiModel.fromEntity(CategoryEntity entity) {
    return CategoryApiModel(
      id: entity.categoryId,
      name: entity.name,
      description: entity.description,
      status: entity.status,
    );
  }

  // List Conversion
  static List<CategoryEntity> toEntityList(List<CategoryApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
