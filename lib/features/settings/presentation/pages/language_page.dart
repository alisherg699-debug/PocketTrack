import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/features/settings/application/settings_cubit.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.selectLanguage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildLanguageItem(context, "O'zbekcha", "uz", state.locale.languageCode == "uz"),
                const SizedBox(height: 12),
                _buildLanguageItem(context, "Русский", "ru", state.locale.languageCode == "ru"),
                const SizedBox(height: 12),
                _buildLanguageItem(context, "English", "en", state.locale.languageCode == "en"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String title, String code, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<SettingsCubit>().changeLanguage(code);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Row(
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF1E293B))),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF0D9488)),
          ],
        ),
      ),
    );
  }
}
