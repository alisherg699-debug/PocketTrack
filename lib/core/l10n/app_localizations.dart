import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('uz'),
    Locale('ru'),
  ];

  static const Map<String, Map<String, String>> _defaultValues = {
    'uz': {
      'welcome': "Xush kelibsiz",
      'loginSubtitle': "Moliyangizni oson kuzatish uchun tizimga kiring.",
      'emailHint': "pochta@misol.com",
      'enterPassword': "Parolingizni kiriting",
      'fillAllFields': "Barcha maydonlarni to'ldiring",
      'email': "Elektron pochta",
      'password': "Parol",
      'forgotPassword': "Parolni unutdingizmi?",
      'login': "Kirish",
      'register': "Ro'yxatdan o'tish",
      'dontHaveAccount': "Hisobingiz yo'qmi?",
    },
    'ru': {
      'welcome': "Добро пожаловать",
      'loginSubtitle': "Войдите, чтобы легко отслеживать свои финансы.",
      'emailHint': "почта@пример.com",
      'enterPassword': "Введите ваш пароль",
      'fillAllFields': "Пожалуйста, заполните все поля",
      'email': "Электронная почта",
      'password': "Пароль",
      'forgotPassword': "Забыли пароль?",
      'login': "Вход",
      'register': "Регистрация",
      'dontHaveAccount': "Нет аккаунта?",
    },
    'en': {
      'welcome': "Welcome",
      'loginSubtitle': "Log in to easily track your finances.",
      'emailHint': "email@example.com",
      'enterPassword': "Enter your password",
      'fillAllFields': "Please fill all fields",
      'email': "Email",
      'password': "Password",
      'forgotPassword': "Forgot password?",
      'login': "Login",
      'register': "Register",
      'dontHaveAccount': "Don't have an account?",
    },
  };

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      debugPrint("Error loading localization asset: $e");
      return false;
    }
  }

  String translate(String key) {
    if (_localizedStrings.containsKey(key) && _localizedStrings[key]!.isNotEmpty) {
      return _localizedStrings[key]!;
    }
    final lang = locale.languageCode;
    if (_defaultValues.containsKey(lang) && _defaultValues[lang]!.containsKey(key)) {
      return _defaultValues[lang]![key]!;
    }
    if (_defaultValues['uz']!.containsKey(key)) {
      return _defaultValues['uz']![key]!;
    }
    return key;
  }

  String get localeName => locale.languageCode;

  // Key Getters
  String get appTitle => translate('appTitle');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get loginSubtitle => translate('loginSubtitle');
  String get emailHint => translate('emailHint');
  String get register => translate('register');
  String get home => translate('home');
  String get expenses => translate('expenses');
  String get income => translate('income');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get budget => translate('budget');
  String get statistics => translate('statistics');
  String get report => translate('report');
  String get export => translate('export');
  String get security => translate('security');
  String get logout => translate('logout');
  String get accountSettings => translate('accountSettings');
  String get categories => translate('categories');
  String get notifications => translate('notifications');
  String get helpSupport => translate('helpSupport');
  String get changeLanguage => translate('changeLanguage');
  String get email => translate('email');
  String get password => translate('password');
  String get enterPassword => translate('enterPassword');
  String get forgotPassword => translate('forgotPassword');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get todayExpenses => translate('todayExpenses');
  String get todayOperations => translate('todayOperations');
  String get seeAll => translate('seeAll');
  String get addExpense => translate('addExpense');
  String get addIncome => translate('addIncome');
  String get editExpense => translate('editExpense');
  String get amount => translate('amount');
  String get title => translate('title');
  String get description => translate('description');
  String get category => translate('category');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get noData => translate('noData');
  String get confirmLogout => translate('confirmLogout');
  String get enterPin => translate('enterPin');
  String get setPin => translate('setPin');
  String get fullName => translate('fullName');
  String get phoneNumber => translate('phoneNumber');
  String get currency => translate('currency');
  String get next => translate('next');
  String get back => translate('back');
  String get skip => translate('skip');
  String get getStarted => translate('getStarted');
  String get onboarding1Title => translate('onboarding1Title');
  String get onboarding1Desc => translate('onboarding1Desc');
  String get onboarding2Title => translate('onboarding2Title');
  String get onboarding2Desc => translate('onboarding2Desc');
  String get onboarding3Title => translate('onboarding3Title');
  String get onboarding3Desc => translate('onboarding3Desc');
  String get totalBalance => translate('totalBalance');
  String get spent => translate('spent');
  String get remaining => translate('remaining');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get week => translate('week');
  String get month => translate('month');
  String get year => translate('year');
  String get selectCategory => translate('selectCategory');
  String get enterAmount => translate('enterAmount');
  String get enterTitle => translate('enterTitle');
  String get passwordStrength => translate('passwordStrength');
  String get weak => translate('weak');
  String get medium => translate('medium');
  String get strong => translate('strong');
  String get min8Chars => translate('min8Chars');
  String get uppercase => translate('uppercase');
  String get digit => translate('digit');
  String get specialChar => translate('specialChar');
  String get passwordReset => translate('passwordReset');
  String get enterEmailToReset => translate('enterEmailToReset');
  String get sendCode => translate('sendCode');
  String get enterCode => translate('enterCode');
  String get checkEmail => translate('checkEmail');
  String get newPassword => translate('newPassword');
  String get confirmPassword => translate('confirmPassword');
  String get currentPassword => translate('currentPassword');
  String get changePassword => translate('changePassword');
  String get expenseDetails => translate('expenseDetails');
  String get deleteExpense => translate('deleteExpense');
  String get confirmDeleteExpense => translate('confirmDeleteExpense');
  String get comparisonTitle => translate('comparisonTitle');
  String get date => translate('date');
  String get created => translate('created');
  String get updated => translate('updated');
  String get noDescription => translate('noDescription');
  String get selectFirstMonth => translate('selectFirstMonth');
  String get selectSecondMonth => translate('selectSecondMonth');
  String get vs => translate('vs');
  String get totalComparison => translate('totalComparison');
  String get categoryAnalysis => translate('categoryAnalysis');
  String get noDataForMonths => translate('noDataForMonths');
  String get dataNotLoaded => translate('dataNotLoaded');
  String get less => translate('less');
  String get more => translate('more');
  String get reportHeader => translate('reportHeader');
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  String get passwordsInvalid => translate('passwordsInvalid');
  String get retry => translate('retry');
  String get noExpensesForPeriod => translate('noExpensesForPeriod');
  String get savedSuccessfully => translate('savedSuccessfully');
  String get selectLimitPercentage => translate('selectLimitPercentage');
  String get fillAllFields => translate('fillAllFields');
  String get passwordTooShort => translate('passwordTooShort');
  String get accountCreatedSuccess => translate('accountCreatedSuccess');
  String get registerSubtitle => translate('registerSubtitle');
  String get createStrongPassword => translate('createStrongPassword');
  String get repeatPassword => translate('repeatPassword');
  String get verificationCode => translate('verificationCode');
  String get passwordChangedSuccess => translate('passwordChangedSuccess');
  String get resetEmailSubtitle => translate('resetEmailSubtitle');
  String get enterOtpSubtitle => translate('enterOtpSubtitle');
  String get confirm => translate('confirm');
  String get resendCode => translate('resendCode');
  String get setNewPasswordSubtitle => translate('setNewPasswordSubtitle');
  String get updatePassword => translate('updatePassword');
  String get goodMorning => translate('goodMorning');
  String get goodAfternoon => translate('goodAfternoon');
  String get goodEvening => translate('goodEvening');
  String get goodNight => translate('goodNight');
  String get user => translate('user');
  String get noExpensesToday => translate('noExpensesToday');
  String get errorOccurred => translate('errorOccurred');
  String get noExpensesYet => translate('noExpensesYet');
  String get addFirstExpense => translate('addFirstExpense');
  String get addTodayFirstExpense => translate('addTodayFirstExpense');
  String get som => translate('som');
  String get dateRange => translate('dateRange');
  String get startDateLabel => translate('startDateLabel');
  String get endDateLabel => translate('endDateLabel');
  String get fileFormat => translate('fileFormat');
  String get pdfDesc => translate('pdfDesc');
  String get excelDesc => translate('excelDesc');
  String get csvDesc => translate('csvDesc');
  String get exportBtn => translate('exportBtn');
  String get errorPickingImage => translate('errorPickingImage');
  String get changePhoto => translate('changePhoto');
  String get newCategory => translate('newCategory');
  String get editCategory => translate('editCategory');
  String get categoryName => translate('categoryName');
  String get selectIcon => translate('selectIcon');
  String get food => translate('food');
  String get transport => translate('transport');
  String get shopping => translate('shopping');
  String get payments => translate('payments');
  String get health => translate('health');
  String get other => translate('other');
  String get systemNotifications => translate('systemNotifications');
  String get dailyReminderTitle => translate('dailyReminderTitle');
  String get weeklyReportTitle => translate('weeklyReportTitle');
  String get weeklyReportDesc => translate('weeklyReportDesc');
  String get budgetAlertTitle => translate('budgetAlertTitle');
  String get newFeaturesTitle => translate('newFeaturesTitle');
  String get newFeaturesDesc => translate('newFeaturesDesc');
  String get thresholdQuestion => translate('thresholdQuestion');
  String get notificationTitle => translate('notificationTitle');
  String get notificationBody => translate('notificationBody');
  String get monthlyBudget => translate('monthlyBudget');
  String get budgetEditDesc => translate('budgetEditDesc');
  String get totalIncome => translate('totalIncome');
  String get totalExpense => translate('totalExpense');
  String get balance => translate('balance');
  String get topCategories => translate('topCategories');
  String get downloadReport => translate('downloadReport');
  String get exampleLunch => translate('exampleLunch');
  String get exampleSalary => translate('exampleSalary');
  String get exampleName => translate('exampleName');
  String get addDescription => translate('addDescription');
  String get invalidInput => translate('invalidInput');
  String get loading => translate('loading');
  String get incomeAdded => translate('incomeAdded');
  String get expenseAdded => translate('expenseAdded');
  String get securityCode => translate('securityCode');
  String get appTagline => translate('appTagline');
  String get failedToLoadData => translate('failedToLoadData');
  String get setMonthlyLimit => translate('setMonthlyLimit');
  String get categoriesTitle => translate('categoriesTitle');
  String get contactUs => translate('contactUs');
  String get contactTelegram => translate('contactTelegram');
  String get contactEmail => translate('contactEmail');
  String get selectLanguage => translate('selectLanguage');
  String get securityDesc => translate('securityDesc');
  String get securitySystem => translate('securitySystem');
  String get pinRequiredDesc => translate('pinRequiredDesc');
  String get salary => translate('salary');
  String get freelance => translate('freelance');
  String get investment => translate('investment');
  String get gift => translate('gift');
  String get faqTitle => translate('faqTitle');
  String get faq1Question => translate('faq1Question');
  String get faq1Answer => translate('faq1Answer');
  String get faq2Question => translate('faq2Question');
  String get faq2Answer => translate('faq2Answer');
  String get faq3Question => translate('faq3Question');
  String get faq3Answer => translate('faq3Answer');

  // Parameterized methods
  String comparisonSummary(String percent, String moreOrLess) {
    return translate('comparisonSummary')
        .replaceAll('{percent}', percent)
        .replaceAll('{moreOrLess}', moreOrLess);
  }

  String todayOperationsCount(int count) {
    return translate('todayOperationsCount').replaceAll('{count}', count.toString());
  }

  String dailyReminderDesc(String time) {
    return translate('dailyReminderDesc').replaceAll('{time}', time);
  }

  String budgetAlertDesc(int threshold) {
    return translate('budgetAlertDesc').replaceAll('{threshold}', threshold.toString());
  }

  String spentOfBudget(String percent) {
    return translate('spentOfBudget').replaceAll('{percent}', percent);
  }

  String incomeAddedBody(String amount, String name) {
    return translate('incomeAddedBody')
        .replaceAll('{amount}', amount)
        .replaceAll('{name}', name);
  }

  String categoryBudgetAllocated(String title) {
    return translate('categoryBudgetAllocated').replaceAll('{title}', title);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'uz', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
