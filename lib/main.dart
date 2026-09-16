import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pockettrack/core/network/auth_interceptor.dart';
import 'package:pockettrack/features/auth/presentation/pages/home_page.dart';
import 'package:pockettrack/features/auth/presentation/pages/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pockettrack/features/expense/application/auth_cubit.dart';
import 'package:pockettrack/features/expense/application/auth_state.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/auth_local_data_source.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/auth_remote_data_source.dart';
import 'package:pockettrack/features/expense/domain/repositories/auth_repository_impl.dart';
import 'package:pockettrack/features/expense/domain/repositories/expense_repository_impl.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/expense_local_data_source.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/auth/presentation/pages/splash_page.dart';
import 'package:pockettrack/features/auth/presentation/pages/pin_entry_page.dart';
import 'package:pockettrack/features/auth/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/features/expense/infrastructure/models/expense_model.dart';
import 'package:pockettrack/features/expense/infrastructure/models/user_model.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/user_local_data_source.dart';
import 'package:pockettrack/core/services/notification_service.dart';
import 'package:pockettrack/features/income/application/income/income_bloc.dart';
import 'package:pockettrack/features/income/domain/repositories/income_repository_impl.dart';
import 'package:pockettrack/features/income/infrastructure/datasources/income_local_data_source.dart';
import 'package:pockettrack/features/income/infrastructure/models/income_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseModelImplAdapter());
  Hive.registerAdapter(UserModelImplAdapter());
  Hive.registerAdapter(IncomeModelImplAdapter());

  final dio = Dio();
  const secureStorage = FlutterSecureStorage();

  final localDataSource = AuthLocalDataSource(secureStorage);
  final remoteDataSource = AuthRemoteDataSource(dio);
  final userLocalDataSource = UserLocalDataSource();
  await userLocalDataSource.init();

  dio.interceptors.add(AuthInterceptor(localDataSource, dio));

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    userLocalDataSource: userLocalDataSource,
  );

  final expenseLocalDataSource = ExpenseLocalDataSource();
  await expenseLocalDataSource.init();
  final expenseRepository = ExpenseRepositoryImpl(expenseLocalDataSource);

  final incomeLocalDataSource = IncomeLocalDataSource();
  await incomeLocalDataSource.init();
  final incomeRepository = IncomeRepositoryImpl(incomeLocalDataSource);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository)..checkAuth(),
        ),
        BlocProvider(create: (context) => ExpenseBloc(expenseRepository)),
        BlocProvider(create: (context) => IncomeBloc(incomeRepository)),
      ],
      child: const MyApp(),
    ),
  );
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0D9488),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
        ),
        fontFamily: 'Geist',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black, size: 20),
        ),
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
                    return const SplashPage();
                  }
                  final String? pin = snapshot.data;
                  if (pin != null && pin.isNotEmpty) {
                    return PinEntryPage(onVerified: () {
                      setState(() {
                        _isPinVerified = true;
                      });
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
                  return const SplashPage();
                }
                final bool isCompleted = snapshot.data?.getBool('is_onboarding_completed') ?? false;
                if (isCompleted) {
                  return const LoginPage();
                }
                return const OnboardingPage();
              },
            ),
            loading: () => const SplashPage(),
            initial: () => const SplashPage(),
            orElse: () => const LoginPage(),
          );
        },
      ),
    );
  }
}
