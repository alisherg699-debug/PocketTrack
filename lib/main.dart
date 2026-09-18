import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Features
import 'package:pockettrack/features/auth/application/auth_cubit.dart';
import 'package:pockettrack/features/auth/application/auth_state.dart';
import 'package:pockettrack/features/auth/presentation/pages/login_page.dart';
import 'package:pockettrack/features/auth/presentation/pages/onboarding_page.dart';
import 'package:pockettrack/features/auth/presentation/pages/pin_entry_page.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/presentation/pages/home_page.dart';
import 'package:pockettrack/features/income/application/income/income_bloc.dart';
import 'package:pockettrack/features/settings/application/settings_cubit.dart';

import 'package:pockettrack/injection_container.dart' as di;
import 'package:pockettrack/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Barcha servislarni ishga tushirish (Firebase, Hive va h.k.)
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isPinVerified = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthCubit>()..checkAuth()),
        BlocProvider(create: (context) => di.sl<ExpenseBloc>()),
        BlocProvider(create: (context) => di.sl<IncomeBloc>()),
        BlocProvider(create: (context) => di.sl<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: settingsState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              useMaterial3: true,
              primaryColor: const Color(0xFF0D9488),
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
              fontFamily: 'Geist',
            ),
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return state.maybeWhen(
                  authenticated: (user) {
                    if (_isPinVerified) return const HomePage();

                    return FutureBuilder<String?>(
                      future: const FlutterSecureStorage().read(key: 'user_pin'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(color: const Color(0xFF0D9488));
                        }
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                          return PinEntryPage(onVerified: () {
                            setState(() => _isPinVerified = true);
                          });
                        }
                        return const HomePage();
                      },
                    );
                  },
                  unauthenticated: () => FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(color: const Color(0xFF0D9488));
                      }
                      final bool isCompleted = snapshot.data?.getBool('is_onboarding_completed') ?? false;
                      return isCompleted ? const LoginPage() : const OnboardingPage();
                    },
                  ),
                  orElse: () => Container(color: const Color(0xFF0D9488)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
