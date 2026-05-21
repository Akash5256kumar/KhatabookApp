import 'package:apna_business_app/domain/entities/inventory_entity.dart';

/// JSON model for an inventory item.
class InventoryItemModel {
  const InventoryItemModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unit,
    this.category,
    this.lastPurchasePrice,
    this.lastSalePrice,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: (json['id'] as num).toInt(),
      category: json['category'] as String?,
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'piece',
      lastPurchasePrice: (json['last_purchase_price'] as num?)?.toDouble(),
      lastSalePrice: (json['last_sale_price'] as num?)?.toDouble(),
    );
  }

  final int id;
  final String? category;
  final String productName;
  final double quantity;
  final String unit;
  final double? lastPurchasePrice;
  final double? lastSalePrice;

  InventoryItemEntity toEntity() => InventoryItemEntity(
        id: id,
        category: category,
        productName: productName,
        quantity: quantity,
        unit: unit,
        lastPurchasePrice: lastPurchasePrice,
        lastSalePrice: lastSalePrice,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (category != null) 'category': category,
        'product_name': productName,
        'quantity': quantity,
        'unit': unit,
        if (lastPurchasePrice != null) 'last_purchase_price': lastPurchasePrice,
        if (lastSalePrice != null) 'last_sale_price': lastSalePrice,
      };
}
