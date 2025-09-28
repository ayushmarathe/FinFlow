import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finflow/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'get_income_event.dart';
part 'get_income_state.dart';

class GetIncomeBloc extends Bloc<GetIncomeEvent, GetIncomeState> {
  ExpenseRepository expenseRepository;
  GetIncomeBloc(this.expenseRepository) : super(GetIncomeInitial()) {
    on<GetIncome>((event, emit) async {
      emit(GetIncomeLoading());

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      try {
        List<Income> income = await expenseRepository.getIncome();
        emit(GetIncomeSuccess(income));
      } catch (e) {
        emit(GetIncomeFailure());
      }
    });
  }
}
