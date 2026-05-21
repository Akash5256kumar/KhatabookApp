import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/inventory_entity.dart';
import 'package:apna_business_app/domain/repositories/inventory_repository.dart';
import 'package:dartz/dartz.dart';

/// Fetches the full inventory list.
class FetchInventoryUseCase {
  FetchInventoryUseCase(this._repository);

  final InventoryRepository _repository;

  Future<Either<Failure, List<InventoryItemEntity>>> call() =>
      _repository.fetchInventory();
}

/// Adds or updates an inventory item.
class UpsertInventoryItemUseCase {
  UpsertInventoryItemUseCase(this._repository);

  final InventoryRepository _repository;

  Future<Either<Failure, InventoryItemEntity>> call({
    String? category,
    required String productName,
    required double quantity,
    required String unit,
    double? lastPurchasePrice,
    double? lastSalePrice,
  }) =>
      _repository.upsertItem(
        category: category,
        productName: productName,
        quantity: quantity,
        unit: unit,
        lastPurchasePrice: lastPurchasePrice,
        lastSalePrice: lastSalePrice,
      );
}

/// Searches inventory items by partial product name.
class SearchInventoryUseCase {
  SearchInventoryUseCase(this._repository);

  final InventoryRepository _repository;

  Future<Either<Failure, List<InventoryItemEntity>>> call(String query) =>
      _repository.searchProducts(query);
}

/// Deletes an inventory item by id.
class DeleteInventoryItemUseCase {
  DeleteInventoryItemUseCase(this._repository);

  final InventoryRepository _repository;

  Future<Either<Failure, Unit>> call(int id) => _repository.deleteItem(id);
}
