import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final Locale locale;
  final String currency;
  final ThemeMode themeMode;

  const SettingsState({
    required this.locale,
    this.currency = 'so\'m',
    this.themeMode = ThemeMode.system,
  });

  SettingsState copyWith({
    Locale? locale,
    String? currency,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(
          const SettingsState(
            locale: Locale('uz'),
            currency: 'so\'m',
            themeMode: ThemeMode.system,
          ),
        ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'uz';
    final currency = prefs.getString('user_currency') ?? 'so\'m';
    final themeModeStr = prefs.getString('theme_mode') ?? 'system';

    ThemeMode themeMode = ThemeMode.system;
    if (themeModeStr == 'light') {
      themeMode = ThemeMode.light;
    } else if (themeModeStr == 'dark') {
      themeMode = ThemeMode.dark;
    }

    emit(state.copyWith(
      locale: Locale(languageCode),
      currency: currency,
      themeMode: themeMode,
    ));
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    emit(state.copyWith(locale: Locale(languageCode)));
  }

  Future<void> changeCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_currency', currency);
    emit(state.copyWith(currency: currency));
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeStr = 'system';
    if (themeMode == ThemeMode.light) {
      themeModeStr = 'light';
    } else if (themeMode == ThemeMode.dark) {
      themeModeStr = 'dark';
    }
    await prefs.setString('theme_mode', themeModeStr);
    emit(state.copyWith(themeMode: themeMode));
  }
}
