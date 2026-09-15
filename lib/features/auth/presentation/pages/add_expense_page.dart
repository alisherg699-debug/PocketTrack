import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../expense/application/expense/expense_bloc.dart';
import '../../../expense/application/expense/expense_event.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../../core/services/notification_service.dart';

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
      text: widget.expenseToEdit?.amount.toString() ?? '',
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

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.expenseToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing ? "Xarajatni tahrirlash" : "Xarajat qo'shish",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      autofocus: !isEditing,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Geist',
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "0",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "so'm",
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              "Xarajat nomi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _titleController,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: "Masalan: Tushlik",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Kategoriya",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 10.0,
              children: categories.map((category) {
                bool isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              "Tavsif",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _descController,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: "Qo'shimcha ma'lumot kiriting...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                ),
              ),
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _amountController.text.isNotEmpty) {
              
              if (isEditing) {
                final updatedExpense = widget.expenseToEdit!.copyWith(
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0.0,
                  category: selectedCategory,
                  description: _descController.text,
                  updatedAt: DateTime.now(),
                );
                context.read<ExpenseBloc>().add(UpdateExpense(updatedExpense));
                Navigator.pop(context);
                Navigator.pop(context);
              } else {

                final expense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0.0,
                  category: selectedCategory,
                  description: _descController.text,
                  date: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                context.read<ExpenseBloc>().add(AddExpense(expense));
                NotificationService.showNotification(
                  id: 1,
                  title: "Xarajat qo'shildi",
                  body: "${expense.title} uchun ${expense.amount.toStringAsFixed(0)} so'm sarflandi",
                );

                Navigator.pop(context);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Iltimos, nomi va miqdorini kiriting"),
                ),
              );
            }
          },
          child: Text(
            isEditing ? "Xarajatni yangilash" : "Xarajatni saqlash",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
