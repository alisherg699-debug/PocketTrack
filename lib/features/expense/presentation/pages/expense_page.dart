import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/expense/presentation/pages/expense_details_page.dart';
import 'package:pockettrack/features/report/presentation/pages/statistics_page.dart';
import 'package:pockettrack/features/settings/presentation/pages/budget_page.dart';
import 'package:pockettrack/core/utils/currency_formatter.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String selectedFilter = 'Oy';
  double monthlyLimit = 2000000;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadLimit();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      monthlyLimit = prefs.getDouble('monthly_limit') ?? 2000000;
    });
  }

  Future<void> _saveLimit(double newLimit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_limit', newLimit);
    setState(() {
      monthlyLimit = newLimit;
    });
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.expenses,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetPage()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
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
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseLoaded) {
            final allExpenses = state.expenses;
            var filteredExpenses = _filterExpenses(allExpenses, selectedFilter);

            if (_searchQuery.isNotEmpty) {
              filteredExpenses = filteredExpenses
                  .where((e) =>
                      e.title.toLowerCase().contains(_searchQuery) ||
                      e.category.toLowerCase().contains(_searchQuery))
                  .toList();
            }

            final totalAmount = filteredExpenses.fold(
              0.0,
              (sum, item) => sum + item.amount,
            );
            final double percent = (totalAmount / monthlyLimit).clamp(0, 1);
            final groupedExpenses = _groupExpensesByDate(filteredExpenses, l10n);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLimitCard(totalAmount, monthlyLimit, percent),
                  const SizedBox(height: 24),
                  _buildSearchBar(l10n),
                  const SizedBox(height: 24),
                  _buildFilters(l10n),
                  const SizedBox(height: 28),
                  if (filteredExpenses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(l10n.noData,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...groupedExpenses.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(entry.key),
                          const SizedBox(height: 12),
                          ...entry.value
                              .map((e) => _buildExpenseItem(e))
                              .toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                ],
              ),
            );
          }
          return Center(child: Text(l10n.failedToLoadData));
        },
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.search,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => _searchController.clear())
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLimitCard(double total, double limit, double percent) {
    final l10n = AppLocalizations.of(context)!;
    String labelText = l10n.todayExpenses;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0D9488).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          // 1. TEPASI: STATISTIKAGA O'TADI
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsPage())),
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labelText, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text("${_formatCurrency(total)} so'm", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24, height: 1)),
                ],
              ),
            ),
          ),
          // 2. PASTI: LIMITNI O'ZGARTIRADI
          GestureDetector(
            onTap: _showSetLimitDialog,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              color: Colors.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${selectedFilter == 'Oy' ? 'Oy' : 'Davr'} limitining ${(percent * 100).toInt()}% sarflandi", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Row(
                        children: [
                          Text("${_formatCurrency(limit)} so'm", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_outlined, color: Colors.white70, size: 14),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: percent, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetLimitDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: monthlyLimit > 0 ? ThousandsSeparatorInputFormatter.format(monthlyLimit) : "",
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ICON BOX
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(
                Icons.money,
                color: Color(0xFF0D9488),
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.setMonthlyLimit,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Oylik sarf-xarajatlaringiz uchun limit belgilang",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            // AMOUNT INPUT
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9. ]')),
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: "Masalan: 2 000 000",
                  suffixText: "so'm ",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // BUTTONS
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        final newLimit = double.tryParse(controller.text.replaceAll(' ', ''));
                        if (newLimit != null) {
                          await _saveLimit(newLimit);
                        }
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(
                      l10n.save,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Expense> _filterExpenses(List<Expense> expenses, String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return expenses.where((expense) {
      final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
      switch (filter) {
        case 'Bugun': return expDate == today;
        case 'Hafta': 
          final weekAgo = today.subtract(const Duration(days: 7));
          return expDate.isAfter(weekAgo) || expDate == today;
        case 'Oy': return expDate.year == now.year && expDate.month == now.month;
        case 'Yil': return expDate.year == now.year;
        default: return true;
      }
    }).toList();
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses, AppLocalizations l10n) {
    Map<String, List<Expense>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    expenses.sort((a, b) => b.date.compareTo(a.date));
    for (var expense in expenses) {
      final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
      String label;
      if (expDate == today) {
        label = l10n.today;
      } else if (expDate == yesterday) {
        label = l10n.yesterday;
      } else {
        label = DateFormat('dd-MMMM, yyyy').format(expDate);
      }
      if (grouped.containsKey(label)) {
        grouped[label]!.add(expense);
      } else {
        grouped[label] = [expense];
      }
    }
    return grouped;
  }

  Widget _buildFilters(AppLocalizations l10n) {
    final List<String> filters = [l10n.today, l10n.week, l10n.month, l10n.year];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: filters.map((f) {
        bool isSelected = selectedFilter == f;
        return GestureDetector(
          onTap: () => setState(() => selectedFilter = f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D9488) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0D9488).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Text(f, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)));
  }

  Widget _buildExpenseItem(Expense expense) {
    IconData icon;
    Color iconColor;
    switch (expense.category.toLowerCase()) {
      case 'oziq-ovqat': icon = Icons.restaurant; iconColor = Colors.orange; break;
      case 'transport': icon = Icons.directions_car; iconColor = Colors.teal; break;
      case 'xaridlar': icon = Icons.shopping_bag_outlined; iconColor = Colors.purple; break;
      default: icon = Icons.payments_outlined; iconColor = const Color(0xFF0D9488);
    }
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseDetailsPage(expense: expense))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))), Text("${expense.category}  •  ${DateFormat('HH:mm').format(expense.date)}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))])),
            Text("- ${_formatCurrency(expense.amount)} so'm", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }
}
