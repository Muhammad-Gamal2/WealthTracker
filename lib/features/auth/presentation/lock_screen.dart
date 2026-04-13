import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:wealth_tracker/features/auth/presentation/auth_signals.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_signals.dart';
import 'package:wealth_tracker/routing/app_router.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _tryingBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricIfAvailable();
    });
  }

  bool get _biometricEnabled =>
      !kIsWeb &&
      biometricAvailableSignal.value &&
      useBiometricSignal.value;

  Future<void> _tryBiometricIfAvailable() async {
    if (!_biometricEnabled) return;
    setState(() => _tryingBiometric = true);
    final success = await unlockWithBiometric();
    if (!mounted) return;
    setState(() => _tryingBiometric = false);
    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tryingBiometric
          ? const Center(child: CircularProgressIndicator())
          : ScreenLock.create(
              onValidate: (input) => unlockWithPin(input),
              onUnlocked: () {
                Navigator.pushReplacementNamed(context, AppRouter.dashboard);
              },
              footer: _biometricEnabled
                  ? TextButton.icon(
                      onPressed: () async {
                        final success = await unlockWithBiometric();
                        if (success && context.mounted) {
                          Navigator.pushReplacementNamed(
                              context, AppRouter.dashboard);
                        }
                      },
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Use Biometrics'),
                    )
                  : null,
              config: ScreenLockConfig(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'WealthTracker',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your PIN',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}
