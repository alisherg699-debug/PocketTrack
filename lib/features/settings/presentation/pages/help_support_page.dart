import 'package:flutter/material.dart';
import 'package:pockettrack/l10n/app_localizations.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.helpSupport, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tez-tez beriladigan savollar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            _buildFaqItem("Xarajatlarni qanday eksport qilsam bo'ladi?", "Xarajatlar tarixi sahifasida o'ng tepadagi sozlamalar tugmasini bosing va 'Eksport' bo'limini tanlang."),
            _buildFaqItem("Ma'lumotlarim xavfsizligi qanday ta'minlangan?", "Ma'lumotlaringiz Firebase bulutli serverlarida xavfsiz saqlanadi va PIN-kod orqali qo'shimcha himoyalangan."),
            _buildFaqItem("Byudjetni qanday o'zgartirsa bo'ladi?", "Byudjet sahifasida o'ng tepadagi sozlamalar tugmasi orqali oylik limitni, kartalar ustiga bosish orqali kategoriya limitlarini o'zgartirishingiz mumkin."),
            const SizedBox(height: 32),
            const Text(
              "Biz bilan bog'lanish",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            _buildSupportButton(
              icon: Icons.send_rounded,
              title: "Telegram orqali bog'lanish",
              color: const Color(0xFF0088CC),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSupportButton(
              icon: Icons.email_outlined,
              title: "Email orqali bog'lanish",
              color: const Color(0xFF0D9488),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportButton({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }
}
