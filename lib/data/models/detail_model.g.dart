// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetailModelImpl _$$DetailModelImplFromJson(Map<String, dynamic> json) =>
    _$DetailModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$DetailModelImplToJson(_$DetailModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'amount': instance.amount,
      'createdAt': instance.createdAt.toIso8601String(),
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'highlights': instance.highlights,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.sale: 'sale',
  TransactionType.payment: 'payment',
  TransactionType.expense: 'expense',
};
