// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CustomerEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  double get totalSale => throw _privateConstructorUsedError;
  double get totalReceived => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CustomerEntityCopyWith<CustomerEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerEntityCopyWith<$Res> {
  factory $CustomerEntityCopyWith(
          CustomerEntity value, $Res Function(CustomerEntity) then) =
      _$CustomerEntityCopyWithImpl<$Res, CustomerEntity>;
  @useResult
  $Res call(
      {String id,
      String name,
      String phone,
      double balance,
      DateTime updatedAt,
      String? avatarUrl,
      double totalSale,
      double totalReceived});
}

/// @nodoc
class _$CustomerEntityCopyWithImpl<$Res, $Val extends CustomerEntity>
    implements $CustomerEntityCopyWith<$Res> {
  _$CustomerEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? balance = null,
    Object? updatedAt = null,
    Object? avatarUrl = freezed,
    Object? totalSale = null,
    Object? totalReceived = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      totalSale: null == totalSale
          ? _value.totalSale
          : totalSale // ignore: cast_nullable_to_non_nullable
              as double,
      totalReceived: null == totalReceived
          ? _value.totalReceived
          : totalReceived // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerEntityImplCopyWith<$Res>
    implements $CustomerEntityCopyWith<$Res> {
  factory _$$CustomerEntityImplCopyWith(_$CustomerEntityImpl value,
          $Res Function(_$CustomerEntityImpl) then) =
      __$$CustomerEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String phone,
      double balance,
      DateTime updatedAt,
      String? avatarUrl,
      double totalSale,
      double totalReceived});
}

/// @nodoc
class __$$CustomerEntityImplCopyWithImpl<$Res>
    extends _$CustomerEntityCopyWithImpl<$Res, _$CustomerEntityImpl>
    implements _$$CustomerEntityImplCopyWith<$Res> {
  __$$CustomerEntityImplCopyWithImpl(
      _$CustomerEntityImpl _value, $Res Function(_$CustomerEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? balance = null,
    Object? updatedAt = null,
    Object? avatarUrl = freezed,
    Object? totalSale = null,
    Object? totalReceived = null,
  }) {
    return _then(_$CustomerEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      totalSale: null == totalSale
          ? _value.totalSale
          : totalSale // ignore: cast_nullable_to_non_nullable
              as double,
      totalReceived: null == totalReceived
          ? _value.totalReceived
          : totalReceived // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$CustomerEntityImpl implements _CustomerEntity {
  const _$CustomerEntityImpl(
      {required this.id,
      required this.name,
      required this.phone,
      required this.balance,
      required this.updatedAt,
      this.avatarUrl,
      this.totalSale = 0.0,
      this.totalReceived = 0.0});

  @override
  final String id;
  @override
  final String name;
  @override
  final String phone;
  @override
  final double balance;
  @override
  final DateTime updatedAt;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final double totalSale;
  @override
  @JsonKey()
  final double totalReceived;

  @override
  String toString() {
    return 'CustomerEntity(id: $id, name: $name, phone: $phone, balance: $balance, updatedAt: $updatedAt, avatarUrl: $avatarUrl, totalSale: $totalSale, totalReceived: $totalReceived)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.totalSale, totalSale) ||
                other.totalSale == totalSale) &&
            (identical(other.totalReceived, totalReceived) ||
                other.totalReceived == totalReceived));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, phone, balance, updatedAt, avatarUrl, totalSale, totalReceived);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerEntityImplCopyWith<_$CustomerEntityImpl> get copyWith =>
      __$$CustomerEntityImplCopyWithImpl<_$CustomerEntityImpl>(
          this, _$identity);
}

abstract class _CustomerEntity implements CustomerEntity {
  const factory _CustomerEntity(
      {required final String id,
      required final String name,
      required final String phone,
      required final double balance,
      required final DateTime updatedAt,
      final String? avatarUrl,
      @Default(0.0) final double totalSale,
      @Default(0.0) final double totalReceived}) = _$CustomerEntityImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get phone;
  @override
  double get balance;
  @override
  DateTime get updatedAt;
  @override
  String? get avatarUrl;
  @override
  double get totalSale;
  @override
  double get totalReceived;
  @override
  @JsonKey(ignore: true)
  _$$CustomerEntityImplCopyWith<_$CustomerEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
