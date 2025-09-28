import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finflow/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'get_categories_event.dart';
part 'get_categories_state.dart';

class GetCategoriesBloc extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  ExpenseRepository expenseRepository;
  GetCategoriesBloc(this.expenseRepository) : super(GetCategoriesInitial()) {
    on<GetCategories>((event, emit) async {
      emit(GetCategoriesLoading());

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      try {
        List<Category> categories = await expenseRepository.getCategory();
        emit(GetCategoriesSuccess(categories));
      } catch (e) {
        emit(GetCategoriesFailure()); // ✅ Emit Failure State correctly
      }
    });
  }
}
