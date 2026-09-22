import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/core/utils/currency_formatter.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';

import 'package:pockettrack/core/l10n/app_localizations.dart';

import '../../../report/pages/add_income_page.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  double totalMonthlyBudget = 2000000; 
  List<String> categories = [];
  Map<String, double> categoryBudgetLimits = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final List<String> defaultCats = [l10n.food, l10n.transport, l10n.shopping, l10n.payments, l10n.health, l10n.other];
    final List<String> cats = prefs.getStringList('custom_categories') ?? defaultCats;
    
    Map<String, double> tempBudgets = {};
    for (var cat in cats) {
      tempBudgets[cat] = prefs.getDouble('budget_$cat') ?? 0.0;
    }

    if (mounted) {
      setState(() {
        totalMonthlyBudget = prefs.getDouble('total_budget') ?? 2000000;
        categories = cats;
        categoryBudgetLimits = tempBudgets;
      });
    }
  }

  Future<void> _saveTotalBudget(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('total_budget', value);
    setState(() => totalMonthlyBudget = value);
  }

  Future<void> _saveCategoryLimit(String category, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget_$category', value);
    setState(() => categoryBudgetLimits[category] = value);
  }

  String _format(double amount) => amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.budget, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(l10n.monthlyBudget, totalMonthlyBudget, _saveTotalBudget, l10n),
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) return const Center(child: CircularProgressIndicator());
          if (state is ExpenseLoaded) {
            final now = DateTime.now();
            final monthlyExpenses = state.expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
            
            final totalSpent = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
            final double totalPercent = (totalSpent / totalMonthlyBudget).clamp(0, 1);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalCard(l10n, totalSpent, totalMonthlyBudget, totalPercent),
                  const SizedBox(height: 32),
                  Text(l10n.categoryAnalysis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  ...categories.map((cat) {
                    final spent = monthlyExpenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount);
                    final limit = categoryBudgetLimits[cat] ?? 0;
                    return _buildCategoryBudgetCard(l10n, cat, spent, limit);
                  }).toList(),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return Center(child: Text(l10n.noData));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddIncomePage()));
        },
        backgroundColor: const Color(0xFF0D9488),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text(l10n.addIncome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTotalCard(AppLocalizations l10n, double spent, double budget, double percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF0D9488).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.monthlyBudget, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text("${_format(budget)} ${l10n.som}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.spentOfBudget((percent * 100).toInt().toString()), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text("${_format(spent)} ${l10n.som}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: percent, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
          ),
        ],
      ),
    );
  }

  String _getLocalizedCategoryName(String cat, AppLocalizations l10n) {
    final lower = cat.toLowerCase();
    if (lower == 'oziq-ovqat' || lower == 'food' || lower == 'продукты' || lower == l10n.food.toLowerCase()) return l10n.food;
    if (lower == 'transport' || lower == 'транспорт' || lower == l10n.transport.toLowerCase()) return l10n.transport;
    if (lower == 'xaridlar' || lower == 'shopping' || lower == 'покупки' || lower == l10n.shopping.toLowerCase()) return l10n.shopping;
    if (lower == 'to\'lovlar' || lower == 'tolovlar' || lower == 'payments' || lower == 'платежи' || lower == l10n.payments.toLowerCase()) return l10n.payments;
    if (lower == 'salomatlik' || lower == 'health' || lower == 'здоровье' || lower == l10n.health.toLowerCase()) return l10n.health;
    if (lower == 'boshqa' || lower == 'other' || lower == 'другое' || lower == l10n.other.toLowerCase()) return l10n.other;
    return cat;
  }

  Widget _buildCategoryBudgetCard(AppLocalizations l10n, String title, double spent, double limit) {
    final String localizedTitle = _getLocalizedCategoryName(title, l10n);
    final double displayLimit = limit > 0 ? limit : 1.0; 
    final double percent = (spent / displayLimit).clamp(0, 1);
    final bool isOverBudget = spent > limit && limit > 0;
    
    Color barColor;
    final titleLower = title.toLowerCase();
    if (titleLower == 'oziq-ovqat' || titleLower == 'food' || titleLower == 'продукты' || titleLower == l10n.food.toLowerCase()) {
      barColor = const Color(0xFF0D9488);
    } else if (titleLower == 'transport' || titleLower == 'транспорт' || titleLower == l10n.transport.toLowerCase()) {
      barColor = Colors.blue;
    } else if (titleLower == 'xaridlar' || titleLower == 'shopping' || titleLower == 'покупки' || titleLower == l10n.shopping.toLowerCase()) {
      barColor = Colors.purple;
    } else if (titleLower == 'to\'lovlar' || titleLower == 'tolovlar' || titleLower == 'payments' || titleLower == 'платежи' || titleLower == l10n.payments.toLowerCase()) {
      barColor = Colors.orange;
    } else if (titleLower == 'salomatlik' || titleLower == 'health' || titleLower == 'здоровье' || titleLower == l10n.health.toLowerCase()) {
      barColor = Colors.pink;
    } else {
      barColor = Colors.blueGrey;
    }
    if (isOverBudget) barColor = Colors.red;

    return GestureDetector(
      onTap: () => _showEditDialog(l10n.categoryBudgetAllocated(localizedTitle), limit, (val) => _saveCategoryLimit(title, val), l10n),
      child: Container(
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
                Container(width: 8, height: 8, decoration: BoxDecoration(color: barColor, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(child: Text(localizedTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)))),
                Text(
                  "${spent.toInt()} / ${limit.toInt()}",
                  style: TextStyle(color: isOverBudget ? Colors.red : const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String title, double currentValue, Function(double) onSave, AppLocalizations l10n) {
    final controller = TextEditingController(
      text: currentValue > 0 ? ThousandsSeparatorInputFormatter.format(currentValue) : "",
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
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF0D9488),
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.budgetEditDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                decoration: InputDecoration(
                  hintText: "${l10n.exampleLunch.split(':')[0]}: 2 000 000",
                  suffixText: "${l10n.som} ",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        onSave(double.parse(controller.text.replaceAll(' ', '')));
                        Navigator.pop(context);
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
}
