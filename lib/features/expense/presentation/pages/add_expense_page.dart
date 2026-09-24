import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/core/services/notification_service.dart';
import 'package:pockettrack/core/utils/currency_formatter.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_event.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/settings/presentation/pages/categories_page.dart';
import 'package:pockettrack/core/utils/category_helper.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpensePage({super.key, this.expenseToEdit});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  String selectedCategory = 'Oziq-ovqat';
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    _amountController = TextEditingController(
      text: widget.expenseToEdit != null 
          ? ThousandsSeparatorInputFormatter.format(widget.expenseToEdit!.amount)
          : '',
    );
    _titleController = TextEditingController(
      text: widget.expenseToEdit?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.expenseToEdit?.description ?? '',
    );
    
    if (widget.expenseToEdit != null) {
      selectedCategory = widget.expenseToEdit!.category;
    }

    _amountController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      categories = prefs.getStringList('custom_categories') ?? 
          ['Oziq-ovqat', 'Transport', 'Xaridlar', 'To\'lovlar', 'Salomatlik', 'Boshqa'];
      
      if (!categories.contains(selectedCategory)) {
        selectedCategory = categories.first;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _checkBudgetAlert(double newExpenseAmount, AppLocalizations l10n) async {
    final prefs = await SharedPreferences.getInstance();
    final bool budgetAlertEnabled = prefs.getBool('budget_alert') ?? true;
    if (!budgetAlertEnabled) return;

    final double totalBudget = prefs.getDouble('total_budget') ?? 2000000.0;
    final int alertThreshold = prefs.getInt('alert_threshold') ?? 80;

    if (totalBudget <= 0) return;
    if (!mounted) return;

    final expenseState = context.read<ExpenseBloc>().state;
    double currentMonthlyTotal = 0.0;

    if (expenseState is ExpenseLoaded) {
      final now = DateTime.now();
      currentMonthlyTotal = expenseState.expenses
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .fold(0.0, (sum, e) => sum + e.amount);
    }

    final double totalSpentWithNew = currentMonthlyTotal + newExpenseAmount;
    final int newPercent = ((totalSpentWithNew / totalBudget) * 100).toInt();

    if (newPercent >= alertThreshold) {
      await Future.delayed(const Duration(milliseconds: 600));
      await NotificationService.showNotification(
        id: DateTime.now().hashCode + 1,
        title: l10n.budgetAlertTitle,
        body: l10n.spentOfBudget(newPercent.toString()),
      );
    }
  }

  void _saveExpense() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final amountText = _amountController.text.replaceAll(' ', '').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidInput)),
      );
      return;
    }

    if (widget.expenseToEdit != null) {
      final updatedExpense = widget.expenseToEdit!.copyWith(
        title: title,
        amount: amount,
        category: selectedCategory,
        description: _descController.text.trim(),
        updatedAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(UpdateExpense(updatedExpense));
      Navigator.pop(context);
    } else {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        category: selectedCategory,
        description: _descController.text.trim(),
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(AddExpense(expense));
      
      final notificationTitle = l10n.expenseAdded;

      final notificationBody = l10n.localeName == 'uz'
          ? "$title uchun ${ThousandsSeparatorInputFormatter.format(amount)} ${l10n.som} sarflandi"
          : l10n.localeName == 'ru'
              ? "Потрачено ${ThousandsSeparatorInputFormatter.format(amount)} ${l10n.som} на $title"
              : "Spent ${ThousandsSeparatorInputFormatter.format(amount)} ${l10n.som} for $title";

      NotificationService.showNotification(
        id: DateTime.now().hashCode,
        title: notificationTitle,
        body: notificationBody,
      );

      await _checkBudgetAlert(amount, l10n);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isEditing = widget.expenseToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editExpense : l10n.addExpense,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: categories.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: Text(
                l10n.amount.toUpperCase(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        autofocus: !isEditing,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "0",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.1)),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9. ]')),
                          ThousandsSeparatorInputFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.som,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF0D9488)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            _buildLabel(l10n.title),
            _buildTextField(_titleController, l10n.exampleLunch),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel(l10n.category),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D9488), size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesPage()),
                    ).then((_) => _loadCategories());
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 10.0,
              children: categories.map((category) {
                bool isSelected = selectedCategory == category;
                final displayTitle = CategoryHelper.getLocalizedName(category, l10n);
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0D9488) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: Text(
                      displayTitle,
                      style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildLabel(l10n.description),
            _buildTextField(_descController, l10n.addDescription, maxLines: 3),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: _saveExpense,
          child: Text(
            isEditing ? l10n.edit : l10n.save,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
        ),
      ),
    );
  }
}
