// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionModelImpl(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      isPositive: json['isPositive'] as bool,
    );

Map<String, dynamic> _$$TransactionModelImplToJson(
        _$TransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'amount': instance.amount,
      'createdAt': instance.createdAt.toIso8601String(),
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'isPositive': instance.isPositive,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.sale: 'sale',
  TransactionType.payment: 'payment',
  TransactionType.expense: 'expense',
};
