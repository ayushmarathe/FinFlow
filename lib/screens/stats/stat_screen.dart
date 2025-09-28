import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finflow/screens/stats/stat.dart';
import 'package:finflow/expense_repository.dart';

class StatScreen extends StatefulWidget {
  final List<Expense> expenses;

  const StatScreen(this.expenses, {super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  String _selectedRange = 'Monthly';
  DateTime _currentDate = DateTime.now();
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  List<Expense> get _filteredExpenses {
    if (_selectedRange == 'Monthly') {
      return widget.expenses.where((expense) {
        return expense.date.year == _currentDate.year &&
            expense.date.month == _currentDate.month;
      }).toList();
    } else if (_selectedRange == 'Weekly') {
      final now = _currentDate;
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return widget.expenses.where((expense) {
        return expense.date
                .isAfter(weekStart.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(weekEnd.add(const Duration(days: 1)));
      }).toList();
    } else if (_selectedRange == 'Daily') {
      return widget.expenses.where((expense) {
        return expense.date.year == _currentDate.year &&
            expense.date.month == _currentDate.month &&
            expense.date.day == _currentDate.day;
      }).toList();
    } else if (_selectedRange == 'Custom' &&
        _customStartDate != null &&
        _customEndDate != null) {
      return widget.expenses.where((expense) {
        return expense.date
                .isAfter(_customStartDate!.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_customEndDate!.add(const Duration(days: 1)));
      }).toList();
    } else {
      return widget.expenses;
    }
  }

  void _goToPrevious() {
    setState(() {
      if (_selectedRange == 'Monthly') {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      } else if (_selectedRange == 'Weekly') {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else if (_selectedRange == 'Daily') {
        _currentDate = _currentDate.subtract(const Duration(days: 1));
      }
    });
  }

  void _goToNext() {
    if (!_canGoNext()) return;
    setState(() {
      if (_selectedRange == 'Monthly') {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      } else if (_selectedRange == 'Weekly') {
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else if (_selectedRange == 'Daily') {
        _currentDate = _currentDate.add(const Duration(days: 1));
      }
    });
  }

  bool _canGoNext() {
    final now = DateTime.now();
    if (_selectedRange == 'Monthly') {
      return !(_currentDate.year == now.year &&
          _currentDate.month == now.month);
    } else if (_selectedRange == 'Weekly') {
      final viewedMonday =
          _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
      final currentMonday = now.subtract(Duration(days: now.weekday - 1));
      return viewedMonday.isBefore(currentMonday);
    } else if (_selectedRange == 'Daily') {
      return !(_currentDate.year == now.year &&
          _currentDate.month == now.month &&
          _currentDate.day == now.day);
    }
    return false;
  }

  String _getWeeklyDateRangeText() {
    final start =
        _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    final end = start.add(const Duration(days: 6));
    final formatter = DateFormat('d MMM');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: widget.expenses.isNotEmpty
          ? widget.expenses
              .map((e) => e.date)
              .reduce((a, b) => a.isBefore(b) ? a : b)
          : DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String headerTitle = () {
      if (_selectedRange == 'Weekly') return _getWeeklyDateRangeText();
      if (_selectedRange == 'Daily')
        return DateFormat('d MMM yyyy').format(_currentDate);
      if (_selectedRange == 'Custom' &&
          _customStartDate != null &&
          _customEndDate != null) {
        return '${DateFormat('d MMM').format(_customStartDate!)} - ${DateFormat('d MMM yyyy').format(_customEndDate!)}';
      }
      return DateFormat.yMMMM().format(_currentDate);
    }();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Statistics + Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedRange,
                  items: const [
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(
                        value: 'Custom', child: Text('Custom Date')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRange = value;
                        _currentDate = DateTime.now();
                        _customStartDate = null;
                        _customEndDate = null;
                      });

                      if (value == 'Custom') {
                        _selectCustomDateRange();
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed:
                      (_selectedRange != 'Custom') ? _goToPrevious : null,
                ),
                Text(
                  headerTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: (_canGoNext() && _selectedRange != 'Custom')
                        ? Colors.black
                        : Colors.grey,
                  ),
                  onPressed: (_canGoNext() && _selectedRange != 'Custom')
                      ? _goToNext
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart Container
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 400,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 254, 249, 249),
                borderRadius: BorderRadius.circular(25),
              ),
              child: MyChart(
                _filteredExpenses,
                key: ValueKey('$_selectedRange-$_currentDate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
