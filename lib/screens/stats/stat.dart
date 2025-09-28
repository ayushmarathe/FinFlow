import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finflow/expense_repository.dart';

class MyChart extends StatefulWidget {
  final List<Expense> expenses;

  const MyChart(this.expenses, {super.key});

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  int? _touchedIndex; // Track the touched index

  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty) {
      return const Center(
        child: Text(
          "No transactions yet",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      );
    }

    Map<String, double> categoryTotals = {};
    Map<String, Color> categoryColors = {};

    for (var expense in widget.expenses) {
      String category = expense.category.name;
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + expense.amount;
      categoryColors[category] =
          Color(expense.category.color); // Convert int to Color
    }

    return Column(
      children: [
        // Pie Chart
        SizedBox(
          height: 200, // Fixed height for the pie chart
          child: PieChart(
            PieChartData(
              sections: _getSections(categoryTotals, categoryColors),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (event is FlTapUpEvent) {
                      final touchedIndex =
                          pieTouchResponse?.touchedSection?.touchedSectionIndex;

                      if (touchedIndex == null || touchedIndex < 0) {
                        _touchedIndex = null;
                      } else {
                        _touchedIndex = (_touchedIndex == touchedIndex)
                            ? null
                            : touchedIndex;
                      }
                    }
                  });
                },
              ),
            ),
          ),
        ),

        // 20px Space Below Pie Chart for Selected Info
        if (_touchedIndex != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                0, 60, 0, 0), // Space between chart & legend
            child: _buildSelectedCategoryInfo(categoryTotals, categoryColors),
          ),

        SizedBox(
          height: 50,
        ),
        // Scrollable Legend
        Expanded(
          child: SingleChildScrollView(
            child: _buildLegend(categoryTotals, categoryColors),
          ),
        ),
      ],
    );
  }

  /// Display info about the selected category
  Widget _buildSelectedCategoryInfo(
      Map<String, double> categoryTotals, Map<String, Color> categoryColors) {
    String category = categoryTotals.keys.elementAt(_touchedIndex!);
    double amount = categoryTotals[category]!;
    Color color = categoryColors[category]!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              category,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 5),
            Text(
              'Total Spent: ₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// Scrollable Legend
  Widget _buildLegend(
      Map<String, double> categoryTotals, Map<String, Color> categoryColors) {
    double totalExpense =
        categoryTotals.values.fold(0, (sum, value) => sum + value);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          // **Move Total Expense to the Top**
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.summarize,
                  color: Colors.black54, size: 20), // Small summary icon
              const SizedBox(width: 10),
              const Text(
                "Total Expense",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${totalExpense.toStringAsFixed(2)} ₹',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            ],
          ),

          const SizedBox(height: 10), // Space after total

          // **Divider for Separation**
          const Divider(thickness: 1, color: Colors.grey),

          // **Category-wise Breakdown**
          ...categoryTotals.entries.map((entry) {
            final color = categoryColors[entry.key]!;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.key,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    '${entry.value.toStringAsFixed(2)} ₹',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Creates sections for the pie chart using category-specific colors
  List<PieChartSectionData> _getSections(
      Map<String, double> categoryTotals, Map<String, Color> categoryColors) {
    double totalSpending =
        categoryTotals.values.fold(0, (sum, value) => sum + value);

    return categoryTotals.entries.map((entry) {
      final category = entry.key;
      final value = entry.value;
      final percentage = (value / totalSpending) * 100;
      final color = categoryColors[category]!;
      final isTouched = _touchedIndex != null &&
          _touchedIndex == categoryTotals.keys.toList().indexOf(category);

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: isTouched ? 100 : 80, // Enlarges the selected section
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
