// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_feed_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SummaryMetricEntity {
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get helperText => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SummaryMetricEntityCopyWith<SummaryMetricEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryMetricEntityCopyWith<$Res> {
  factory $SummaryMetricEntityCopyWith(
          SummaryMetricEntity value, $Res Function(SummaryMetricEntity) then) =
      _$SummaryMetricEntityCopyWithImpl<$Res, SummaryMetricEntity>;
  @useResult
  $Res call({String title, double amount, String helperText});
}

/// @nodoc
class _$SummaryMetricEntityCopyWithImpl<$Res, $Val extends SummaryMetricEntity>
    implements $SummaryMetricEntityCopyWith<$Res> {
  _$SummaryMetricEntityCopyWithImpl(this._value, this._then);

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
abstract class _$$SummaryMetricEntityImplCopyWith<$Res>
    implements $SummaryMetricEntityCopyWith<$Res> {
  factory _$$SummaryMetricEntityImplCopyWith(_$SummaryMetricEntityImpl value,
          $Res Function(_$SummaryMetricEntityImpl) then) =
      __$$SummaryMetricEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, double amount, String helperText});
}

/// @nodoc
class __$$SummaryMetricEntityImplCopyWithImpl<$Res>
    extends _$SummaryMetricEntityCopyWithImpl<$Res, _$SummaryMetricEntityImpl>
    implements _$$SummaryMetricEntityImplCopyWith<$Res> {
  __$$SummaryMetricEntityImplCopyWithImpl(_$SummaryMetricEntityImpl _value,
      $Res Function(_$SummaryMetricEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? amount = null,
    Object? helperText = null,
  }) {
    return _then(_$SummaryMetricEntityImpl(
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

class _$SummaryMetricEntityImpl implements _SummaryMetricEntity {
  const _$SummaryMetricEntityImpl(
      {required this.title, required this.amount, required this.helperText});

  @override
  final String title;
  @override
  final double amount;
  @override
  final String helperText;

  @override
  String toString() {
    return 'SummaryMetricEntity(title: $title, amount: $amount, helperText: $helperText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryMetricEntityImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.helperText, helperText) ||
                other.helperText == helperText));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, amount, helperText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryMetricEntityImplCopyWith<_$SummaryMetricEntityImpl> get copyWith =>
      __$$SummaryMetricEntityImplCopyWithImpl<_$SummaryMetricEntityImpl>(
          this, _$identity);
}

abstract class _SummaryMetricEntity implements SummaryMetricEntity {
  const factory _SummaryMetricEntity(
      {required final String title,
      required final double amount,
      required final String helperText}) = _$SummaryMetricEntityImpl;

  @override
  String get title;
  @override
  double get amount;
  @override
  String get helperText;
  @override
  @JsonKey(ignore: true)
  _$$SummaryMetricEntityImplCopyWith<_$SummaryMetricEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HomeFeedEntity {
  List<SummaryMetricEntity> get metrics => throw _privateConstructorUsedError;
  List<TransactionEntity> get feedItems => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeFeedEntityCopyWith<HomeFeedEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeFeedEntityCopyWith<$Res> {
  factory $HomeFeedEntityCopyWith(
          HomeFeedEntity value, $Res Function(HomeFeedEntity) then) =
      _$HomeFeedEntityCopyWithImpl<$Res, HomeFeedEntity>;
  @useResult
  $Res call(
      {List<SummaryMetricEntity> metrics,
      List<TransactionEntity> feedItems,
      int page,
      bool hasMore});
}

/// @nodoc
class _$HomeFeedEntityCopyWithImpl<$Res, $Val extends HomeFeedEntity>
    implements $HomeFeedEntityCopyWith<$Res> {
  _$HomeFeedEntityCopyWithImpl(this._value, this._then);

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
              as List<SummaryMetricEntity>,
      feedItems: null == feedItems
          ? _value.feedItems
          : feedItems // ignore: cast_nullable_to_non_nullable
              as List<TransactionEntity>,
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
abstract class _$$HomeFeedEntityImplCopyWith<$Res>
    implements $HomeFeedEntityCopyWith<$Res> {
  factory _$$HomeFeedEntityImplCopyWith(_$HomeFeedEntityImpl value,
          $Res Function(_$HomeFeedEntityImpl) then) =
      __$$HomeFeedEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SummaryMetricEntity> metrics,
      List<TransactionEntity> feedItems,
      int page,
      bool hasMore});
}

/// @nodoc
class __$$HomeFeedEntityImplCopyWithImpl<$Res>
    extends _$HomeFeedEntityCopyWithImpl<$Res, _$HomeFeedEntityImpl>
    implements _$$HomeFeedEntityImplCopyWith<$Res> {
  __$$HomeFeedEntityImplCopyWithImpl(
      _$HomeFeedEntityImpl _value, $Res Function(_$HomeFeedEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metrics = null,
    Object? feedItems = null,
    Object? page = null,
    Object? hasMore = null,
  }) {
    return _then(_$HomeFeedEntityImpl(
      metrics: null == metrics
          ? _value._metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as List<SummaryMetricEntity>,
      feedItems: null == feedItems
          ? _value._feedItems
          : feedItems // ignore: cast_nullable_to_non_nullable
              as List<TransactionEntity>,
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

class _$HomeFeedEntityImpl implements _HomeFeedEntity {
  const _$HomeFeedEntityImpl(
      {required final List<SummaryMetricEntity> metrics,
      required final List<TransactionEntity> feedItems,
      required this.page,
      required this.hasMore})
      : _metrics = metrics,
        _feedItems = feedItems;

  final List<SummaryMetricEntity> _metrics;
  @override
  List<SummaryMetricEntity> get metrics {
    if (_metrics is EqualUnmodifiableListView) return _metrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_metrics);
  }

  final List<TransactionEntity> _feedItems;
  @override
  List<TransactionEntity> get feedItems {
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
    return 'HomeFeedEntity(metrics: $metrics, feedItems: $feedItems, page: $page, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeFeedEntityImpl &&
            const DeepCollectionEquality().equals(other._metrics, _metrics) &&
            const DeepCollectionEquality()
                .equals(other._feedItems, _feedItems) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

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
  _$$HomeFeedEntityImplCopyWith<_$HomeFeedEntityImpl> get copyWith =>
      __$$HomeFeedEntityImplCopyWithImpl<_$HomeFeedEntityImpl>(
          this, _$identity);
}

abstract class _HomeFeedEntity implements HomeFeedEntity {
  const factory _HomeFeedEntity(
      {required final List<SummaryMetricEntity> metrics,
      required final List<TransactionEntity> feedItems,
      required final int page,
      required final bool hasMore}) = _$HomeFeedEntityImpl;

  @override
  List<SummaryMetricEntity> get metrics;
  @override
  List<TransactionEntity> get feedItems;
  @override
  int get page;
  @override
  bool get hasMore;
  @override
  @JsonKey(ignore: true)
  _$$HomeFeedEntityImplCopyWith<_$HomeFeedEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
