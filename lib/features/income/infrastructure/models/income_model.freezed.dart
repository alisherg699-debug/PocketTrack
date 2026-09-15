// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IncomeModel _$IncomeModelFromJson(Map<String, dynamic> json) {
  return _IncomeModel.fromJson(json);
}

/// @nodoc
mixin _$IncomeModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(2)
  double get amount => throw _privateConstructorUsedError;
  @HiveField(3)
  String get category => throw _privateConstructorUsedError;
  @HiveField(4)
  String? get description => throw _privateConstructorUsedError;
  @HiveField(5)
  DateTime get date => throw _privateConstructorUsedError;
  @HiveField(6)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(7)
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IncomeModelCopyWith<IncomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeModelCopyWith<$Res> {
  factory $IncomeModelCopyWith(
          IncomeModel value, $Res Function(IncomeModel) then) =
      _$IncomeModelCopyWithImpl<$Res, IncomeModel>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) double amount,
      @HiveField(3) String category,
      @HiveField(4) String? description,
      @HiveField(5) DateTime date,
      @HiveField(6) DateTime createdAt,
      @HiveField(7) DateTime updatedAt});
}

/// @nodoc
class _$IncomeModelCopyWithImpl<$Res, $Val extends IncomeModel>
    implements $IncomeModelCopyWith<$Res> {
  _$IncomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? category = null,
    Object? description = freezed,
    Object? date = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IncomeModelImplCopyWith<$Res>
    implements $IncomeModelCopyWith<$Res> {
  factory _$$IncomeModelImplCopyWith(
          _$IncomeModelImpl value, $Res Function(_$IncomeModelImpl) then) =
      __$$IncomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) double amount,
      @HiveField(3) String category,
      @HiveField(4) String? description,
      @HiveField(5) DateTime date,
      @HiveField(6) DateTime createdAt,
      @HiveField(7) DateTime updatedAt});
}

/// @nodoc
class __$$IncomeModelImplCopyWithImpl<$Res>
    extends _$IncomeModelCopyWithImpl<$Res, _$IncomeModelImpl>
    implements _$$IncomeModelImplCopyWith<$Res> {
  __$$IncomeModelImplCopyWithImpl(
      _$IncomeModelImpl _value, $Res Function(_$IncomeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? category = null,
    Object? description = freezed,
    Object? date = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$IncomeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 2)
class _$IncomeModelImpl implements _IncomeModel {
  const _$IncomeModelImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.amount,
      @HiveField(3) required this.category,
      @HiveField(4) this.description,
      @HiveField(5) required this.date,
      @HiveField(6) required this.createdAt,
      @HiveField(7) required this.updatedAt});

  factory _$IncomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncomeModelImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final double amount;
  @override
  @HiveField(3)
  final String category;
  @override
  @HiveField(4)
  final String? description;
  @override
  @HiveField(5)
  final DateTime date;
  @override
  @HiveField(6)
  final DateTime createdAt;
  @override
  @HiveField(7)
  final DateTime updatedAt;

  @override
  String toString() {
    return 'IncomeModel(id: $id, title: $title, amount: $amount, category: $category, description: $description, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, amount, category,
      description, date, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeModelImplCopyWith<_$IncomeModelImpl> get copyWith =>
      __$$IncomeModelImplCopyWithImpl<_$IncomeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IncomeModelImplToJson(
      this,
    );
  }
}

abstract class _IncomeModel implements IncomeModel {
  const factory _IncomeModel(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String title,
      @HiveField(2) required final double amount,
      @HiveField(3) required final String category,
      @HiveField(4) final String? description,
      @HiveField(5) required final DateTime date,
      @HiveField(6) required final DateTime createdAt,
      @HiveField(7) required final DateTime updatedAt}) = _$IncomeModelImpl;

  factory _IncomeModel.fromJson(Map<String, dynamic> json) =
      _$IncomeModelImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get title;
  @override
  @HiveField(2)
  double get amount;
  @override
  @HiveField(3)
  String get category;
  @override
  @HiveField(4)
  String? get description;
  @override
  @HiveField(5)
  DateTime get date;
  @override
  @HiveField(6)
  DateTime get createdAt;
  @override
  @HiveField(7)
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$IncomeModelImplCopyWith<_$IncomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
