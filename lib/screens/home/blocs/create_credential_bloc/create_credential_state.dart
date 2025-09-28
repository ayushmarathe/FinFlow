part of 'create_credential_bloc.dart';

sealed class CreateCredentialState extends Equatable {
  const CreateCredentialState();
  
  @override
  List<Object> get props => [];
}

final class CreateCredentialInitial extends CreateCredentialState {}

final class CreateCredentialFailure extends CreateCredentialState {}
final class CreateCredentialLoading extends CreateCredentialState {}
final class CreateCredentialSuccess extends CreateCredentialState {}