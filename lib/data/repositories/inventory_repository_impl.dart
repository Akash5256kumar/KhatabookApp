import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/datasources/remote/inventory_remote_datasource.dart';
import 'package:apna_business_app/data/models/inventory_model.dart';
import 'package:apna_business_app/domain/entities/inventory_entity.dart';
import 'package:apna_business_app/domain/repositories/inventory_repository.dart';
import 'package:dartz/dartz.dart';

/// Inventory repository implementation.
class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._remoteDataSource);

  final InventoryRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<InventoryItemEntity>>> fetchInventory() async {
    try {
      final items = await _remoteDataSource.fetchInventory();
      return Right(items.map((InventoryItemModel m) => m.toEntity()).toList(growable: false));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, InventoryItemEntity>> upsertItem({
    String? category,
    required String productName,
    required double quantity,
    required String unit,
    double? lastPurchasePrice,
    double? lastSalePrice,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (category != null && category.isNotEmpty) 'category': category,
        'product_name': productName,
        'quantity': quantity,
        'unit': unit,
        if (lastPurchasePrice != null) 'last_purchase_price': lastPurchasePrice,
        if (lastSalePrice != null) 'last_sale_price': lastSalePrice,
      };
      final model = await _remoteDataSource.upsertItem(payload);
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(int id) async {
    try {
      await _remoteDataSource.deleteItem(id);
      return const Right(unit);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<InventoryItemEntity>>> searchProducts(
      String query) async {
    try {
      final models = await _remoteDataSource.searchProducts(query);
      return Right(
          models.map((InventoryItemModel m) => m.toEntity()).toList(growable: false));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
