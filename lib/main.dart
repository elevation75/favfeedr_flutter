// favfeedr_flutter/lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for theme preference
import 'package:favfeedr_flutter/services/subscription_service.dart';
import 'package:favfeedr_flutter/services/rss_service.dart';
import 'package:favfeedr_flutter/services/settings_service.dart'; // New import
import 'package:favfeedr_flutter/ui/home_screen.dart'; // Import HomeScreen

final SettingsService _settingsService = SettingsService(); // New instance

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const FavFeedrApp());
  } catch (e) {
    print('Error in main: $e');
    // In a real app, you might want to show a crash report dialog
    // or send the error to a reporting service.
  }
}

class FavFeedrApp extends StatefulWidget {
  const FavFeedrApp({super.key});

  @override
  State<FavFeedrApp> createState() => _FavFeedrAppState();
}

class _FavFeedrAppState extends State<FavFeedrApp> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final RssService _rssService = RssService(_settingsService); // Pass _settingsService
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? theme = prefs.getString('themeMode');
    if (theme == 'light') {
      setState(() {
        _themeMode = ThemeMode.light;
      });
    } else {
      setState(() {
        _themeMode = ThemeMode.dark;
      });
    }
  }

  void toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    _saveThemeMode(_themeMode);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode == ThemeMode.light ? 'light' : 'dark');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FavFeedr',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode, // Apply the theme mode
      theme: _lightThemeData, // Light theme
      darkTheme: _darkThemeData, // Dark theme
      home: HomeScreen( // Use HomeScreen as the home widget
        subscriptionService: _subscriptionService,
        rssService: _rssService,
        toggleThemeMode: toggleThemeMode, // Pass the toggleThemeMode function
        themeMode: _themeMode,
        settingsService: _settingsService, // Pass _settingsService
      ),
    );
  }

  // Dark Theme Definition
  ThemeData get _darkThemeData => ThemeData(
        fontFamily: 'Roboto', // Set the default font family
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF5252), // A slightly softer red
        hintColor: const Color(0xFFFF5252), // A slightly softer red
        scaffoldBackgroundColor: const Color(0xFF212121), // Darker grey background
        cardColor: const Color(0xFF282828), // Slightly darker card for contrast
        dividerColor: const Color(0xFF424242), // For separators

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5252),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFA000), // An accent color
          onSecondary: Colors.white,
          background: Color(0xFF212121),
          onBackground: Colors.white,
          surface: Color(0xFF282828),
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),

        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF282828), // AppBar matches card color
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF282828),
          contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          actionTextColor: const Color(0xFFFF5252),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5252),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white70,
            textStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );

  // Light Theme Definition
  ThemeData get _lightThemeData => ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        primaryColor: const Color(0xFFE53935), // A slightly deeper red for light mode
        hintColor: const Color(0xFFE53935),
        scaffoldBackgroundColor: Colors.white,
        cardColor: const Color(0xFFF5F5F5), // Light grey card
        dividerColor: Colors.grey.shade300,

        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE53935),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFC107), // A different accent for light mode
          onSecondary: Colors.black,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Color(0xFFF5F5F5),
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          brightness: Brightness.light,
        ),

        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey.shade800,
          contentTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          actionTextColor: const Color(0xFFE53935),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            textStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );
}