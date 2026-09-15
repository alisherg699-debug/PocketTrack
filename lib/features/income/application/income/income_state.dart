import '../../domain/entities/income.dart';

abstract class IncomeState {}

class IncomeInitial extends IncomeState {}

class IncomeLoading extends IncomeState {}

class IncomeLoaded extends IncomeState {
  final List<Income> incomes;
  IncomeLoaded(this.incomes);
}

class IncomeError extends IncomeState {
  final String message;
  IncomeError(this.message);
}
