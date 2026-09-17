import 'package:pockettrack/features/income/domain/entities/income.dart';

abstract class IncomeRepository {
  Future<List<Income>> getAll();
  Future<void> add(Income income);
  Future<void> update(Income income);
  Future<void> delete(String id);
}
