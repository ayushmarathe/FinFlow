part of 'get_credential_bloc.dart';

sealed class GetCredentialEvent extends Equatable {
  const GetCredentialEvent();

  @override
  List<Object> get props => [];
}

class GetCredential extends GetCredentialEvent{}