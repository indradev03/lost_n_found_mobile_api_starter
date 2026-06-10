import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/error/failures.dart';
import 'package:lost_n_found/core/services/connectivity/network_info.dart';
import 'package:lost_n_found/features/item/data/datasources/item_datasource.dart';
import 'package:lost_n_found/features/item/data/datasources/local/item_local_datasource.dart';
import 'package:lost_n_found/features/item/data/datasources/remote/item_remote_datasource.dart';
import 'package:lost_n_found/features/item/data/models/item_hive_model.dart';
import 'package:lost_n_found/features/item/domain/entities/item_entity.dart';
import 'package:lost_n_found/features/item/domain/repositories/item_repository.dart';

final itemRepositoryProvider = Provider<IItemRepository>((ref) {
  final itemDatasource = ref.read(itemLocalDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final itemRemoteDatasource = ref.read(itemRemoteDatasourceProvider);
  return ItemRepository(
    itemDatasource: itemDatasource,
    networkInfo: networkInfo,
    itemRemoteDatasource: itemRemoteDatasource,
  );
});

class ItemRepository implements IItemRepository {
  final IItemLocalDataSource _itemDataSource;
  final NetworkInfo _networkInfo;
  final IItemRemoteDatasource _iItemRemoteDatasource;

  ItemRepository({
    required IItemRemoteDatasource itemRemoteDatasource,
    required IItemLocalDataSource itemDatasource,
    required NetworkInfo networkInfo,
  }) : _itemDataSource = itemDatasource,
       _networkInfo = networkInfo,
       _iItemRemoteDatasource = itemRemoteDatasource;

  @override
  Future<Either<Failure, bool>> createItem(ItemEntity item) async {
    try {
      final itemModel = ItemHiveModel.fromEntity(item);
      final result = await _itemDataSource.createItem(itemModel);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to create item"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteItem(String itemId) async {
    try {
      final result = await _itemDataSource.deleteItem(itemId);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to delete item"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getAllItems() async {
    try {
      final models = await _itemDataSource.getAllItems();
      final entities = ItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItemById(String itemId) async {
    try {
      final model = await _itemDataSource.getItemById(itemId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: 'Item not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsByUser(
    String userId,
  ) async {
    try {
      final models = await _itemDataSource.getItemsByUser(userId);
      final entities = ItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getLostItems() async {
    try {
      final models = await _itemDataSource.getLostItems();
      final entities = ItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getFoundItems() async {
    try {
      final models = await _itemDataSource.getFoundItems();
      final entities = ItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItemsByCategory(
    String categoryId,
  ) async {
    try {
      final models = await _itemDataSource.getItemsByCategory(categoryId);
      final entities = ItemHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateItem(ItemEntity item) async {
    try {
      final itemModel = ItemHiveModel.fromEntity(item);
      final result = await _itemDataSource.updateItem(itemModel);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to update item"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _iItemRemoteDatasource.uploadImage(image);

        return Right(fileName);
      } on SocketException {
        return Left(ApiFailure(message: 'No Internet Connection'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadVideo(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _iItemRemoteDatasource.uploadVideo(image);

        return Right(fileName);
      } on SocketException {
        return Left(ApiFailure(message: 'No Internet Connection'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No Internet Connection'));
    }
  }
}
