import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_settings.dart';
import '../services/data_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final dataService = context.watch<DataService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, Icons.palette_outlined, 'Penampilan'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (mode) {
                if (mode != null) settings.setThemeMode(mode);
              },
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    activeColor: null,
                    secondary: Icon(Icons.light_mode_outlined),
                    title: Text('Mode Terang'),
                  ),
                  Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    secondary: Icon(Icons.dark_mode_outlined),
                    title: Text('Mode Gelap'),
                  ),
                  Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    secondary: Icon(Icons.brightness_auto_outlined),
                    title: Text('Mengikuti Sistem'),
                    subtitle: Text('Sesuaikan dengan tema perangkat'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, Icons.tune_outlined, 'Preferensi'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.movie_filter_outlined,
                      color: Colors.orange),
                  title: const Text('Mode Demo'),
                  subtitle: const Text('Gunakan data contoh lokal'),
                  trailing: Switch(
                    value: settings.demoMode,
                    onChanged: settings.setDemoMode,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.red),
                  title: const Text('Reset Data Demo'),
                  subtitle: const Text('Kembalikan data ke versi awal'),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Reset Data Demo?'),
                        content: const Text(
                          'Semua perubahan data akan dihapus dan dikembalikan ke data contoh awal.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, true),
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      dataService.resetToSeedData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data demo dikembalikan ke awal'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, Icons.info_outline, 'Tentang'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      'assets/logo1.1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  title: const Text('Baraya'),
                  subtitle: const Text('v1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Baraya v1.0.0'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Baraya v1.0.0 • 2026',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}