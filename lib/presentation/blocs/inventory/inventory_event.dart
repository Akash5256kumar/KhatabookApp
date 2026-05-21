part of 'inventory_bloc.dart';

sealed class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class InventoryStarted extends InventoryEvent {
  const InventoryStarted();
}

final class InventoryRefreshed extends InventoryEvent {
  const InventoryRefreshed();
}

final class InventoryItemUpserted extends InventoryEvent {
  const InventoryItemUpserted({
    this.category,
    required this.productName,
    required this.quantity,
    required this.unit,
    this.lastPurchasePrice,
    this.lastSalePrice,
  });

  final String? category;
  final String productName;
  final double quantity;
  final String unit;
  final double? lastPurchasePrice;
  final double? lastSalePrice;

  @override
  List<Object?> get props =>
      <Object?>[category, productName, quantity, unit, lastPurchasePrice, lastSalePrice];
}

final class InventoryItemDeleted extends InventoryEvent {
  const InventoryItemDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => <Object?>[id];
}
