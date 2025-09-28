// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finflow/expense_repository.dart';
import 'package:finflow/screens/add_expenses/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:finflow/screens/add_expenses/blocs/create_expenseb_bloc/create_expense_bloc.dart';
import 'package:finflow/screens/add_expenses/blocs/create_income_bloc/create_income_bloc.dart';
import 'package:finflow/screens/add_expenses/blocs/get_categoriesbloc/get_categories_bloc.dart';
import 'package:finflow/screens/add_expenses/views/add_transaction_screen.dart';
import 'package:finflow/screens/home/blocs/get_expensesbloc/get_expenses_bloc.dart';
import 'package:finflow/screens/home/blocs/get_income_bloc/get_income_bloc.dart';
import 'package:finflow/screens/home/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finflow/screens/stats/stat_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late Color selectedItem = Colors.blue;
  Color unSelectedItem = Colors.grey;
  String userName = "User"; // Default name
  double userBudget = 0.0;

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name']; // ✅ Fetch name
          userBudget = (userDoc['budget'] as num).toDouble();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GetExpensesBloc, GetExpensesState>(
          listener: (context, state) {
            if (state is GetExpensesFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load expenses')),
              );
            }
          },
        ),
        BlocListener<GetIncomeBloc, GetIncomeState>(
          listener: (context, state) {
            if (state is GetIncomeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load income')),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<GetExpensesBloc, GetExpensesState>(
        builder: (context, expensesState) {
          return BlocBuilder<GetIncomeBloc, GetIncomeState>(
            builder: (context, incomeState) {
              bool hasExpenses = expensesState is GetExpensesSuccess;
              bool hasIncome = incomeState is GetIncomeSuccess;

              // If either expenses or income is successful, render UI
              if (hasExpenses || hasIncome) {
                return Scaffold(
                  appBar: AppBar(),
                  bottomNavigationBar: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    child: BottomNavigationBar(
                      onTap: (value) {
                        setState(() {
                          index = value;
                        });
                      },
                      backgroundColor: Colors.white,
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      elevation: 3,
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home,
                              color:
                                  index == 0 ? selectedItem : unSelectedItem),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.graphic_eq_rounded,
                              color:
                                  index == 1 ? selectedItem : unSelectedItem),
                          label: 'Stats',
                        ),
                      ],
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) => CreateCategoryBloc(
                                      FirebaseExpenseRepo())),
                              BlocProvider(
                                  create: (context) =>
                                      GetCategoriesBloc(FirebaseExpenseRepo())
                                        ..add(GetCategories())),
                              BlocProvider(
                                  create: (context) =>
                                      CreateExpenseBloc(FirebaseExpenseRepo())),
                              BlocProvider(
                                  create: (context) =>
                                      CreateIncomeBloc(FirebaseExpenseRepo())),
                            ],
                            child: const AddTransactionScreen(),
                          ),
                        ),
                      );
                      if (result is Expense) {
                        context.read<GetExpensesBloc>().add(GetExpense());
                      } else if (result is Income) {
                        context.read<GetIncomeBloc>().add(GetIncome());
                      }
                    },
                    shape: const CircleBorder(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 212, 157, 157)),
                      child: const Icon(Icons.add),
                    ),
                  ),
                  body: index == 0
                      ? MainScreen(
                          userName,
                          userBudget,
                          hasExpenses ? (expensesState).expenses : [],
                          hasIncome ? (incomeState).income : [],
                        )
                      : StatScreen(
                          hasExpenses ? (expensesState).expenses : [],
                        ),
                );
              } else {
                // If both are loading or failed, show loader
                return const Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
