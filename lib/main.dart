import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/features/expense/application/auth_cubit.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/income/application/income/income_bloc.dart';
import 'package:pockettrack/features/auth/presentation/pages/splash_page.dart';
import 'package:pockettrack/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dependency Injection-ni ishga tushiramiz (Firebase, Hive va h.k.)
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthCubit>()..checkAuth()),
        BlocProvider(create: (context) => di.sl<ExpenseBloc>()),
        BlocProvider(create: (context) => di.sl<IncomeBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF0D9488),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
          fontFamily: 'Geist',
        ),
        // Endi ilova har doim SplashPage dan boshlanadi
        home: const SplashPage(),
      ),
    );
  }
}
