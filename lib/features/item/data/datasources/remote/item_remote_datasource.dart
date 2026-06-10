import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/api/api_client.dart';
import 'package:lost_n_found/core/api/api_endpoints.dart';
import 'package:lost_n_found/core/services/storage/token_service.dart';
import 'package:lost_n_found/features/item/data/datasources/item_datasource.dart';

final itemRemoteDatasourceProvider = Provider<IItemRemoteDatasource>((ref) {
  return ItemRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ItemRemoteDatasource implements IItemRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ItemRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<String> uploadImage(File image) async {
    // c:asd/asd/a.jpg
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'itemPhoto': MultipartFile.fromFileSync(image.path, filename: fileName),
    });

    // get token from token service
    final token = _tokenService.getTOken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.itemUploadPhoto,
      formData: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['success'];
  }

  @override
  Future<String> uplaodVideo(File video) async {
    final fileName = video.path.split('/').last;
    final formData = FormData.fromMap({
      'itemVideo': MultipartFile.fromFileSync(video.path, filename: fileName),
    });

    // get token from token service
    final token = _tokenService.getTOken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.itemUploadVideo,
      formData: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['success'];
  }
}
