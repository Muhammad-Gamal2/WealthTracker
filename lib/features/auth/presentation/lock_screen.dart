import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/features/auth/presentation/auth_signals.dart';
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
    _tryBiometricIfAvailable();
  }

  Future<void> _tryBiometricIfAvailable() async {
    if (!kIsWeb &&
        biometricAvailableSignal.value &&
        useBiometricFromSettings()) {
      setState(() => _tryingBiometric = true);
      final success = await unlockWithBiometric();
      setState(() => _tryingBiometric = false);
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    }
  }

  bool useBiometricFromSettings() {
    // Read directly from signal set during init
    return biometricAvailableSignal.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tryingBiometric
          ? const Center(child: CircularProgressIndicator())
          : ScreenLock(
              correctString: '', // We handle validation ourselves
              onUnlockFailed: (context) {},
              onVerify: (context, input) async {
                final valid = await unlockWithPin(input);
                if (valid && context.mounted) {
                  Navigator.pushReplacementNamed(
                      context, AppRouter.dashboard);
                }
              },
              footer: !kIsWeb && biometricAvailableSignal.value
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
