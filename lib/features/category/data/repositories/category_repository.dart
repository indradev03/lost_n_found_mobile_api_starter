import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/error/failures.dart';
import 'package:lost_n_found/core/services/connectivity/network_info.dart';

import 'package:lost_n_found/features/category/data/datasources/category_datasource.dart';
import 'package:lost_n_found/features/category/data/datasources/local/category_local_datasource.dart';
import 'package:lost_n_found/features/category/data/datasources/remote/category_remote_datasource.dart';

import 'package:lost_n_found/features/category/data/models/category_api_model.dart';
import 'package:lost_n_found/features/category/data/models/category_hive_model.dart';

import 'package:lost_n_found/features/category/domain/entities/category_entity.dart';
import 'package:lost_n_found/features/category/domain/repositories/category_repository.dart';

/// Provider
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final localDataSource = ref.read(categoryLocalDatasourceProvider);
  final remoteDataSource = ref.read(categoryRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return CategoryRepository(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

/// Repository
class CategoryRepository implements ICategoryRepository {
  final ICategoryLocalDataSource _localDataSource;
  final ICategoryRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  CategoryRepository({
    required ICategoryLocalDataSource localDataSource,
    required ICategoryRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  // ================= CREATE =================
  @override
  Future<Either<Failure, bool>> createCategory(CategoryEntity category) async {
    try {
      final model = CategoryHiveModel.fromEntity(category);

      final result = await _localDataSource.createCategory(model);

      if (result) {
        return const Right(true);
      }

      return const Left(
        LocalDatabaseFailure(message: "Failed to create category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ================= DELETE =================
  @override
  Future<Either<Failure, bool>> deleteCategory(String categoryId) async {
    try {
      final result = await _localDataSource.deleteCategory(categoryId);

      if (result) {
        return const Right(true);
      }

      return const Left(
        LocalDatabaseFailure(message: "Failed to delete category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ================= GET ALL (OFFLINE-FIRST) =================
  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _remoteDataSource.getAllCategories();

        final result = CategoryApiModel.toEntityList(apiModels);

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: (e.response?.data is Map<String, dynamic>)
                ? e.response?.data['message'] ?? 'Failed to fetch categories'
                : e.message ?? 'Failed to fetch categories',
          ),
        );
      }
    } else {
      try {
        final models = await _localDataSource.getAllCategories();

        final entities = CategoryHiveModel.toEntityList(models);

        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // ================= GET BY ID =================
  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(
    String categoryId,
  ) async {
    try {
      final model = await _localDataSource.getCategoryById(categoryId);

      if (model != null) {
        return Right(model.toEntity());
      }

      return const Left(LocalDatabaseFailure(message: 'Category not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // ================= UPDATE =================
  @override
  Future<Either<Failure, bool>> updateCategory(CategoryEntity category) async {
    try {
      final model = CategoryHiveModel.fromEntity(category);

      final result = await _localDataSource.updateCategory(model);

      if (result) {
        return const Right(true);
      }

      return const Left(
        LocalDatabaseFailure(message: "Failed to update category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
