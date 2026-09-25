import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/core/services/notification_service.dart';
import 'package:pockettrack/core/utils/currency_formatter.dart';
import 'package:pockettrack/features/income/application/income/income_bloc.dart';
import 'package:pockettrack/features/income/application/income/income_event.dart';
import 'package:pockettrack/features/income/domain/entities/income.dart';
import 'package:pockettrack/features/settings/application/settings_cubit.dart';
import 'package:pockettrack/core/utils/category_helper.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _amountController = TextEditingController(text: "");
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = "";
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final l10n = AppLocalizations.of(context)!;
      _nameController.text = l10n.salary;
      _selectedCategory = l10n.salary;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  List<String> _getCategories(AppLocalizations l10n) {
    return [
      l10n.salary,
      l10n.freelance,
      l10n.investment,
      l10n.gift,
      l10n.other,
    ];
  }

  void _saveIncome() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final amountText = _amountController.text.replaceAll(' ', '').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidInput)),
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

    NotificationService.showNotification(
      id: DateTime.now().hashCode,
      title: l10n.incomeAdded,
      body: l10n.incomeAddedBody(ThousandsSeparatorInputFormatter.format(amount), name),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = context.watch<SettingsCubit>().state.currency;
    final categories = _getCategories(l10n);

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
          l10n.addIncome,
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.enterAmount.toUpperCase(),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
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
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          hintText: "0",
                          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.1)),
                          border: InputBorder.none, 
                          isDense: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9. ]')),
                          ThousandsSeparatorInputFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencySymbol,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildLabel(l10n.title),
            _buildTextField(_nameController, l10n.exampleSalary),
            const SizedBox(height: 24),
            _buildLabel(l10n.category),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((cat) => _buildCategoryChip(cat)).toList(),
            ),
            const SizedBox(height: 24),
            _buildLabel(l10n.description),
            _buildTextField(_descController, l10n.addDescription, maxLines: 3),
            const SizedBox(height: 24),
            _buildLabel(l10n.date),
            _buildStaticField("${l10n.today}, ${DateFormat('HH:mm', l10n.localeName).format(DateTime.now())}"),
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
            child: Text(
              l10n.save,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = CategoryHelper.getLocalizedName(label, l10n);
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
          displayTitle,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
