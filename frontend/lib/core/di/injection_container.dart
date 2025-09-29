import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/environment.dart';
// Features - Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
// Features - Dashboard
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/create_transaction_usecase.dart';
import '../../features/dashboard/domain/usecases/get_balance_usecase.dart';
import '../../features/dashboard/domain/usecases/get_categories_usecase.dart';
import '../../features/dashboard/domain/usecases/get_recent_transactions_usecase.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
// Features - Settings
import '../../features/settings/presentation/bloc/settings_bloc.dart';
// Features - Transactions
import '../../features/transactions/presentation/bloc/transactions_bloc.dart';
import '../connectivity/connectivity_bloc.dart';
import '../network/dio_client.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage.dart';
import '../storage/secure_storage_service.dart';
import '../utils/connectivity_helper.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Core services
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(getIt<FlutterSecureStorage>()),
  );

  // Network
  final dio = Dio(BaseOptions(
    baseUrl: AppEnvironment.apiBaseUrl,
    connectTimeout: AppEnvironment.apiTimeout,
    receiveTimeout: AppEnvironment.apiTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  if (AppEnvironment.enableLogging) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  getIt.registerSingleton<Dio>(dio);

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<Dio>(), getIt<SecureStorageService>()),
  );

  // Core utilities
  getIt.registerLazySingleton<ConnectivityHelper>(
    () => ConnectivityHelper(),
  );

  // Features
  _initAuth();
  _initDashboard();
  _initSettings();
  _initTransactions();
  _initConnectivity();
}

void _initAuth() {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));

  // BLoC
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      secureStorage: SecureStorage(),
    ),
  );
}

void _initDashboard() {
  // Data sources
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: getIt<DashboardRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetBalanceUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetRecentTransactionsUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => CreateTransactionUseCase(getIt<DashboardRepository>()));
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt<DashboardRepository>()));

  // BLoC
  getIt.registerFactory(
    () => DashboardBloc(
      getBalanceUseCase: getIt<GetBalanceUseCase>(),
      getRecentTransactionsUseCase: getIt<GetRecentTransactionsUseCase>(),
      createTransactionUseCase: getIt<CreateTransactionUseCase>(),
      getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
    ),
  );
}

void _initSettings() {
  // BLoC
  getIt.registerLazySingleton(
    () => SettingsBloc(getIt<SharedPreferences>()),
  );
}

void _initTransactions() {
  // BLoC
  getIt.registerFactory(
    () => TransactionsBloc(),
  );
}

void _initConnectivity() {
  // BLoC
  getIt.registerLazySingleton(
    () => ConnectivityBloc(
      connectivityHelper: getIt<ConnectivityHelper>(),
    ),
  );
}
