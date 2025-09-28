import 'package:finflow/expense_repository.dart';
import 'package:finflow/screens/authentication/views/auth_screen.dart';
import 'package:finflow/screens/home/blocs/create_credential_bloc/create_credential_bloc.dart';
import 'package:finflow/screens/home/blocs/get_credential_bloc/get_credential_bloc.dart';
import 'package:finflow/screens/home/blocs/get_expensesbloc/get_expenses_bloc.dart';
import 'package:finflow/screens/home/blocs/get_income_bloc/get_income_bloc.dart';
import 'package:finflow/screens/home/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: const Color.fromARGB(255, 252, 252, 252),
          onSurface: const Color(0xFF6D6D6D),
          primary: const Color.fromARGB(255, 211, 125, 115), // Soft blue
          secondary: const Color.fromARGB(255, 4, 217, 241), // Fresh mint green
          tertiary:
              const Color.fromARGB(255, 237, 0, 229), // Light pastel yellow
          outline: const Color.fromARGB(255, 213, 137, 137),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading while checking auth state
          }
          if (snapshot.hasData) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      GetExpensesBloc(FirebaseExpenseRepo())..add(GetExpense()),
                ),
                BlocProvider(
                  create: (context) =>
                      GetIncomeBloc(FirebaseExpenseRepo())..add(GetIncome()),
                ),
                BlocProvider(
                    create: (context) =>
                        CreateCredentialBloc(FirebaseExpenseRepo())),
                BlocProvider(
                  create: (context) => GetCredentialBloc(FirebaseExpenseRepo())
                    ..add(GetCredential()),
                )
              ],
              child: HomeScreen(), // Redirect to home if logged in
            );
          }
          return AuthScreen(); // Show login/signup screen if not logged in
        },
      ),
    );
  }
}
