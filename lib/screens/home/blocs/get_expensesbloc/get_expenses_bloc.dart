import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finflow/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'get_expenses_event.dart';
part 'get_expenses_state.dart';

class GetExpensesBloc extends Bloc<GetExpensesEvent, GetExpensesState> {
  ExpenseRepository expenseRepository;
  GetExpensesBloc(this.expenseRepository) : super(GetExpensesInitial()) {
    on<GetExpense>((event, emit) async {
      emit(GetExpnesesLoading());

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      try {
        List<Expense> expenses = await expenseRepository.getExpenses();

        // 🔥 Sort expenses by date (latest first)
        expenses.sort((a, b) => b.date.compareTo(a.date));

        emit(GetExpensesSuccess(expenses));
      } catch (e) {
        emit(GetExpensesFailure());
      }
    });
  }
}
