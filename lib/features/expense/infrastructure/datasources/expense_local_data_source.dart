import 'package:hive/hive.dart';
import 'package:pockettrack/features/expense/infrastructure/models/expense_model.dart';

class ExpenseLocalDataSource {
  late Box expensesBox;

  Future<void> init() async {
    expensesBox = await Hive.openBox('expenses');
  }

  Future<void> add(ExpenseModel expense) async {
    await expensesBox.put(expense.id, expense);
  }

  Future<List<ExpenseModel>> getAll() async {
    return expensesBox.values.toList().cast<ExpenseModel>();
  }

  Future<void> update(ExpenseModel expense) async {
    await expensesBox.put(expense.id, expense);
  }

  Future<void> delete(String id) async {
    await expensesBox.delete(id);
  }
}
