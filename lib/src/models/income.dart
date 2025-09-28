import 'package:finflow/expense_repository.dart';

class Income {
  String incomeId;
  DateTime date;
  int income;

  Income({
    required this.incomeId,
    required this.date,
    required this.income
  });

  static final empty = Income(
    incomeId: '',
    date : DateTime.now(),
    income: 0
  );

  IncomeEntity toEntity() {
    return IncomeEntity(
      incomeId : incomeId,
      date : date,
      income : income
    );
  }

  static Income fromEntity(IncomeEntity entity) {
    return Income(
      incomeId : entity.incomeId,
      date : entity.date,
      income : entity.income
      );
  }
}