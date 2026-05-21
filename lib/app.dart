import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/features/auth/presentation/auth_signals.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_signals.dart';
import 'package:wealth_tracker/routing/app_router.dart';

class WealthTrackerApp extends StatelessWidget {
  const WealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isDark = isDarkModeSignal.value;
      return MaterialApp(
        title: 'ثَريّ',
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        darkTheme: ObsidianTheme.darkTheme(),
        theme: ObsidianTheme.lightTheme(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        initialRoute: hasPinSignal.value ? AppRouter.lock : AppRouter.dashboard,
        routes: AppRouter.routes,
      );
    });
  }
}
