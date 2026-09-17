import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'package:pockettrack/features/income/domain/entities/income.dart';

part 'income_model.freezed.dart';
part 'income_model.g.dart';

@freezed
class IncomeModel with _$IncomeModel {
  @HiveType(typeId: 2)
  const factory IncomeModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required double amount,
    @HiveField(3) required String category,
    @HiveField(4) String? description,
    @HiveField(5) required DateTime date,
    @HiveField(6) required DateTime createdAt,
    @HiveField(7) required DateTime updatedAt,
  }) = _IncomeModel;

  factory IncomeModel.fromJson(Map<String, dynamic> json) =>
      _$IncomeModelFromJson(json);

  factory IncomeModel.fromEntity(Income income) {
    return IncomeModel(
      id: income.id,
      title: income.title,
      amount: income.amount,
      category: income.category,
      description: income.description,
      date: income.date,
      createdAt: income.createdAt,
      updatedAt: income.updatedAt,
    );
  }
}

extension IncomeModelMapper on IncomeModel {
  Income toEntity() {
    return Income(
      id: id,
      title: title,
      amount: amount,
      category: category,
      description: description,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
