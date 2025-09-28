import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finflow/expense_repository.dart';

part 'create_credential_event.dart';
part 'create_credential_state.dart';

class CreateCredentialBloc extends Bloc<CreateCredentialEvent, CreateCredentialState> {
  ExpenseRepository expenseRepository;
  CreateCredentialBloc(this.expenseRepository) : super(CreateCredentialInitial()) {
    on<createCredential>((event, emit) async{
      emit(CreateCredentialLoading());

      try{
        await expenseRepository.createCredential(event.credential);
        emit(CreateCredentialSuccess());
      }catch (e){
        emit(CreateCredentialFailure());
      }
    });
  }
}
