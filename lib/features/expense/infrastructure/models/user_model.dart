import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  @HiveType(typeId: 1)
  const factory UserModel({
    @HiveField(0) required String id,
    @HiveField(1) required String firstName,
    @HiveField(2) required String email,
    @HiveField(3) required String password,
    @HiveField(4) String? phone,
    @HiveField(5) String? currency,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      email: user.email,
      password: user.password,
      phone: user.phone,
      currency: user.currency,
    );
  }
}

extension UserModelMapper on UserModel {
  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      email: email,
      password: password,
      phone: phone,
      currency: currency,
    );
  }
}
