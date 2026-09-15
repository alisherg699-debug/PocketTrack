import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  DateTime startDate = DateTime(2026, 9, 1);
  DateTime endDate = DateTime(2026, 9, 15);
  String selectedFormat = 'PDF';

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D9488)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Eksport", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sana orali'gi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDateInput("Boshlanish sanasi", startDate, () => _selectDate(context, true))),
                const SizedBox(width: 16),
                Expanded(child: _buildDateInput("Tugash sanasi", endDate, () => _selectDate(context, false))),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Fayl formati", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            _buildFormatOption("PDF", "Chop etish va bo'lishish uchun qulay hisobot", Icons.picture_as_pdf_outlined),
            const SizedBox(height: 12),
            _buildFormatOption("Excel", "Batafsil tahlil va formulalar uchun jadval", Icons.grid_on_outlined),
            const SizedBox(height: 12),
            _buildFormatOption("CSV", "Boshqa moliya ilovalariga oson import qilish", Icons.storage_outlined),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$selectedFormat fayl tayyorlanmoqda..."), backgroundColor: const Color(0xFF0D9488)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text("Eksport qilish", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Text(
              DateFormat('dd.MM.yyyy').format(date), 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatOption(String title, String desc, IconData icon) {
    bool isSelected = selectedFormat == title;
    return GestureDetector(
      onTap: () => setState(() => selectedFormat = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3)),
                ],
              ),
            ),
            if (isSelected) 
              const Icon(Icons.check_circle, color: Color(0xFF0D9488), size: 24)
            else 
              Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0), width: 2))),
          ],
        ),
      ),
    );
  }
}
