// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_feed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SummaryMetricModel _$SummaryMetricModelFromJson(Map<String, dynamic> json) {
  return _SummaryMetricModel.fromJson(json);
}

/// @nodoc
mixin _$SummaryMetricModel {
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get helperText => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SummaryMetricModelCopyWith<SummaryMetricModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryMetricModelCopyWith<$Res> {
  factory $SummaryMetricModelCopyWith(
          SummaryMetricModel value, $Res Function(SummaryMetricModel) then) =
      _$SummaryMetricModelCopyWithImpl<$Res, SummaryMetricModel>;
  @useResult
  $Res call({String title, double amount, String helperText});
}

/// @nodoc
class _$SummaryMetricModelCopyWithImpl<$Res, $Val extends SummaryMetricModel>
    implements $SummaryMetricModelCopyWith<$Res> {
  _$SummaryMetricModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? amount = null,
    Object? helperText = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      helperText: null == helperText
          ? _value.helperText
          : helperText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SummaryMetricModelImplCopyWith<$Res>
    implements $SummaryMetricModelCopyWith<$Res> {
  factory _$$SummaryMetricModelImplCopyWith(_$SummaryMetricModelImpl value,
          $Res Function(_$SummaryMetricModelImpl) then) =
      __$$SummaryMetricModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, double amount, String helperText});
}

/// @nodoc
class __$$SummaryMetricModelImplCopyWithImpl<$Res>
    extends _$SummaryMetricModelCopyWithImpl<$Res, _$SummaryMetricModelImpl>
    implements _$$SummaryMetricModelImplCopyWith<$Res> {
  __$$SummaryMetricModelImplCopyWithImpl(_$SummaryMetricModelImpl _value,
      $Res Function(_$SummaryMetricModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? amount = null,
    Object? helperText = null,
  }) {
    return _then(_$SummaryMetricModelImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      helperText: null == helperText
          ? _value.helperText
          : helperText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SummaryMetricModelImpl implements _SummaryMetricModel {
  const _$SummaryMetricModelImpl(
      {required this.title, required this.amount, required this.helperText});

  factory _$SummaryMetricModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SummaryMetricModelImplFromJson(json);

  @override
  final String title;
  @override
  final double amount;
  @override
  final String helperText;

  @override
  String toString() {
    return 'SummaryMetricModel(title: $title, amount: $amount, helperText: $helperText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryMetricModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.helperText, helperText) ||
                other.helperText == helperText));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, amount, helperText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryMetricModelImplCopyWith<_$SummaryMetricModelImpl> get copyWith =>
      __$$SummaryMetricModelImplCopyWithImpl<_$SummaryMetricModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SummaryMetricModelImplToJson(
      this,
    );
  }
}

abstract class _SummaryMetricModel implements SummaryMetricModel {
  const factory _SummaryMetricModel(
      {required final String title,
      required final double amount,
      required final String helperText}) = _$SummaryMetricModelImpl;

  factory _SummaryMetricModel.fromJson(Map<String, dynamic> json) =
      _$SummaryMetricModelImpl.fromJson;

  @override
  String get title;
  @override
  double get amount;
  @override
  String get helperText;
  @override
  @JsonKey(ignore: true)
  _$$SummaryMetricModelImplCopyWith<_$SummaryMetricModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomeFeedModel _$HomeFeedModelFromJson(Map<String, dynamic> json) {
  return _HomeFeedModel.fromJson(json);
}

/// @nodoc
mixin _$HomeFeedModel {
  List<SummaryMetricModel> get metrics => throw _privateConstructorUsedError;
  List<TransactionModel> get feedItems => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomeFeedModelCopyWith<HomeFeedModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeFeedModelCopyWith<$Res> {
  factory $HomeFeedModelCopyWith(
          HomeFeedModel value, $Res Function(HomeFeedModel) then) =
      _$HomeFeedModelCopyWithImpl<$Res, HomeFeedModel>;
  @useResult
  $Res call(
      {List<SummaryMetricModel> metrics,
      List<TransactionModel> feedItems,
      int page,
      bool hasMore});
}

/// @nodoc
class _$HomeFeedModelCopyWithImpl<$Res, $Val extends HomeFeedModel>
    implements $HomeFeedModelCopyWith<$Res> {
  _$HomeFeedModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metrics = null,
    Object? feedItems = null,
    Object? page = null,
    Object? hasMore = null,
  }) {
    return _then(_value.copyWith(
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as List<SummaryMetricModel>,
      feedItems: null == feedItems
          ? _value.feedItems
          : feedItems // ignore: cast_nullable_to_non_nullable
              as List<TransactionModel>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeFeedModelImplCopyWith<$Res>
    implements $HomeFeedModelCopyWith<$Res> {
  factory _$$HomeFeedModelImplCopyWith(
          _$HomeFeedModelImpl value, $Res Function(_$HomeFeedModelImpl) then) =
      __$$HomeFeedModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SummaryMetricModel> metrics,
      List<TransactionModel> feedItems,
      int page,
      bool hasMore});
}

/// @nodoc
class __$$HomeFeedModelImplCopyWithImpl<$Res>
    extends _$HomeFeedModelCopyWithImpl<$Res, _$HomeFeedModelImpl>
    implements _$$HomeFeedModelImplCopyWith<$Res> {
  __$$HomeFeedModelImplCopyWithImpl(
      _$HomeFeedModelImpl _value, $Res Function(_$HomeFeedModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metrics = null,
    Object? feedItems = null,
    Object? page = null,
    Object? hasMore = null,
  }) {
    return _then(_$HomeFeedModelImpl(
      metrics: null == metrics
          ? _value._metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as List<SummaryMetricModel>,
      feedItems: null == feedItems
          ? _value._feedItems
          : feedItems // ignore: cast_nullable_to_non_nullable
              as List<TransactionModel>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeFeedModelImpl implements _HomeFeedModel {
  const _$HomeFeedModelImpl(
      {required final List<SummaryMetricModel> metrics,
      required final List<TransactionModel> feedItems,
      required this.page,
      required this.hasMore})
      : _metrics = metrics,
        _feedItems = feedItems;

  factory _$HomeFeedModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeFeedModelImplFromJson(json);

  final List<SummaryMetricModel> _metrics;
  @override
  List<SummaryMetricModel> get metrics {
    if (_metrics is EqualUnmodifiableListView) return _metrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_metrics);
  }

  final List<TransactionModel> _feedItems;
  @override
  List<TransactionModel> get feedItems {
    if (_feedItems is EqualUnmodifiableListView) return _feedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feedItems);
  }

  @override
  final int page;
  @override
  final bool hasMore;

  @override
  String toString() {
    return 'HomeFeedModel(metrics: $metrics, feedItems: $feedItems, page: $page, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeFeedModelImpl &&
            const DeepCollectionEquality().equals(other._metrics, _metrics) &&
            const DeepCollectionEquality()
                .equals(other._feedItems, _feedItems) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_metrics),
      const DeepCollectionEquality().hash(_feedItems),
      page,
      hasMore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeFeedModelImplCopyWith<_$HomeFeedModelImpl> get copyWith =>
      __$$HomeFeedModelImplCopyWithImpl<_$HomeFeedModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeFeedModelImplToJson(
      this,
    );
  }
}

abstract class _HomeFeedModel implements HomeFeedModel {
  const factory _HomeFeedModel(
      {required final List<SummaryMetricModel> metrics,
      required final List<TransactionModel> feedItems,
      required final int page,
      required final bool hasMore}) = _$HomeFeedModelImpl;

  factory _HomeFeedModel.fromJson(Map<String, dynamic> json) =
      _$HomeFeedModelImpl.fromJson;

  @override
  List<SummaryMetricModel> get metrics;
  @override
  List<TransactionModel> get feedItems;
  @override
  int get page;
  @override
  bool get hasMore;
  @override
  @JsonKey(ignore: true)
  _$$HomeFeedModelImplCopyWith<_$HomeFeedModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
