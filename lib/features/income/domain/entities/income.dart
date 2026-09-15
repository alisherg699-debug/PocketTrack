import 'package:freezed_annotation/freezed_annotation.dart';

part 'income.freezed.dart';

@freezed
class Income with _$Income {
  const factory Income({
    required String id,
    required String title,
    required double amount,
    required String category,
    String? description,
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Income;
}
