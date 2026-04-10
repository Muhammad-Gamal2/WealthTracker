import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/features/auth/domain/auth_repository.dart';
import 'package:wealth_tracker/features/settings/presentation/settings_signals.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _goldKeyController = TextEditingController();
  final _twelveKeyController = TextEditingController();
  bool _showGoldKey = false;
  bool _showTwelveKey = false;

  @override
  void initState() {
    super.initState();
    _goldKeyController.text = goldApiKeySignal.value;
    _twelveKeyController.text = twelveDataApiKeySignal.value;
  }

  @override
  void dispose() {
    _goldKeyController.dispose();
    _twelveKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Watch((context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader(context, 'API Keys', Icons.key),
            _apiKeyTile(
              context,
              label: 'GoldAPI.io Key',
              hint: 'Get free key at goldapi.io',
              controller: _goldKeyController,
              showKey: _showGoldKey,
              onToggleShow: () =>
                  setState(() => _showGoldKey = !_showGoldKey),
              onSave: () => saveGoldApiKey(_goldKeyController.text.trim()),
            ),
            const SizedBox(height: 12),
            _apiKeyTile(
              context,
              label: 'Twelve Data API Key',
              hint: 'Get free key at twelvedata.com',
              controller: _twelveKeyController,
              showKey: _showTwelveKey,
              onToggleShow: () =>
                  setState(() => _showTwelveKey = !_showTwelveKey),
              onSave: () =>
                  saveTwelveDataApiKey(_twelveKeyController.text.trim()),
            ),
            const SizedBox(height: 24),
            _sectionHeader(context, 'Security', Icons.security),
            ListTile(
              leading: const Icon(Icons.pin),
              title: Text(hasPinConfiguredSignal.value
                  ? 'Change PIN'
                  : 'Set PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSetPinFlow(context),
            ),
            if (hasPinConfiguredSignal.value)
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: const Text('Remove PIN'),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () => _confirmRemovePin(context),
              ),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Unlock'),
              subtitle: const Text('Use fingerprint or Face ID'),
              value: useBiometricSignal.value,
              onChanged: (val) => toggleBiometric(val),
            ),
            const SizedBox(height: 24),
            _sectionHeader(context, 'Appearance', Icons.palette),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              value: isDarkModeSignal.value,
              onChanged: (val) => toggleDarkMode(val),
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }

  Widget _apiKeyTile(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool showKey,
    required VoidCallback onToggleShow,
    required VoidCallback onSave,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              obscureText: !showKey,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                          showKey ? Icons.visibility_off : Icons.visibility),
                      onPressed: onToggleShow,
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        onSave();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('$label saved'),
                              duration: const Duration(seconds: 2)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        title: const Text('Remove PIN'),
        content: const Text(
            'Are you sure you want to remove your PIN? The app will no longer be locked.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await sl<AuthRepository>().clearPin();
              await loadSettings();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Remove',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
