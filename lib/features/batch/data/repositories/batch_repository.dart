import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/error/failures.dart';
import 'package:lost_n_found/core/services/connectivity/network_info.dart';
import 'package:lost_n_found/features/batch/data/datasources/batch_datasource.dart';
import 'package:lost_n_found/features/batch/data/datasources/local/batch_local_datasource.dart';
import 'package:lost_n_found/features/batch/data/datasources/remote/batch_remote_datasource.dart';
import 'package:lost_n_found/features/batch/data/models/batch_api_model.dart';
import 'package:lost_n_found/features/batch/data/models/batch_hive_model.dart';
import 'package:lost_n_found/features/batch/domain/entities/batch_entity.dart';
import 'package:lost_n_found/features/batch/domain/repositories/batch_repository.dart';

// Create provider
final batchRepositoryProvider = Provider<IBatchRepository>((ref) {
  final localDataSource = ref.read(batchLocalDatasourceProvider);
  final remoteDataSource = ref.read(batchRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return BatchRepository(
    localDataSource: localDataSource,
    remoteDatSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

class BatchRepository implements IBatchRepository {
  final IBatchLocalDataSource _localDataSource;
  final IBatchRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  BatchRepository({
    required IBatchLocalDataSource localDataSource,
    required IBatchRemoteDataSource remoteDatSource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDatSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createBatch(BatchEntity batch) async {
    try {
      // conversion
      // entity lai model ma convert gara
      final batchModel = BatchHiveModel.fromEntity(batch);
      final result = await _localDataSource.createBatch(batchModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to create a batch"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBatch(String batchId) async {
    try {
      final result = await _localDataSource.deleteBatch(batchId);
      if (result) {
        return Right(true);
      }

      return Left(LocalDatabaseFailure(message: ' Failed to delete batch'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BatchEntity>>> getAllBatches() async {
    // internet xa ki xaina
    if (await _networkInfo.isConnected) {
      try {
        // api model lai capture garyu
        final apiModels = await _remoteDataSource.getAllBatches();
        // convert to entity
        final result = BatchApiModel.toEntityList(apiModels);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: (e.response?.data is Map<String, dynamic>)
                ? e.response?.data['message'] ?? 'Failed to fetch batches'
                : e.message ?? 'Failed to fetch batches',
          ),
        );
      }
    } else {
      try {
        final models = await _localDataSource.getAllBatches();
        final entities = BatchHiveModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId) async {
    try {
      final model = await _localDataSource.getBatchById(batchId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Batch not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBatch(BatchEntity batch) async {
    try {
      final batchModel = BatchHiveModel.fromEntity(batch);
      final result = await _localDataSource.updateBatch(batchModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to update batch"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
