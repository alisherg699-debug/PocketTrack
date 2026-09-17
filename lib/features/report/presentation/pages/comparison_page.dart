import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  late DateTime firstMonth;
  late DateTime secondMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    secondMonth = DateTime(now.year, now.month);
    firstMonth = DateTime(now.year, now.month - 1);
  }

  String _formatK(double amount) {
    if (amount >= 1000) return "${(amount / 1000).toStringAsFixed(0)}k";
    return amount.toStringAsFixed(0);
  }

  // Oylarni tanlash uchun picker
  Future<void> _pickMonth(bool isFirst) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFirst ? firstMonth : secondMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: isFirst ? "Birinchi oyni tanlang" : "Ikkinchi oyni tanlang",
    );
    if (picked != null) {
      setState(() {
        if (isFirst) firstMonth = DateTime(picked.year, picked.month);
        else secondMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Solishtirish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) return const Center(child: CircularProgressIndicator());
          if (state is ExpenseLoaded) {
            final expenses = state.expenses;

            final m1Data = _getMonthStats(expenses, firstMonth);
            final m2Data = _getMonthStats(expenses, secondMonth);

            final totalDiffPercent = m1Data.total > 0 
                ? ((m2Data.total - m1Data.total) / m1Data.total * 100) 
                : (m2Data.total > 0 ? 100.0 : 0.0);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthHeader(),
                        const SizedBox(height: 24),
                        _buildComparisonChart(m1Data.total, m2Data.total),
                        const SizedBox(height: 32),
                        const Text("Kategoriyalar tahlili", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 16),
                        if (m1Data.categories.isEmpty && m2Data.categories.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("Ushbu oylar uchun ma'lumot topilmadi")))
                        else
                          ..._buildCategoryComparisonList(m1Data.categories, m2Data.categories),
                      ],
                    ),
                  ),
                ),
                _buildSummaryFooter(totalDiffPercent),
              ],
            );
          }
          return const Center(child: Text("Ma'lumotlar yuklanmadi"));
        },
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(onTap: () => _pickMonth(true), child: _buildMonthButton(DateFormat('MMMM').format(firstMonth))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("vs", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold))),
        GestureDetector(onTap: () => _pickMonth(false), child: _buildMonthButton(DateFormat('MMMM').format(secondMonth))),
      ],
    );
  }

  Widget _buildMonthButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(double m1Total, double m2Total) {
    double maxY = (m1Total > m2Total ? m1Total : m2Total) * 1.3;
    if (maxY == 0) maxY = 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Umumiy taqqoslash", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat('MMM').format(firstMonth), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)));
                        if (value == 1) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat('MMM').format(secondMonth), style: const TextStyle(color: Color(0xFF0D9488), fontSize: 12, fontWeight: FontWeight.bold)));
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: m1Total, color: const Color(0xFF94A3B8), width: 30, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: m2Total, color: const Color(0xFF0D9488), width: 30, borderRadius: BorderRadius.circular(4))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryComparisonList(Map<String, double> m1Cats, Map<String, double> m2Cats) {
    Set<String> allCategories = {...m1Cats.keys, ...m2Cats.keys};
    return allCategories.map((cat) {
      double v1 = m1Cats[cat] ?? 0;
      double v2 = m2Cats[cat] ?? 0;
      double diff = v1 > 0 ? ((v2 - v1) / v1 * 100) : (v2 > 0 ? 100.0 : 0.0);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("${DateFormat('MMM').format(firstMonth)}: ${_formatK(v1)}  •  ${DateFormat('MMM').format(secondMonth)}: ${_formatK(v2)}", 
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: diff <= 0 ? const Color(0xFFF0FDFA) : const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(20)),
              child: Text(
                "${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}%",
                style: TextStyle(color: diff <= 0 ? const Color(0xFF0D9488) : const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSummaryFooter(double percent) {
    bool isSaving = percent <= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Color(0xFFF0FDFA), border: Border(top: BorderSide(color: Color(0xFF0D9488), width: 0.5))),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(isSaving ? Icons.trending_down : Icons.trending_up, color: const Color(0xFF0D9488)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Bu oy o'tgan oyga nisbatan ${percent.abs().toStringAsFixed(0)}% ${isSaving ? 'kam' : 'ko\'p'} sarfladingiz",
                style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MonthStats _getMonthStats(List<Expense> expenses, DateTime month) {
    final filtered = expenses.where((e) => e.date.year == month.year && e.date.month == month.month).toList();
    double total = filtered.fold(0.0, (sum, e) => sum + e.amount);
    Map<String, double> categories = {};
    for (var e in filtered) {
      categories[e.category] = (categories[e.category] ?? 0) + e.amount;
    }
    return _MonthStats(total, categories);
  }
}

class _MonthStats {
  final double total;
  final Map<String, double> categories;
  _MonthStats(this.total, this.categories);
}
