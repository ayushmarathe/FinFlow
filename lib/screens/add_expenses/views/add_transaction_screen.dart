import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'add_expense.dart';
import 'add_income.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  int _selectedIndex = 0;

  // Screens list
  final List<Widget> _screens = [
    const AddExpense(),
    const AddIncome(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],  // Show the selected screen
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Change the screen on tap
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.arrowDown,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              ),
              label: 'Expense',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.arrowUp,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
              ),
              label: 'Income',
            ),
          ],
        ),
      ),
    );
  }
}
