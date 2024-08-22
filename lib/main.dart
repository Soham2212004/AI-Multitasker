import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; 
import 'settings.dart';
import 'user.dart';
import 'home_page.dart';
import 'splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(AIMultitaskerApp());
}

class AIMultitaskerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Multitasker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial route
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  String? _profileImagePath;
  Color _bgColor = Colors.blue; // Default background color
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [
    HomePage(),
    UserPage(onProfileUpdated: () {}),
    SettingsPage(),
  ];

  final List<Widget> _navigationItems = [
    Icon(Icons.home, size: 30, color: Colors.black),
    Icon(Icons.account_circle_outlined, size: 30, color: Colors.black),
    Icon(Icons.settings, size: 30, color: Colors.black),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _updateAppUsage(); // Load the profile image when the screen initializes
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _updateAppUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Update the time spent on the previous app
    String? previousApp = prefs.getString('currentApp');
    if (previousApp != null) {
      int? previousTime = prefs.getInt('$previousApp-time');
      if (previousTime != null) {
        int timeSpent = currentTime - previousTime;
        int totalTime = prefs.getInt('$previousApp-totalTime') ?? 0;
        await prefs.setInt('$previousApp-totalTime', totalTime + timeSpent);
      }
    }

    // Set the current app and time
    await prefs.setString('currentApp', 'HomePage'); // Replace 'HomePage' with the current page name
    await prefs.setInt('HomePage-time', currentTime);
  }

  void _onNavigationTap(int index) {
    setState(() {
      _page = index;
      switch (index) {
        case 0:
          _bgColor = Colors.blue;
          break;
        case 1:
          _bgColor = Colors.yellow;
          break;
        case 2:
          _bgColor = Colors.red;
          break;
      }
      _updateAppUsage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _bgColor,
        child: _pages.isNotEmpty ? _pages[_page] : Center(child: CircularProgressIndicator()), // Add loading indicator for the first build
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Colors.transparent, // Make background color transparent
        items: _navigationItems,
        index: _page,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onNavigationTap,
      ),
    );
  }
}
