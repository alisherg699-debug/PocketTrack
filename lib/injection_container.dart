import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pockettrack/core/network/auth_interceptor.dart';
import 'package:pockettrack/core/services/notification_service.dart';
import 'package:pockettrack/features/expense/application/auth_cubit.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/domain/repositories/auth_repository.dart';
import 'package:pockettrack/features/expense/domain/repositories/auth_repository_impl.dart';
import 'package:pockettrack/features/expense/domain/repositories/expense_repository.dart';
import 'package:pockettrack/features/expense/domain/repositories/expense_repository_impl.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/auth_local_data_source.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/expense_local_data_source.dart';
import 'package:pockettrack/features/expense/infrastructure/models/expense_model.dart';
import 'package:pockettrack/features/expense/infrastructure/models/user_model.dart';
import 'package:pockettrack/features/income/application/income/income_bloc.dart';
import 'package:pockettrack/features/income/domain/repositories/income_repository.dart';
import 'package:pockettrack/features/income/domain/repositories/income_repository_impl.dart';
import 'package:pockettrack/features/income/infrastructure/datasources/income_local_data_source.dart';
import 'package:pockettrack/features/income/infrastructure/models/income_model.dart';
import 'firebase_options.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Firebase & Services
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  
  // 2. Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ExpenseModelImplAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserModelImplAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(IncomeModelImplAdapter());

  // 3. Data Sources
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => AuthLocalDataSource(secureStorage));
  
  final expenseDS = ExpenseLocalDataSource();
  await expenseDS.init();
  sl.registerLazySingleton(() => expenseDS);

  final incomeDS = IncomeLocalDataSource();
  await incomeDS.init();
  sl.registerLazySingleton(() => incomeDS);

  // 4. Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(sl()));
  sl.registerLazySingleton<IncomeRepository>(() => IncomeRepositoryImpl(sl()));

  // 5. Blocs
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => ExpenseBloc(sl()));
  sl.registerFactory(() => IncomeBloc(sl()));

  // 6. Network
  final dio = Dio();
  dio.interceptors.add(AuthInterceptor(sl(), dio));
  sl.registerLazySingleton(() => dio);
}
