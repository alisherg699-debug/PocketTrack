import 'package:pockettrack/features/income/infrastructure/datasources/income_local_data_source.dart';
import 'package:pockettrack/features/income/infrastructure/models/income_model.dart';
import 'package:pockettrack/features/income/domain/entities/income.dart';
import 'package:pockettrack/features/income/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeLocalDataSource localDataSource;

  IncomeRepositoryImpl(this.localDataSource);

  @override
  Future<List<Income>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> add(Income income) async {
    await localDataSource.add(IncomeModel.fromEntity(income));
  }

  @override
  Future<void> update(Income income) async {
    await localDataSource.update(IncomeModel.fromEntity(income));
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }
}
