import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeEntity {
  String incomeId;
  DateTime date;
  int income;

  IncomeEntity({
    required this.incomeId,
    required this.date,
    required this.income
  });

  Map<String, Object?> toDocument() {
    return {
      'incomeId' : incomeId,
      'date' : date,
      'income' : income,
    };
  }

  static IncomeEntity fromDocument(Map<String, dynamic> doc){
    return IncomeEntity(
      incomeId: doc['incomeId'], 
      date : (doc['date']as Timestamp).toDate(),
      income: doc['income']
    ); 
  }

}