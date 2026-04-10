import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/constants/app_constants.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_signals.dart';
import 'package:wealth_tracker/routing/app_router.dart';

class WealthTrackerApp extends StatelessWidget {
  const WealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isDark = isDarkModeSignal.value;
      return MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1565C0), // Deep blue seed
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF1565C0),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        initialRoute: AppRouter.lock,
        routes: AppRouter.routes,
      );
    });
  }
}
