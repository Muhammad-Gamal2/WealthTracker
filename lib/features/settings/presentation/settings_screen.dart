import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/features/auth/domain/auth_repository.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_signals.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _goldKeyController = TextEditingController();
  final _eodhdKeyController = TextEditingController();
  bool _showGoldKey = false;
  bool _showEodhdKey = false;

  @override
  void initState() {
    super.initState();
    _goldKeyController.text = goldApiKeySignal.value;
    _eodhdKeyController.text = eodhdApiKeySignal.value;
  }

  @override
  void dispose() {
    _goldKeyController.dispose();
    _eodhdKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsidianTheme.bg,
      body: SafeArea(
        child: Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 4, right: 20, top: 8, bottom: 8),
          decoration: const BoxDecoration(
            color: Color(0xB807090F),
            border: Border(
              bottom: BorderSide(color: ObsidianTheme.border),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: ObsidianTheme.text1, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Settings',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ObsidianTheme.text1,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Watch((context) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;

                Widget content = ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: 20,
                  ),
                  children: [
                    // ── API KEYS ──
                    _buildSectionHeader(
                      icon: Icons.key_rounded,
                      label: 'API KEYS',
                    ),
                    const SizedBox(height: 10),
                    _buildApiKeysCard(),
                    const SizedBox(height: 28),

                    // ── SECURITY ──
                    _buildSectionHeader(
                      icon: Icons.shield_rounded,
                      label: 'SECURITY',
                    ),
                    const SizedBox(height: 10),
                    _buildSecurityCard(context),
                    const SizedBox(height: 28),

                    // ── APPEARANCE ──
                    _buildSectionHeader(
                      icon: Icons.palette_rounded,
                      label: 'APPEARANCE',
                    ),
                    const SizedBox(height: 10),
                    _buildAppearanceCard(),
                    const SizedBox(height: 40),
                  ],
                );

                if (isDesktop) {
                  content = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: content,
                    ),
                  );
                }

                return content;
              },
            );
          }),
        ),
          ],
        ),
      ),
    );
  }

  // ─── Section header ────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ObsidianTheme.accent),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.accent,
            letterSpacing: 0.06 * 12,
          ),
        ),
      ],
    );
  }

  // ─── API Keys card ─────────────────────────────────────────────────

  Widget _buildApiKeysCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildApiKeyRow(
            label: 'GoldAPI.io Key',
            controller: _goldKeyController,
            showKey: _showGoldKey,
            onToggleShow: () => setState(() => _showGoldKey = !_showGoldKey),
            onSave: () {
              saveGoldApiKey(_goldKeyController.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('GoldAPI.io Key saved'),
                    duration: Duration(seconds: 2)),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(height: 1, color: ObsidianTheme.border),
          ),
          _buildApiKeyRow(
            label: 'EODHD API Key',
            controller: _eodhdKeyController,
            showKey: _showEodhdKey,
            onToggleShow: () =>
                setState(() => _showEodhdKey = !_showEodhdKey),
            onSave: () {
              saveEodhdApiKey(_eodhdKeyController.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('EODHD API Key saved'),
                    duration: Duration(seconds: 2)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyRow({
    required String label,
    required TextEditingController controller,
    required bool showKey,
    required VoidCallback onToggleShow,
    required VoidCallback onSave,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ObsidianTheme.text3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: !showKey,
                style: GoogleFonts.dmMono(
                    fontSize: 13, color: ObsidianTheme.text1),
                decoration: InputDecoration(
                  hintText: 'Paste your API key',
                  hintStyle: GoogleFonts.dmMono(
                      fontSize: 13, color: ObsidianTheme.text3),
                  filled: true,
                  fillColor: const Color(0x0DFFFFFF),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: ObsidianTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: ObsidianTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: ObsidianTheme.accent, width: 1.5),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildIconBtn(
              icon: showKey ? Icons.visibility_off : Icons.visibility,
              onTap: onToggleShow,
            ),
            const SizedBox(width: 4),
            _buildIconBtn(
              icon: Icons.save_rounded,
              onTap: onSave,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ObsidianTheme.border),
        ),
        child: Icon(icon, size: 18, color: ObsidianTheme.text2),
      ),
    );
  }

  // ─── Security card ─────────────────────────────────────────────────

  Widget _buildSecurityCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          // Set / Change PIN
          _buildSettingsRow(
            icon: Icons.pin_rounded,
            iconBgColor: const Color(0x0DFFFFFF),
            iconColor: ObsidianTheme.text2,
            title: hasPinConfiguredSignal.value ? 'Change PIN' : 'Set PIN',
            subtitle: 'Lock the app with a PIN code',
            trailing: const Icon(Icons.chevron_right,
                color: ObsidianTheme.text3, size: 22),
            onTap: () => _showSetPinFlow(context),
          ),
          // Biometric (hidden on web)
          if (!kIsWeb) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(height: 1, color: ObsidianTheme.border),
            ),
            _buildSettingsRow(
              icon: Icons.fingerprint,
              iconBgColor: const Color(0x0DFFFFFF),
              iconColor: ObsidianTheme.text2,
              title: 'Biometric Unlock',
              subtitle: 'Use fingerprint or Face ID',
              trailing: _buildToggle(
                value: useBiometricSignal.value,
                accent: ObsidianTheme.accent,
                onChange: (v) => toggleBiometric(v),
              ),
            ),
          ],
          // Remove PIN (only shown if PIN configured)
          if (hasPinConfiguredSignal.value) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(height: 1, color: ObsidianTheme.border),
            ),
            _buildSettingsRow(
              icon: Icons.lock_open_rounded,
              iconBgColor: const Color(0x1AF87171),
              iconColor: ObsidianTheme.lossRed,
              title: 'Remove PIN',
              subtitle: 'App will no longer be locked',
              titleColor: ObsidianTheme.lossRed,
              onTap: () => _confirmRemovePin(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ObsidianTheme.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? ObsidianTheme.text1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: ObsidianTheme.text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // ─── Appearance card ───────────────────────────────────────────────

  Widget _buildAppearanceCard() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _buildSettingsRow(
        icon: Icons.dark_mode_rounded,
        iconBgColor: const Color(0x0DFFFFFF),
        iconColor: ObsidianTheme.text2,
        title: 'Dark Mode',
        subtitle: 'Toggle dark theme',
        trailing: _buildToggle(
          value: isDarkModeSignal.value,
          accent: ObsidianTheme.accent,
          onChange: (v) => toggleDarkMode(v),
        ),
      ),
    );
  }

  // ─── Custom toggle switch ──────────────────────────────────────────

  Widget _buildToggle({
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChange,
  }) {
    return GestureDetector(
      onTap: () => onChange(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? accent : const Color(0x1FFFFFFF),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  // ─── PIN flows ─────────────────────────────────────────────────────

  void _showSetPinFlow(BuildContext context) {
    screenLockCreate(
      context: context,
      onConfirmed: (pin) async {
        await sl<AuthRepository>().setPin(pin);
        await loadSettings();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN set successfully')),
          );
        }
      },
    );
  }

  void _confirmRemovePin(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ObsidianTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianTheme.radius),
          side: const BorderSide(color: ObsidianTheme.border),
        ),
        title: Text(
          'Remove PIN',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.text1,
          ),
        ),
        content: Text(
          'Are you sure you want to remove your PIN? The app will no longer be locked.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: ObsidianTheme.text2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ObsidianTheme.text2,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await sl<AuthRepository>().clearPin();
              await loadSettings();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ObsidianTheme.lossRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
