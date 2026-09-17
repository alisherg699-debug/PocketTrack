import 'package:hive/hive.dart';
import 'package:pockettrack/features/income/infrastructure/models/income_model.dart';

class IncomeLocalDataSource {
  late Box incomesBox;

  Future<void> init() async {
    incomesBox = await Hive.openBox('incomes');
  }

  Future<void> add(IncomeModel income) async {
    await incomesBox.put(income.id, income);
  }

  Future<List<IncomeModel>> getAll() async {
    return incomesBox.values.toList().cast<IncomeModel>();
  }

  Future<void> update(IncomeModel income) async {
    await incomesBox.put(income.id, income);
  }

  Future<void> delete(String id) async {
    await incomesBox.delete(id);
  }
}
