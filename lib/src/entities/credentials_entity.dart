
class CredentialsEntity {
  String credentialId;
  String userName;
  double budget;

  CredentialsEntity({
    required this.credentialId,
    required this.userName,
    required this.budget,
  });

  Map<String, Object?> toDocument() {
    return {
      'credentialId' : credentialId,
      'userName' : userName,
      'budget' : budget,
    };
  }

  static CredentialsEntity fromDocument(Map<String, dynamic> doc){
    return CredentialsEntity(
      credentialId: doc['credentialId'],
      userName: doc['incomeId'], 
      budget : doc['budget']
    ); 
  }

}