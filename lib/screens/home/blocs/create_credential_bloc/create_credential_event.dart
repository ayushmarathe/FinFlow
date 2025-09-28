part of 'create_credential_bloc.dart';

sealed class CreateCredentialEvent extends Equatable {
  const CreateCredentialEvent();

  @override
  List<Object> get props => [];
}

class createCredential extends CreateCredentialEvent {
  final Credential credential;

  const createCredential(this.credential);

  @override
  List<Object> get props => [credential];
}