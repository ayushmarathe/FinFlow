part of 'get_credential_bloc.dart';

sealed class GetCredentialState extends Equatable {
  const GetCredentialState();
  
  @override
  List<Object> get props => [];
}

final class GetCredentialInitial extends GetCredentialState {}

final class GetCredentialFailure extends GetCredentialState {}
final class GetCredentialLoading extends GetCredentialState {}
final class GetCredentialSuccess extends GetCredentialState {
  final List<Credential> credential;

  const GetCredentialSuccess(this.credential);

  @override
  List<Object> get props => [credential];
}