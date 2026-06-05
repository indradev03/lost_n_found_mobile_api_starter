import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/api/api_client.dart';
import 'package:lost_n_found/core/api/api_endpoints.dart';
import 'package:lost_n_found/features/batch/data/datasources/batch_datasource.dart';
import 'package:lost_n_found/features/batch/data/models/batch_api_model.dart';

final batchRemoteDatasourceProvider = Provider<IBatchRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return BatchRemoteDatasource(apiClient: apiClient);
});

class BatchRemoteDatasource implements IBatchRemoteDataSource {
  final ApiClient _apiClient;
  BatchRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<bool> createBatch(BatchApiModel batch) async {
    final response = await _apiClient.post(
      ApiEndpoints.batches,
      data: batch.toJson(),
    );
    return response.data['success'];
  }

  @override
  Future<bool> deleteBatch(String batchId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BatchApiModel>> getAllBatches() async {
    final response = await _apiClient.get(ApiEndpoints.batches);
    final data = response.data['data'] as List;
    return data.map((json) => BatchApiModel.fromJson(json)).toList();
  }

  @override
  Future<BatchApiModel?> getBatchById(String batchId) async {
    final response = await _apiClient.get(ApiEndpoints.batchById(batchId));
    return BatchApiModel.fromJson(response.data['data']);
  }

  @override
  Future<bool> updateBatch(BatchApiModel batch) {
    throw UnimplementedError();
  }
}
