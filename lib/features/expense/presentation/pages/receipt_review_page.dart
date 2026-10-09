import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_event.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/expense/presentation/pages/add_expense_page.dart';

class ReceiptReviewPage extends StatelessWidget {
  final String imagePath;

  const ReceiptReviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Chekni tekshirish",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
            onPressed: () {
              // Rescan action simulation
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Extracted status banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.document_scanner_outlined, color: Color(0xFF0D9488), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ma'lumotlar ajratib olindi",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Saqlashdan oldin tekshirib chiqing",
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary Info Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildEditableRow(Icons.store_mall_directory_outlined, "Do'kon", "Korzinka — Chilonzor"),
                  _buildDivider(),
                  _buildEditableRow(Icons.calendar_today_outlined, "Sana", "5-oktabr, 2026 · 18:42"),
                  _buildDivider(),
                  _buildEditableRow(Icons.restaurant_menu_outlined, "Kategoriya", "Oziq-ovqat"),
                  _buildDivider(),
                  _buildEditableRow(Icons.payments_outlined, "Jami", "44 100 so'm", isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Mahsulotlar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text(
                  "3 ta",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item cards
            _buildItemCard("Sut 1L", "1 dona", "14 500 so'm"),
            const SizedBox(height: 8),
            _buildItemCard("Non", "2 dona", "8 000 so'm"),
            const SizedBox(height: 8),
            _buildItemCard("Olma", "1.2 kg", "21 600 so'm"),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpensePage(
                          expenseToEdit: Expense(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'Korzinka — Chilonzor',
                            amount: 44100,
                            category: 'Oziq-ovqat',
                            date: DateTime(2026, 10, 5, 18, 42),
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "Tahrirlash",
                    style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final newExpense = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Korzinka — Chilonzor',
                      amount: 44100,
                      category: 'Oziq-ovqat',
                      description: 'Sut 1L, Non (2), Olma (1.2kg)',
                      date: DateTime(2026, 10, 5, 18, 42),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    context.read<ExpenseBloc>().add(AddExpense(newExpense));
                    Navigator.pop(context); // Pop review page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Saqlash",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500, fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit_outlined, color: Color(0xFF94A3B8), size: 16),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 20, endIndent: 20);
  }

  Widget _buildItemCard(String name, String quantity, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
              const SizedBox(height: 2),
              Text(quantity, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ],
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
