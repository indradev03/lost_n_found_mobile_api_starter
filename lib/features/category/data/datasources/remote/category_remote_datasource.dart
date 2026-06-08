import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/api/api_client.dart';
import 'package:lost_n_found/core/api/api_endpoints.dart';
import 'package:lost_n_found/features/category/data/datasources/category_datasource.dart';
import 'package:lost_n_found/features/category/data/models/category_api_model.dart';

final categoryRemoteDatasourceProvider = Provider<ICategoryRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return CategoryRemoteDatasource(apiClient: apiClient);
});

class CategoryRemoteDatasource implements ICategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<bool> createCategory(CategoryApiModel category) async {
    final response = await _apiClient.post(
      ApiEndpoints.categories,
      data: category.toJson(),
    );

    return response.data['success'];
  }

  @override
  Future<List<CategoryApiModel>> getAllCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);

    final data = response.data['data'] as List;

    return data.map((json) => CategoryApiModel.fromJson(json)).toList();
  }

  @override
  Future<CategoryApiModel?> getCategoryById(String categoryId) async {
    final response = await _apiClient.get(
      ApiEndpoints.categoryById(categoryId),
    );

    return CategoryApiModel.fromJson(response.data['data']);
  }

  @override
  Future<bool> updateCategory(CategoryApiModel category) async {
    final response = await _apiClient.put(
      ApiEndpoints.categoryById(category.id!),
      data: category.toJson(),
    );

    return response.data['success'];
  }

  @override
  Future<bool> deleteCategory(String categoryId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.categoryById(categoryId),
    );

    return response.data['success'];
  }
}
