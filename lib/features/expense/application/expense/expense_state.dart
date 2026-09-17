import 'package:pockettrack/features/expense/domain/entities/expense.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  ExpenseLoaded(this.expenses);
}

class ExpenseLoading extends ExpenseState {}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);
}
