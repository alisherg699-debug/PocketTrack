import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_event.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/income/application/income/income_bloc.dart';
import 'package:pockettrack/features/income/application/income/income_event.dart';
import 'package:pockettrack/features/income/application/income/income_state.dart';
import 'package:pockettrack/features/report/presentation/pages/export_page.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  DateTime selectedDate = DateTime(2026, 9);

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(GetExpenses());
    context.read<IncomeBloc>().add(GetIncomes());
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.report,
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: MultiBlocBuilder(
        builder: (context, expenseState, incomeState) {
          if (expenseState is ExpenseLoading || incomeState is IncomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseState is ExpenseLoaded && incomeState is IncomeLoaded) {
            final filteredExpenses = expenseState.expenses.where((e) =>
                e.date.year == selectedDate.year &&
                e.date.month == selectedDate.month).toList();
            
            final filteredIncomes = incomeState.incomes.where((i) =>
                i.date.year == selectedDate.year &&
                i.date.month == selectedDate.month).toList();

            final totalExpense = filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);
            final totalIncome = filteredIncomes.fold(0.0, (sum, item) => sum + item.amount);
            final balance = totalIncome - totalExpense;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelector(l10n),
                  const SizedBox(height: 24),
                  _buildIncomeExpenseRow(l10n, totalIncome, totalExpense),
                  const SizedBox(height: 16),
                  _buildBalanceSection(l10n, balance),
                  const SizedBox(height: 32),
                  _buildPieChartCard(l10n, filteredExpenses, totalExpense),
                  const SizedBox(height: 32),
                  Text(
                    l10n.topCategories,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  ..._buildSortedCategoryList(l10n, filteredExpenses, totalExpense),
                  const SizedBox(height: 32),
                  _buildDownloadButton(l10n),
                ],
              ),
            );
          }
          return Center(child: Text(l10n.noData));
        },
      ),
    );
  }

  Widget _buildMonthSelector(AppLocalizations l10n) {
    final monthName = DateFormat('MMMM yyyy', Localizations.localeOf(context).toString()).format(selectedDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => setState(() => selectedDate = DateTime(selectedDate.year, selectedDate.month - 1)), icon: const Icon(Icons.chevron_left)),
        Text(
          monthName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        IconButton(onPressed: () => setState(() => selectedDate = DateTime(selectedDate.year, selectedDate.month + 1)), icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  Widget _buildIncomeExpenseRow(AppLocalizations l10n, double income, double expense) {
    return Row(
      children: [
        Expanded(child: _buildMiniCard(l10n.totalIncome, l10n.som, income, const Color(0xFF0D9488), const Color(0xFFF0FDFA))),
        const SizedBox(width: 16),
        Expanded(child: _buildMiniCard(l10n.totalExpense, l10n.som, expense, const Color(0xFF1E293B), Colors.white)),
      ],
    );
  }

  Widget _buildMiniCard(String title, String currency, double amount, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text("${_formatCurrency(amount)} $currency", style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(AppLocalizations l10n, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.balance, style: const TextStyle(color: Color(0xFF0D9488), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                "${balance >= 0 ? '+' : ''}${_formatCurrency(balance)} ${l10n.som}",
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(AppLocalizations l10n, List<Expense> expenses, double total) {
    Map<String, double> categorySums = {};
    for (var e in expenses) {
      categorySums[e.category] = (categorySums[e.category] ?? 0) + e.amount;
    }

    final colors = [const Color(0xFF0D9488), const Color(0xFFF59E0B), const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFFEF4444)];
    int colorIndex = 0;

    List<PieChartSectionData> sections = categorySums.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '',
        radius: 35,
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(l10n.categoryAnalysis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 60, sections: sections)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.expenses, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    const Text("100%", style: TextStyle(color: Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSortedCategoryList(AppLocalizations l10n, List<Expense> expenses, double total) {
    Map<String, double> categorySums = {};
    for (var e in expenses) {
      categorySums[e.category] = (categorySums[e.category] ?? 0) + e.amount;
    }
    var sorted = categorySums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final colors = [const Color(0xFF10B981), const Color(0xFF0D9488), const Color(0xFFF59E0B)];

    return sorted.take(3).map((entry) {
      int idx = sorted.indexOf(entry);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[idx % colors.length], shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("${((entry.value / total) * 100).toInt()}% ulush", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
            Text("${_formatCurrency(entry.value)} ${l10n.som}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDownloadButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExportPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D9488),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: Text(l10n.downloadReport, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class MultiBlocBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ExpenseState expenseState, IncomeState incomeState) builder;
  const MultiBlocBuilder({super.key, required this.builder});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(builder: (context, exp) => BlocBuilder<IncomeBloc, IncomeState>(builder: (context, inc) => builder(context, exp, inc)));
  }
}
