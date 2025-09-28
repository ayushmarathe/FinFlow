import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finflow/expense_repository.dart';
import 'package:finflow/screens/add_expenses/blocs/create_expenseb_bloc/create_expense_bloc.dart';
import 'package:finflow/screens/add_expenses/blocs/get_categoriesbloc/get_categories_bloc.dart';
import 'package:finflow/screens/add_expenses/views/category_creation.dart';
import 'package:finflow/services/budget_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  late Expense expense;
  bool isLoading = false;
  bool showCategories = false; // Visibility flag for category list

  @override
  void initState() {
    super.initState();
    expense = Expense.empty;
    expense.category = Category.empty;
    dateController.text = DateFormat('dd/MM/yy').format(expense.date);
    expense.expenseId = Uuid().v1();
  }

  void _addDefaultCategories(BuildContext context) async {
    final defaultCategories = [
      Category(
        name: "Food",
        icon: "food", // Replace with actual icon file name
        color: 0xFFFFC107,
        categoryId: Uuid().v1(),
        totalExpenses: 0,
      ),
      Category(
        name: "travel",
        icon: "travel",
        color: 0xFF2196F3,
        categoryId: Uuid().v1(),
        totalExpenses: 0,
      ),
      Category(
        name: "bills",
        icon: "bills",
        color: 0xFFE91E63,
        categoryId: Uuid().v1(),
        totalExpenses: 0,
      ),
    ];

    for (var category in defaultCategories) {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': category.name,
        'icon': category.icon,
        'color': category.color,
        'categoryId': category.categoryId,
        'totalExpenses': category.totalExpenses,
      });
    }

    // Refresh categories by triggering the Bloc event
    context.read<GetCategoriesBloc>().add(GetCategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          Navigator.pop(context, expense);
        } else if (state is CreateExpenseLoading) {
          setState(() {
            isLoading = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                if (state.categories.isEmpty) {}
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        const Text(
                          'Add Expenses',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.69,
                          child: TextFormField(
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            controller: expenseController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                FontAwesomeIcons.rupeeSign,
                                size: 20,
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                          controller: categoryController,
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Category',
                            hintStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            filled: true,
                            fillColor: expense.category == Category.empty
                                ? Colors.white
                                : Color(expense.category.color),
                            prefixIcon: expense.category == Category.empty
                                ? const Icon(FontAwesomeIcons.list, size: 20)
                                : Image.asset(
                                    'assets/icons/${expense.category.icon}.png'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                var newCategory =
                                    await getCategoryCreation(context);

                                if (newCategory != null) {
                                  // Add category to Firestore
                                  await FirebaseFirestore.instance
                                      .collection('categories')
                                      .add({
                                    'name': newCategory.name,
                                    'icon': newCategory.icon,
                                    'color': newCategory.color,
                                    'categoryId': newCategory.categoryId,
                                    'totalExpenses': newCategory.totalExpenses,
                                  });

                                  // Refresh categories by triggering the Bloc event
                                  context
                                      .read<GetCategoriesBloc>()
                                      .add(GetCategories());

                                  setState(() {
                                    showCategories =
                                        false; // Hide category list after creation
                                  });
                                }
                              },
                              icon: const Icon(FontAwesomeIcons.plus),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              showCategories =
                                  !showCategories; // Toggle category list
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        /// Category List (Visible only when showCategories is true)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: Visibility(
                            visible: showCategories,
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                itemCount: state.categories.length,
                                itemBuilder: (context, i) {
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        onTap: () {
                                          setState(() {
                                            expense.category =
                                                state.categories[i];
                                            categoryController.text =
                                                state.categories[i].name;
                                            showCategories =
                                                false; // Hide list after selection
                                          });
                                        },
                                        leading: Image.asset(
                                            'assets/icons/${state.categories[i].icon}.png'),
                                        title: Text(
                                          state.categories[i].name,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        tileColor:
                                            Color(state.categories[i].color),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                          controller: dateController,
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          onTap: () async {
                            DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: expense.date,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );

                            setState(() {
                              dateController.text =
                                  DateFormat('dd/MM/yy').format(newDate!);
                              expense.date = newDate;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Date',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              FontAwesomeIcons.clock,
                              size: 20,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (expenseController.text.isEmpty ||
                                        int.tryParse(expenseController.text) ==
                                            null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please enter a valid expense amount'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (expense.category == Category.empty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Please select a category'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      expense.amount =
                                          int.parse(expenseController.text);
                                    });

                                    context
                                        .read<CreateExpenseBloc>()
                                        .add(CreateExpense(expense));

                                    await BudgetNotificationService
                                        .checkBudgetAndNotify();
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
