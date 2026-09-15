import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/notification_service.dart';
import '../../../income/application/income/income_bloc.dart';
import '../../../income/application/income/income_event.dart';
import '../../../income/domain/entities/income.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _amountController = TextEditingController(text: "");
  final _nameController = TextEditingController(text: "Oylik maosh");
  final _descController = TextEditingController();
  String _selectedCategory = "Oylik maosh";

  final List<String> _categories = [
    "Oylik maosh",
    "Freelance",
    "Investitsiya",
    "Sovg'a",
    "Boshqa"
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveIncome() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, nomi va miqdorini to'g'ri kiriting")),
      );
      return;
    }

    final income = Income(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      amount: amount,
      category: _selectedCategory,
      description: _descController.text.trim(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<IncomeBloc>().add(AddIncome(income));

    // Bildirishnoma yuborish
    NotificationService.showNotification(
      id: DateTime.now().hashCode,
      title: "Daromad qo'shildi",
      body: "$name uchun ${amount.toStringAsFixed(0)} so'm qabul qilindi",
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Daromad qo'shish",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "MIQDORNI KIRITING",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: "0.00",
                        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.1)),
                        border: InputBorder.none, 
                        isDense: true
                      ),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "so'm",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildLabel("Daromad nomi"),
            _buildTextField(_nameController, "Masalan: Oylik"),
            const SizedBox(height: 24),
            _buildLabel("Kategoriya"),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((cat) => _buildCategoryChip(cat)).toList(),
            ),
            const SizedBox(height: 24),
            _buildLabel("Tavsif"),
            _buildTextField(_descController, "Qo'shimcha ma'lumot kiriting...", maxLines: 3),
            const SizedBox(height: 24),
            _buildLabel("Sana va vaqt"),
            _buildStaticField("Bugun, ${DateFormat('HH:mm').format(DateTime.now())}"),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _saveIncome,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text(
              "Daromadni saqlash",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      ),
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
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStaticField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B))),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
