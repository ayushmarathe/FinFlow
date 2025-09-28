
import 'package:finflow/expense_repository.dart';

class Credential {
  String credentialId;
  String userName;
  double budget;

  Credential({
    required this.credentialId,
    required this.userName,
    required this.budget,
  });

  static final empty = Credential(
    credentialId: '',
    userName: '',
    budget: 0
  );

  CredentialsEntity toEntity() {
    return CredentialsEntity(
      credentialId : credentialId,
      userName : userName,
      budget : budget
    );
  }

  static Credential fromEntity(CredentialsEntity entity) {
    return Credential(
      credentialId: entity.credentialId,
      userName : entity.userName,
      budget : entity.budget
      );
  }
}