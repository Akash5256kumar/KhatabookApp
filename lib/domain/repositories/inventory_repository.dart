import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/inventory_entity.dart';
import 'package:dartz/dartz.dart';

/// Contract for inventory data.
abstract interface class InventoryRepository {
  Future<Either<Failure, List<InventoryItemEntity>>> fetchInventory();

  Future<Either<Failure, InventoryItemEntity>> upsertItem({
    String? category,
    required String productName,
    required double quantity,
    required String unit,
    double? lastPurchasePrice,
    double? lastSalePrice,
  });

  Future<Either<Failure, List<InventoryItemEntity>>> searchProducts(String query);

  Future<Either<Failure, Unit>> deleteItem(int id);
}
