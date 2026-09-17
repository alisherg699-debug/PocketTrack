import 'package:pockettrack/features/expense/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAll();

  Future<void> add(Expense expense);

  Future<void> update(Expense expense);

  Future<void> delete(String id);
}
