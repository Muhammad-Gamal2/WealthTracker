import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/widgets/app_shell.dart';
import 'package:wealth_tracker/features/auth/presentation/lock_screen.dart';
import 'package:wealth_tracker/features/gold/presentation/gold_screen.dart';
import 'package:wealth_tracker/features/liquidity/presentation/liquidity_screen.dart';
import 'package:wealth_tracker/features/real_estate/presentation/real_estate_screen.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_screen.dart';
import 'package:wealth_tracker/features/stocks/presentation/stocks_screen.dart';

class AppRouter {
  AppRouter._();

  static const String lock = '/lock';
  static const String dashboard = '/';
  static const String gold = '/gold';
  static const String stocks = '/stocks';
  static const String liquidity = '/liquidity';
  static const String realEstate = '/real-estate';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        lock: (_) => const LockScreen(),
        dashboard: (_) => const AppShell(),
        gold: (_) => const GoldScreen(),
        stocks: (_) => const StocksScreen(),
        liquidity: (_) => const LiquidityScreen(),
        realEstate: (_) => const RealEstateScreen(),
        settings: (_) => const SettingsScreen(),
      };
}
