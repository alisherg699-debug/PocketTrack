import 'package:pockettrack/features/expense/infrastructure/datasources/expense_local_data_source.dart';
import 'package:pockettrack/features/expense/infrastructure/models/expense_model.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/expense/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl(this.localDataSource);

  @override
  Future<List<Expense>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> add(Expense expense) async {
    await localDataSource.add(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> update(Expense expense) async {
    await localDataSource.update(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }
}
