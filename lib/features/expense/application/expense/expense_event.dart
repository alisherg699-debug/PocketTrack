import '../../domain/entities/expense.dart';

abstract class ExpenseEvent {}

class GetExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  AddExpense(this.expense);
}

class DeleteExpense extends ExpenseEvent {
  final String id;

  DeleteExpense(this.id);
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  UpdateExpense(this.expense);
}
