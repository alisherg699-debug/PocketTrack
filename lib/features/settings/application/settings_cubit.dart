import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final Locale locale;
  final String currency;

  const SettingsState({
    required this.locale,
    this.currency = 'so\'m',
  });

  SettingsState copyWith({
    Locale? locale,
    String? currency,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(
          const SettingsState(
            locale: Locale('uz'),
            currency: 'so\'m',
          ),
        ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'uz';
    final currency = prefs.getString('user_currency') ?? 'so\'m';
    emit(SettingsState(locale: Locale(languageCode), currency: currency));
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
}
