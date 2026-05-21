// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DetailModel _$DetailModelFromJson(Map<String, dynamic> json) {
  return _DetailModel.fromJson(json);
}

/// @nodoc
mixin _$DetailModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  List<String> get highlights => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DetailModelCopyWith<DetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetailModelCopyWith<$Res> {
  factory $DetailModelCopyWith(
          DetailModel value, $Res Function(DetailModel) then) =
      _$DetailModelCopyWithImpl<$Res, DetailModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String subtitle,
      String imageUrl,
      String description,
      double amount,
      DateTime createdAt,
      TransactionType type,
      List<String> highlights});
}

/// @nodoc
class _$DetailModelCopyWithImpl<$Res, $Val extends DetailModel>
    implements $DetailModelCopyWith<$Res> {
  _$DetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? imageUrl = null,
    Object? description = null,
    Object? amount = null,
    Object? createdAt = null,
    Object? type = null,
    Object? highlights = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      highlights: null == highlights
          ? _value.highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DetailModelImplCopyWith<$Res>
    implements $DetailModelCopyWith<$Res> {
  factory _$$DetailModelImplCopyWith(
          _$DetailModelImpl value, $Res Function(_$DetailModelImpl) then) =
      __$$DetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String subtitle,
      String imageUrl,
      String description,
      double amount,
      DateTime createdAt,
      TransactionType type,
      List<String> highlights});
}

/// @nodoc
class __$$DetailModelImplCopyWithImpl<$Res>
    extends _$DetailModelCopyWithImpl<$Res, _$DetailModelImpl>
    implements _$$DetailModelImplCopyWith<$Res> {
  __$$DetailModelImplCopyWithImpl(
      _$DetailModelImpl _value, $Res Function(_$DetailModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? imageUrl = null,
    Object? description = null,
    Object? amount = null,
    Object? createdAt = null,
    Object? type = null,
    Object? highlights = null,
  }) {
    return _then(_$DetailModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      highlights: null == highlights
          ? _value._highlights
          : highlights // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DetailModelImpl implements _DetailModel {
  const _$DetailModelImpl(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.imageUrl,
      required this.description,
      required this.amount,
      required this.createdAt,
      required this.type,
      required final List<String> highlights})
      : _highlights = highlights;

  factory _$DetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetailModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final String imageUrl;
  @override
  final String description;
  @override
  final double amount;
  @override
  final DateTime createdAt;
  @override
  final TransactionType type;
  final List<String> _highlights;
  @override
  List<String> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  @override
  String toString() {
    return 'DetailModel(id: $id, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, description: $description, amount: $amount, createdAt: $createdAt, type: $type, highlights: $highlights)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetailModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._highlights, _highlights));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      subtitle,
      imageUrl,
      description,
      amount,
      createdAt,
      type,
      const DeepCollectionEquality().hash(_highlights));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DetailModelImplCopyWith<_$DetailModelImpl> get copyWith =>
      __$$DetailModelImplCopyWithImpl<_$DetailModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetailModelImplToJson(
      this,
    );
  }
}

abstract class _DetailModel implements DetailModel {
  const factory _DetailModel(
      {required final String id,
      required final String title,
      required final String subtitle,
      required final String imageUrl,
      required final String description,
      required final double amount,
      required final DateTime createdAt,
      required final TransactionType type,
      required final List<String> highlights}) = _$DetailModelImpl;

  factory _DetailModel.fromJson(Map<String, dynamic> json) =
      _$DetailModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get subtitle;
  @override
  String get imageUrl;
  @override
  String get description;
  @override
  double get amount;
  @override
  DateTime get createdAt;
  @override
  TransactionType get type;
  @override
  List<String> get highlights;
  @override
  @JsonKey(ignore: true)
  _$$DetailModelImplCopyWith<_$DetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
