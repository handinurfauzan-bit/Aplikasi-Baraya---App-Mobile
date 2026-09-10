import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/app_settings.dart';
import 'services/data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final dataService = DataService();
  await dataService.init();
  final settings = AppSettings();
  await settings.init();
  runApp(KumpulApp(dataService: dataService, settings: settings));
}

class KumpulApp extends StatelessWidget {
  final DataService dataService;
  final AppSettings settings;

  const KumpulApp({super.key, required this.dataService, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DataService>.value(value: dataService),
        ChangeNotifierProvider<AppSettings>.value(value: settings),
      ],
      child: Consumer<AppSettings>(
        builder: (context, appSettings, _) {
          return MaterialApp(
            title: 'Kumpul.in',
            debugShowCheckedModeBanner: false,
            themeMode: appSettings.themeMode,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4F46E5), // Indigo Accent
        brightness: brightness,
        primary: const Color(0xFF4338CA),
        secondary: const Color(0xFF0D9488), // Teal Accent
        surface: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F1115) : const Color(0xFFF1F5F9),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}