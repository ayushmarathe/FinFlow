import 'package:finflow/expense_repository.dart';


abstract class ExpenseRepository {
  Future<void> createCategory(Category category);
  Future<List<Category>> getCategory();

  Future<void> createExpense(Expense expense) ;
  Future<List<Expense>> getExpenses() ;

  Future<void> createIncome(Income income);
  Future<List<Income>> getIncome() ;

  Future<void> createCredential(Credential credential);
  Future<List<Credential>> getCredential();

  Future<void> deleteExpense(String expenseId);
  Future<void> addExpense(Expense expense);

  Future<void> addDefaultCategories(String userId);
}
