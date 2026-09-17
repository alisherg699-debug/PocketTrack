import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/report/presentation/pages/monthly_report_page.dart';
import 'package:pockettrack/features/report/presentation/pages/comparison_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});


  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Statistika",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComparisonPage(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
                color: Color(0xFF1E293B),
                size: 22,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthlyReportPage(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.pie_chart_outline_rounded,
                color: Color(0xFF1E293B),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is ExpenseLoaded) {
            final expenses = state.expenses;
            final totalAmount =
                expenses.fold(0.0, (sum, item) => sum + item.amount);
            final weeklyData = _getWeeklyData(expenses);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeeklyChartCard(weeklyData, totalAmount),
                  const SizedBox(height: 32),
                  const Text(
                    "Kategoriyalar bo'yicha",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  ..._buildCategoryList(expenses, totalAmount),
                ],
              ),
            );
          }
          return const Center(child: Text("Ma'lumotlar yo'q"));
        },
      ),
    );
  }

  Widget _buildWeeklyChartCard(List<double> data, double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Haftalik sarf-xarajat",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              Text("Jami: ${_formatCurrency(total)} so'm",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488))),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.isEmpty
                    ? 100
                    : (data.reduce((a, b) => a > b ? a : b) * 1.2),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Dus',
                          'Ses',
                          'Cho',
                          'Pay',
                          'Jum',
                          'Sha',
                          'Yak'
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(days[value.toInt() % 7],
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data.length > i ? data[i] : 0,
                        color: const Color(0xFF0D9488),
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryList(List<Expense> expenses, double total) {
    Map<String, double> categorySums = {};
    for (var e in expenses) {
      categorySums[e.category] = (categorySums[e.category] ?? 0) + e.amount;
    }

    return categorySums.entries.map((entry) {
      double percent = total > 0 ? (entry.value / total) : 0;
      return _buildCategoryItem(
        icon: _getIconForCategory(entry.key),
        title: entry.key,
        percent: percent,
        amount: entry.value,
      );
    }).toList();
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required double percent,
    required double amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
              ),
              Text("${(percent * 100).toInt()}%",
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              const SizedBox(width: 12),
              Text("${_formatCurrency(amount)} so'm",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'oziq-ovqat':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'xaridlar':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  List<double> _getWeeklyData(List<Expense> expenses) {
    List<double> data = List.filled(7, 0.0);
    for (var e in expenses) {
      int weekday = e.date.weekday - 1;
      data[weekday] += e.amount;
    }
    return data;
  }
}
