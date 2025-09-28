import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finflow/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
part 'get_credential_event.dart';
part 'get_credential_state.dart';

class GetCredentialBloc extends Bloc<GetCredentialEvent, GetCredentialState> {
  ExpenseRepository expenseRepository;
  GetCredentialBloc(this.expenseRepository) : super(GetCredentialInitial()) {
    on<GetCredential>((event, emit) async {
      emit(GetCredentialLoading());

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      try {
        List<Credential> credential = await expenseRepository.getCredential();
        emit(GetCredentialSuccess(credential));
      } catch (e) {
        emit(GetCredentialFailure());
      }
    });
  }
}
