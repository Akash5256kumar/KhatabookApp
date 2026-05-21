// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerModelImpl _$$CustomerModelImplFromJson(Map<String, dynamic> json) =>
    _$CustomerModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      balance: (json['balance'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      totalSale: (json['total_sale'] as num?)?.toDouble() ?? 0.0,
      totalReceived: (json['total_received'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$CustomerModelImplToJson(_$CustomerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'balance': instance.balance,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'avatarUrl': instance.avatarUrl,
      'total_sale': instance.totalSale,
      'total_received': instance.totalReceived,
    };
