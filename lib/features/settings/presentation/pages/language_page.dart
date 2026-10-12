import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/features/settings/application/settings_cubit.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.selectLanguage,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildLanguageItem(
                  context,
                  "🇺🇿 O'zbekcha",
                  "uz",
                  state.locale.languageCode == "uz",
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildLanguageItem(
                  context,
                  "🇷🇺 Русский",
                  "ru",
                  state.locale.languageCode == "ru",
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildLanguageItem(
                  context,
                  "🇺🇸 English",
                  "en",
                  state.locale.languageCode == "en",
                  isDark,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    String title,
    String code,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<SettingsCubit>().changeLanguage(code);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0D9488)),
          ],
        ),
      ),
    );
  }
}
