import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:finflow/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseExpenseRepo implements ExpenseRepository{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


// Get the currently logged-in user ID
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

  // Reference Firestore collections within the user's document
  CollectionReference get categoryCollection => 
      _firestore.collection('users').doc(userId).collection('categories');

  CollectionReference get expenseCollection => 
      _firestore.collection('users').doc(userId).collection('expenses');

  CollectionReference get incomeCollection => 
      _firestore.collection('users').doc(userId).collection('income');

  CollectionReference get credentialCollection => 
      _firestore.collection('users').doc(userId).collection('credential');



  @override
  Future<void> createCategory(Category category) async {
    try{
      await categoryCollection
        .doc(category.categoryId)
        .set(category.toEntity().toDocument());
    }catch (e){
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory() async {
    if (userId.isEmpty) {
      throw Exception("User not logged in");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();

    return snapshot.docs.map((e) => Category.fromEntity(CategoryEntity.fromDocument(e.data()))).toList();
  }

  @override
  Future<void> createExpense(Expense expense) async {
    try{
      await expenseCollection
        .doc(expense.expenseId)
        .set(expense.toEntity().toDocument());
    }catch (e){
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    if (userId.isEmpty) {
      throw Exception("User not logged in");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    return snapshot.docs.map((e) => Expense.fromEntity(ExpenseEntity.fromDocument(e.data()))).toList();
  }

  @override
  Future<void> createIncome(Income income) async {
    try{
      await incomeCollection
        .doc(income.incomeId)
        .set(income.toEntity().toDocument());
    }catch (e){
      log(e.toString());
      rethrow;
    }
  }

  @override
   Future<List<Income>> getIncome() async {
    if (userId.isEmpty) {
      throw Exception("User not logged in");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('income')
        .get();

    return snapshot.docs.map((e) => Income.fromEntity(IncomeEntity.fromDocument(e.data()))).toList();
  }

  @override
  Future<void> createCredential(Credential credential) async {
    try{
      await credentialCollection
        .doc(credential.credentialId)
        .set(credential.toEntity().toDocument());
    }catch (e){
      log(e.toString());
      rethrow;
    }
  }
  
  @override
  Future<List<Credential>> getCredential() async {
    if (userId.isEmpty) {
      throw Exception("User not logged in");
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('credential')
        .get();

    return snapshot.docs.map((e) => Credential.fromEntity(CredentialsEntity.fromDocument(e.data()))).toList();
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("❌ Error: User not logged in.");
        return;
      }

      print("🔹 Deleting expense: $expenseId for user: $userId");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId)
          .delete();

      print("✅ Expense deleted successfully from Firestore");
    } catch (e) {
      print("❌ Error deleting expense: $e");
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.expenseId) // ✅ Use same ID to restore
          .set({
        'amount': expense.amount,
        'category': expense.category.name,
        'date': expense.date.toIso8601String(),
        'color': expense.category.color,
        'icon': expense.category.icon
      });

      print("✅ Expense restored successfully in Firestore");
    } catch (e) {
      print("❌ Error restoring expense: $e");
    }
  }

  @override
  Future<void> addDefaultCategories(String userId) async {
    try {
      final CollectionReference categoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories');

      // Check if categories exist
      final QuerySnapshot existingCategories = await categoryRef.get();
      if (existingCategories.docs.isNotEmpty) {
        print("✅ Categories already exist for this user.");
        return; // Exit if categories already exist
      }

      // Default categories
      final List<Category> defaultCategories = [
        Category(
            categoryId: '',
            name: 'Food',
            totalExpenses: 0,
            icon: 'food',
            color: 0xFFE57373),
        Category(
            categoryId: '',
            name: 'Transport',
            totalExpenses: 0,
            icon: 'travel',
            color: 0xFF64B5F6),
        Category(
            categoryId: '',
            name: 'Shopping',
            totalExpenses: 0,
            icon: 'shopping',
            color: 0xFFFFD54F),
        Category(
            categoryId: '',
            name: 'Entertainment',
            totalExpenses: 0,
            icon: 'miscelaneous',
            color: 0xFFBA68C8),
        Category(
            categoryId: '',
            name: 'Bills',
            totalExpenses: 0,
            icon: 'bills',
            color: 0xFF4DB6AC),
        Category(
            categoryId: '',
            name: 'Health',
            totalExpenses: 0,
            icon: 'health',
            color: 0xFFFF8A65),
      ];

      // Add default categories using createCategory()
      for (var category in defaultCategories) {
        DocumentReference docRef = categoryRef.doc(); // Generate Firestore ID
        category.categoryId = docRef.id; // Assign Firestore-generated ID
        await createCategory(category); // Use existing method to add
      }

      print("✅ Default categories added for user: $userId");
    } catch (e) {
      print("❌ Error adding default categories: $e");
    }
  }
}
