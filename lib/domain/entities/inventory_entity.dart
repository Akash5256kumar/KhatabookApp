import 'package:equatable/equatable.dart';

/// A single inventory item.
class InventoryItemEntity extends Equatable {
  const InventoryItemEntity({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unit,
    this.category,
    this.lastPurchasePrice,
    this.lastSalePrice,
  });

  final int id;
  final String? category;
  final String productName;
  final double quantity;
  final String unit;
  final double? lastPurchasePrice;
  final double? lastSalePrice;

  @override
  List<Object?> get props =>
      <Object?>[id, category, productName, quantity, unit, lastPurchasePrice, lastSalePrice];
}
