import '../../domain/entities/income.dart';

abstract class IncomeEvent {}

class GetIncomes extends IncomeEvent {}

class AddIncome extends IncomeEvent {
  final Income income;
  AddIncome(this.income);
}

class UpdateIncome extends IncomeEvent {
  final Income income;
  UpdateIncome(this.income);
}

class DeleteIncome extends IncomeEvent {
  final String id;
  DeleteIncome(this.id);
}
