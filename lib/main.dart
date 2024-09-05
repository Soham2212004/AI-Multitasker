import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home/splash_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: AIMultitaskerApp(),
    ),
  );
}
class AIMultitaskerApp extends StatefulWidget {
  @override
  _AIMultitaskerAppState createState() => _AIMultitaskerAppState();

  static _AIMultitaskerAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AIMultitaskerAppState>();
  }
}

class _AIMultitaskerAppState extends State<AIMultitaskerApp> {
  ThemeData _themeData = ThemeData.light();

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeData = isDarkMode ? ThemeData.dark() : ThemeData.light();
    });
  }

  void setThemeData(ThemeData themeData) {
    setState(() {
      _themeData = themeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = _themeData.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Background GIF for dark mode
          if (isDarkMode)
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1550353127-b0da3aeaa0ca?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGJsYWNrJTIwYW5kJTIwYmx1ZSUyMGJhY2tncm91bmR8ZW58MHx8MHx8fDA%3D',
                fit: BoxFit.cover,
              ),
            ),
          // The main app content
          MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'AI Multitasker App',
            theme: _themeData.copyWith(
              scaffoldBackgroundColor: isDarkMode ? Colors.transparent : Colors.white,
              appBarTheme: AppBarTheme(
                color: Colors.transparent, // Transparent background for the AppBar
                elevation: 0, // Removes the shadow under the AppBar
                iconTheme: IconThemeData(
                  color: isDarkMode ? Colors.white : Colors.black, // Adjust icon color based on theme
                ),
                titleTextStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Adjust title color based on theme
                  fontSize: 20,
                ),
              ),
            ),
            home: SplashScreen(),
          ),
        ],
      ),
    );
  }
}
