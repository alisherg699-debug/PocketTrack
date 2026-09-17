import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/features/income/domain/repositories/income_repository.dart';
import 'package:pockettrack/features/income/application/income/income_event.dart';
import 'package:pockettrack/features/income/application/income/income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final IncomeRepository repository;

  IncomeBloc(this.repository) : super(IncomeInitial()) {
    on<GetIncomes>((event, emit) async {
      emit(IncomeLoading());

      try {
        final incomes = await repository.getAll();
        emit(IncomeLoaded(incomes));
      } catch (e) {
        emit(IncomeError(e.toString()));
      }
    });

    on<AddIncome>((event, emit) async {
      try {
        await repository.add(event.income);
        add(GetIncomes());
      } catch (e) {
        emit(IncomeError(e.toString()));
      }
    });

    on<UpdateIncome>((event, emit) async {
      try {
        await repository.update(event.income);
        add(GetIncomes());
      } catch (e) {
        emit(IncomeError(e.toString()));
      }
    });

    on<DeleteIncome>((event, emit) async {
      try {
        await repository.delete(event.id);
        add(GetIncomes());
      } catch (e) {
        emit(IncomeError(e.toString()));
      }
    });
  }
}
