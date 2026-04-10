import 'package:flutter/material.dart';
import 'package:wealth_tracker/app.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/features/auth/presentation/auth_signals.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_signals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up all dependencies (database, services, repositories)
  await setupDependencies();

  // Load settings & auth state before the app renders
  await Future.wait([
    loadSettings(),
    initAuthState(),
  ]);

  runApp(const WealthTrackerApp());
}
