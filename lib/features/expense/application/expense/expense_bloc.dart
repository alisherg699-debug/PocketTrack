import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/features/expense/domain/repositories/expense_repository.dart';
import 'package:pockettrack/features/expense/application/expense/expense_event.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc(this.repository) : super(ExpenseInitial()) {
    on<GetExpenses>((event, emit) async {
      emit(ExpenseLoading());

      try {
        final expenses = await repository.getAll();

        emit(ExpenseLoaded(expenses));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<AddExpense>((event, emit) async {
      try {
        await repository.add(event.expense);

        add(GetExpenses());
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<UpdateExpense>((event, emit) async {
      try {
        await repository.update(event.expense);

        add(GetExpenses());
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<DeleteExpense>((event, emit) async {
      try {
        await repository.delete(event.id);

        add(GetExpenses());
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }
}
