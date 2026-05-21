import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/widgets/sprout_logo.dart';
import 'package:wealth_tracker/core/widgets/trefoil_divider.dart';
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
      !kIsWeb && biometricAvailableSignal.value && useBiometricSignal.value;

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
      body: Stack(
        children: [
          // Saffron ambient glow at the bottom
          Positioned(
            bottom: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.2,
                  colors: [
                    ObsidianTheme.accent.withValues(alpha: 0.10),
                    ObsidianTheme.accent.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Main content
          _tryingBiometric
              ? const Center(child: CircularProgressIndicator())
              : ScreenLock(
                  correctString: '0000',
                  onValidate: (input) => unlockWithPin(input),
                  onUnlocked: () {
                    Navigator.pushReplacementNamed(
                        context, AppRouter.dashboard);
                  },
                  footer: _biometricEnabled
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextButton.icon(
                            onPressed: () async {
                              final success = await unlockWithBiometric();
                              if (success && context.mounted) {
                                Navigator.pushReplacementNamed(
                                    context, AppRouter.dashboard);
                              }
                            },
                            icon: Icon(Icons.fingerprint,
                                color: ObsidianTheme.accent),
                            label: Text(
                              'استخدم البصمة',
                              style: GoogleFonts.reemKufi(
                                fontSize: 14,
                                color: ObsidianTheme.text2,
                              ),
                            ),
                          ),
                        )
                      : null,
                  config: ScreenLockConfig(
                    backgroundColor: ObsidianTheme.bg,
                  ),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SproutLogo(
                        size: 56,
                        color: ObsidianTheme.accent,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'ثَريّ',
                        style: GoogleFonts.amiri(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: ObsidianTheme.cream,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TrefoilDivider(
                        width: 120,
                        color: ObsidianTheme.accent,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'أدخل رمز الدخول',
                        style: GoogleFonts.reemKufi(
                          fontSize: 14,
                          color: ObsidianTheme.text2,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
