// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'PocketTrack';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get home => 'Главная';

  @override
  String get expenses => 'Расходы';

  @override
  String get income => 'Доходы';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get budget => 'Бюджет';

  @override
  String get statistics => 'Статистика';

  @override
  String get report => 'Отчет';

  @override
  String get export => 'Экспорт';

  @override
  String get security => 'Безопасность';
}
