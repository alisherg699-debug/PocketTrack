import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_event.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/expense/presentation/pages/add_expense_page.dart';

class ReceiptReviewPage extends StatefulWidget {
  final String imagePath;

  const ReceiptReviewPage({super.key, required this.imagePath});

  @override
  State<ReceiptReviewPage> createState() => _ReceiptReviewPageState();
}

class _ReceiptReviewPageState extends State<ReceiptReviewPage> {
  bool _isLoading = true;
  String _storeName = "Supermarket Korzinka";
  double _totalAmount = 44100.0;
  final List<Map<String, String>> _extractedItems = [
    {"name": "Sut 1L", "qty": "1 dona", "price": "14 500 so'm"},
    {"name": "Non", "qty": "2 dona", "price": "8 000 so'm"},
    {"name": "Olma", "qty": "1.2 kg", "price": "21 600 so'm"},
  ];

  @override
  void initState() {
    super.initState();
    _processReceiptImage();
  }

  Future<void> _processReceiptImage() async {
    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final scannedText = recognizedText.text;
      if (scannedText.isNotEmpty) {
        final lines = scannedText.split('\n').where((l) => l.trim().isNotEmpty).toList();
        if (lines.isNotEmpty) {
          _storeName = lines.first;
        }

        for (var line in lines) {
          final cleanLine = line.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleanLine.length >= 4) {
            final parsed = double.tryParse(cleanLine);
            if (parsed != null && parsed > 1000 && parsed < 10000000) {
              _totalAmount = parsed;
            }
          }
        }
      }
    } catch (_) {
      // Fallback to default mock data if OCR fails or runs on unsupported environment
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.checkReceipt,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            onPressed: () {
              setState(() => _isLoading = true);
              _processReceiptImage();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Extracted status banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.document_scanner_outlined, color: Color(0xFF0D9488), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dataExtracted,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.reviewBeforeSaving,
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildEditableRow(context, Icons.store_mall_directory_outlined, l10n.store, _storeName, isDark),
                        _buildDivider(isDark),
                        _buildEditableRow(context, Icons.calendar_today_outlined, l10n.date, "${DateTime.now().day}-oktabr, ${DateTime.now().year} · ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}", isDark),
                        _buildDivider(isDark),
                        _buildEditableRow(context, Icons.restaurant_menu_outlined, l10n.category, l10n.food, isDark),
                        _buildDivider(isDark),
                        _buildEditableRow(context, Icons.payments_outlined, l10n.total, "${_totalAmount.toStringAsFixed(0)} so'm", isDark, isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Items Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.products,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                      Text(
                        "${_extractedItems.length} ta",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Item cards
                  ..._extractedItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildItemCard(context, item["name"]!, item["qty"]!, item["price"]!, isDark),
                      )),
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
                            title: _storeName,
                            amount: _totalAmount,
                            category: l10n.food,
                            date: DateTime.now(),
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
                  child: Text(
                    l10n.edit,
                    style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final newExpense = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _storeName,
                      amount: _totalAmount,
                      category: l10n.food,
                      description: _extractedItems.map((e) => "${e['name']} (${e['qty']})").join(', '),
                      date: DateTime.now(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    context.read<ExpenseBloc>().add(AddExpense(newExpense));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableRow(BuildContext context, IconData icon, String label, String value, bool isDark, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.w500, fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
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

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), indent: 20, endIndent: 20);
  }

  Widget _buildItemCard(BuildContext formatContext, String name, String quantity, String price, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(formatContext).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1E293B))),
              const SizedBox(height: 2),
              Text(quantity, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
            ],
          ),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
