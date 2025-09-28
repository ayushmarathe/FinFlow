import 'package:finflow/expense_repository.dart';
import 'package:finflow/screens/home/view/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';

class MainScreen extends StatefulWidget {
  final String userName; // ✅ Add username
  final double userBudget;
  final List<Expense> expenses;
  final List<Income> income;

  const MainScreen(this.userName, this.userBudget, this.expenses, this.income,
      {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool viewAllTransactions = false;
  Category? selectedCategory; // null = 'All' selected

  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    double totalExpense =
        widget.expenses.fold(0, (sum, item) => sum + item.amount);
    double totalIncome =
        widget.income.fold(0, (sum, item) => sum + item.income);
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userEmail = user?.email;

    final today = DateTime.now();
    final categories = widget.expenses
        .map((e) => e.category)
        .toSet()
        .toList(); // toSet() ensures uniqueness

    final todayExpenses = viewAllTransactions
        ? widget.expenses.where((e) {
            final matchesCategory =
                selectedCategory == null || e.category == selectedCategory;

            // If startDate & endDate are selected, filter within range
            final matchesDateRange = (startDate != null && endDate != null)
                ? (e.date.isAfter(
                        startDate!.subtract(const Duration(days: 1))) &&
                    e.date.isBefore(endDate!.add(const Duration(days: 1))))
                : true; // If no range selected, show all

            return matchesCategory && matchesDateRange;
          }).toList()
        : widget.expenses
            .where((e) =>
                e.date.year == today.year &&
                e.date.month == today.month &&
                e.date.day == today.day)
            .toList();

    final double totalBalance =
        widget.userBudget.toDouble() + totalIncome - totalExpense;

    return Scaffold(
      drawer: CustomDrawer(
        userName: widget.userName,
        mail: userEmail,
        budget: widget.userBudget,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(255, 125, 185, 205)),
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.userName,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        )
                      ],
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        Restart.restartApp();
                      });
                    },
                    icon: Icon(Icons.refresh))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            if (viewAllTransactions)
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('All'),
                        selected: selectedCategory == null,
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: selectedCategory == null
                              ? Colors.white
                              : Colors.black,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = null;
                          });
                        },
                      ),
                    ),
                    ...categories.map((category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category.name),
                            selected: selectedCategory == category,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          ),
                        )),
                  ],
                ),
              ),
            if (!viewAllTransactions)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        color: Colors.grey.shade300,
                        offset: const Offset(5, 5))
                  ],
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.tertiary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary,
                  ], transform: const GradientRotation(3.14 / 4)),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Total Balance',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      '${totalBalance.toStringAsFixed(2)}₹',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_upward,
                                    size: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Income',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    '${totalIncome.toStringAsFixed(2)}₹',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  )
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expense',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    '${totalExpense.toStringAsFixed(2)}₹', // <-- Dynamically updates
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      viewAllTransactions = false;
                    });
                  },
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                        color:
                            !viewAllTransactions ? Colors.black : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      viewAllTransactions = true;
                    });
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                        color: viewAllTransactions ? Colors.black : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            if (viewAllTransactions)
              Column(
                children: [
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        initialDateRange: startDate != null && endDate != null
                            ? DateTimeRange(start: startDate!, end: endDate!)
                            : null,
                      );

                      if (picked != null) {
                        setState(() {
                          startDate = picked.start;
                          endDate = picked.end;
                        });
                      }
                    },
                    child: Text(startDate == null || endDate == null
                        ? "Select Date Range"
                        : "${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            if (viewAllTransactions && startDate != null && endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Showing: ${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM').format(endDate!)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          startDate = null;
                          endDate = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: todayExpenses.isEmpty
                  ? Center(
                      child: Text(
                        viewAllTransactions
                            ? "No transactions yet"
                            : "No transaction today!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: todayExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = todayExpenses[index];
                        return Dismissible(
                          key: Key(expense.expenseId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) async {
                            final removedExpense = widget.expenses[index];

                            setState(() {
                              widget.expenses.removeAt(index);
                            });

                            await FirebaseExpenseRepo()
                                .deleteExpense(removedExpense.expenseId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Expense deleted"),
                                action: SnackBarAction(
                                  label: "Undo",
                                  onPressed: () async {
                                    setState(() {
                                      widget.expenses
                                          .insert(index, removedExpense);
                                    });

                                    await FirebaseExpenseRepo()
                                        .addExpense(removedExpense);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 2,
                                      color: Colors.grey.shade300,
                                      offset: const Offset(5, 5))
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color:
                                                  Color(expense.category.color),
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: Image.asset(
                                              'assets/icons/${expense.category.icon}.png',
                                              height: 32,
                                              width: 32,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          expense.category.name,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '-${expense.amount}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          DateFormat('dd/MM/yy')
                                              .format(expense.date),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
