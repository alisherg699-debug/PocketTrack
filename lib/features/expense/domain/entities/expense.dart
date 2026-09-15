import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String title,
    required double amount,
    required String category,
    String? description,
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Expense;
}
