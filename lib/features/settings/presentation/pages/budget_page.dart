import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/income/presentation/pages/add_income_page.dart';

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
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cats = prefs.getStringList('custom_categories') ?? 
        ['Oziq-ovqat', 'Transport', 'Xaridlar', 'To\'lovlar', 'Salomatlik', 'Boshqa'];
    
    Map<String, double> tempBudgets = {};
    for (var cat in cats) {
      tempBudgets[cat] = prefs.getDouble('budget_$cat') ?? 0.0;
    }

    setState(() {
      totalMonthlyBudget = prefs.getDouble('total_budget') ?? 2000000;
      categories = cats;
      categoryBudgetLimits = tempBudgets;
    });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Byudjet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog("Oylik byudjet miqdori", totalMonthlyBudget, _saveTotalBudget),
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
                  _buildTotalCard(totalSpent, totalMonthlyBudget, totalPercent),
                  const SizedBox(height: 32),
                  const Text("Kategoriyalar bo'yicha", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  ...categories.map((cat) {
                    final spent = monthlyExpenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount);
                    final limit = categoryBudgetLimits[cat] ?? 0;
                    return _buildCategoryBudgetCard(cat, spent, limit);
                  }).toList(),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return const Center(child: Text("Ma'lumotlar yo'q"));
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
        label: const Text("Daromad qo'shish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTotalCard(double spent, double budget, double percent) {
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
          const Text("OYLIK BYUDJET", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text("${_format(budget)} so'm", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Byudjetning ${(percent * 100).toInt()}% sarflandi", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text("${_format(spent)} so'm", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildCategoryBudgetCard(String title, double spent, double limit) {
    final double displayLimit = limit > 0 ? limit : 1.0; 
    final double percent = (spent / displayLimit).clamp(0, 1);
    final bool isOverBudget = spent > limit && limit > 0;
    
    Color barColor;
    switch (title.toLowerCase()) {
      case 'oziq-ovqat': barColor = const Color(0xFF0D9488); break;
      case 'transport': barColor = Colors.blue; break;
      case 'xaridlar': barColor = Colors.purple; break;
      case 'to\'lovlar': barColor = Colors.orange; break;
      default: barColor = Colors.blueGrey;
    }
    if (isOverBudget) barColor = Colors.red;

    return GestureDetector(
      onTap: () => _showEditDialog("$title uchun ajratilgan byudjet", limit, (val) => _saveCategoryLimit(title, val)),
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
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)))),
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

  void _showEditDialog(String title, double currentValue, Function(double) onSave) {
    final controller = TextEditingController(text: currentValue > 0 ? currentValue.toStringAsFixed(0) : "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: const InputDecoration(hintText: "Summani kiriting", suffixText: " so'm", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Bekor qilish")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(double.parse(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text("Saqlash", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
