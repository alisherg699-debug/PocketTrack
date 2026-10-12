import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';
import 'package:pockettrack/features/settings/application/settings_cubit.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final currentThemeMode = state.themeMode;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.appearance,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : const Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                height: 1.0,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTheme,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.appearanceSubtitle,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                // Light Mode Option
                _buildThemeCard(
                  context,
                  title: l10n.lightMode,
                  subtitle: l10n.lightModeDesc,
                  themeMode: ThemeMode.light,
                  isSelected: currentThemeMode == ThemeMode.light,
                  previewType: _ThemePreviewType.light,
                  l10n: l10n,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Dark Mode Option
                _buildThemeCard(
                  context,
                  title: l10n.darkMode,
                  subtitle: l10n.darkModeDesc,
                  themeMode: ThemeMode.dark,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  previewType: _ThemePreviewType.dark,
                  l10n: l10n,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // System Mode Option
                _buildThemeCard(
                  context,
                  title: l10n.systemMode,
                  subtitle: l10n.systemModeDesc,
                  themeMode: ThemeMode.system,
                  isSelected: currentThemeMode == ThemeMode.system,
                  previewType: _ThemePreviewType.system,
                  l10n: l10n,
                  isDark: isDark,
                ),
                const SizedBox(height: 28),

                // Bottom Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: Color(0xFF0D9488), size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.themeSavedInfo,
                          style: TextStyle(color: isDark ? const Color(0xFF99F6E4) : const Color(0xFF0F766E), fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ThemeMode themeMode,
    required bool isSelected,
    required _ThemePreviewType previewType,
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<SettingsCubit>().changeThemeMode(themeMode);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Mini Preview Thumbnail
            _buildPreviewThumbnail(previewType),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.selected,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Radio / Check Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0D9488) : (isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewThumbnail(_ThemePreviewType type) {
    return Container(
      width: 56,
      height: 72,
      decoration: BoxDecoration(
        color: type == _ThemePreviewType.dark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(6),
      child: type == _ThemePreviewType.system
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 30,
                  height: 6,
                  decoration: BoxDecoration(
                    color: type == _ThemePreviewType.dark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 6,
                  decoration: BoxDecoration(
                    color: type == _ThemePreviewType.dark ? Colors.white12 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
    );
  }
}

enum _ThemePreviewType { light, dark, system }
