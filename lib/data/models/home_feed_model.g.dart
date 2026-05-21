// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SummaryMetricModelImpl _$$SummaryMetricModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SummaryMetricModelImpl(
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      helperText: json['helperText'] as String,
    );

Map<String, dynamic> _$$SummaryMetricModelImplToJson(
        _$SummaryMetricModelImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'amount': instance.amount,
      'helperText': instance.helperText,
    };

_$HomeFeedModelImpl _$$HomeFeedModelImplFromJson(Map<String, dynamic> json) =>
    _$HomeFeedModelImpl(
      metrics: (json['metrics'] as List<dynamic>)
          .map((e) => SummaryMetricModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedItems: (json['feedItems'] as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
    );

Map<String, dynamic> _$$HomeFeedModelImplToJson(_$HomeFeedModelImpl instance) =>
    <String, dynamic>{
      'metrics': instance.metrics,
      'feedItems': instance.feedItems,
      'page': instance.page,
      'hasMore': instance.hasMore,
    };
