import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/core/services/exchange_rate_service.dart';
import 'package:wealth_tracker/core/services/gold_api_service.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/services/stock_api_service.dart';
import 'package:wealth_tracker/features/auth/data/auth_repository_impl.dart';
import 'package:wealth_tracker/features/auth/domain/auth_repository.dart';
import 'package:wealth_tracker/features/dashboard/data/wealth_repository_impl.dart';
import 'package:wealth_tracker/features/dashboard/domain/wealth_repository.dart';
import 'package:wealth_tracker/features/gold/data/gold_repository_impl.dart';
import 'package:wealth_tracker/features/gold/domain/gold_repository.dart';
import 'package:wealth_tracker/features/liquidity/data/liquidity_repository_impl.dart';
import 'package:wealth_tracker/features/liquidity/domain/liquidity_repository.dart';
import 'package:wealth_tracker/features/real_estate/data/real_estate_repository_impl.dart';
import 'package:wealth_tracker/features/real_estate/domain/real_estate_repository.dart';
import 'package:wealth_tracker/features/settings/data/settings_repository_impl.dart';
import 'package:wealth_tracker/features/settings/domain/settings_repository.dart';
import 'package:wealth_tracker/features/stocks/data/stock_repository_impl.dart';
import 'package:wealth_tracker/features/stocks/domain/stock_repository.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Database ──
  final db = AppDatabase();
  sl.registerSingleton<AppDatabase>(db);

  // ── HTTP ──
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: false,
    responseHeader: false,
    responseBody: true,
    error: true,
    logPrint: (obj) => print('[DIO] $obj'),
  ));
  sl.registerSingleton<Dio>(dio);

  // ── Local Auth ──
  sl.registerSingleton<LocalAuthentication>(LocalAuthentication());

  // ── API Services ──
  sl.registerSingleton<GoldApiService>(GoldApiService(sl<Dio>()));
  sl.registerSingleton<StockApiService>(StockApiService(sl<Dio>()));
  sl.registerSingleton<ExchangeRateService>(ExchangeRateService(sl<Dio>()));

  // ── Repositories ──
  sl.registerSingleton<SettingsRepository>(
      SettingsRepositoryImpl(sl<AppDatabase>()));

  sl.registerSingleton<PriceUpdateService>(PriceUpdateService(
    db: sl<AppDatabase>(),
    goldApi: sl<GoldApiService>(),
    stockApi: sl<StockApiService>(),
    exchangeRateApi: sl<ExchangeRateService>(),
    settings: sl<SettingsRepository>(),
  ));

  sl.registerSingleton<GoldRepository>(GoldRepositoryImpl(sl<AppDatabase>()));
  sl.registerSingleton<StockRepository>(StockRepositoryImpl(sl<AppDatabase>()));
  sl.registerSingleton<LiquidityRepository>(
      LiquidityRepositoryImpl(sl<AppDatabase>()));
  sl.registerSingleton<RealEstateRepository>(
      RealEstateRepositoryImpl(sl<AppDatabase>()));

  sl.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(sl<SettingsRepository>(), sl<LocalAuthentication>()));

  sl.registerSingleton<WealthRepository>(WealthRepositoryImpl(
    sl<AppDatabase>(),
    sl<PriceUpdateService>(),
  ));
}
