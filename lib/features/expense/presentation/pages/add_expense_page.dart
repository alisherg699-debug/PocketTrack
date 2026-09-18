import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/core/services/notification_service.dart';
import 'package:pockettrack/core/utils/currency_formatter.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_event.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';

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

  void _saveExpense() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.replaceAll(' ', '').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, nomi va miqdorini to'g'ri kiriting")),
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
      
      NotificationService.showNotification(
        id: DateTime.now().hashCode,
        title: "Xarajat qo'shildi",
        body: "$title uchun ${ThousandsSeparatorInputFormatter.format(amount)} so'm sarflandi",
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.expenseToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing ? "Xarajatni tahrirlash" : "Xarajat qo'shish",
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
            const Align(
              alignment: Alignment.center,
              child: Text(
                "MIQDORNI KIRITING",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
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
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.1)),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9. ]')),
                          ThousandsSeparatorInputFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "so'm",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF0D9488)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            _buildLabel("Xarajat nomi"),
            _buildTextField(_titleController, "Masalan: Tushlik"),
            const SizedBox(height: 24),
            _buildLabel("Kategoriya"),
            Wrap(
              spacing: 8.0,
              runSpacing: 10.0,
              children: categories.map((category) {
                bool isSelected = selectedCategory == category;
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
                      category,
                      style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildLabel("Tavsif"),
            _buildTextField(_descController, "Qo'shimcha ma'lumot kiriting...", maxLines: 3),
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
            isEditing ? "Xarajatni yangilash" : "Xarajatni saqlash",
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
