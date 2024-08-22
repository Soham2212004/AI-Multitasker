import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; 
import 'settings.dart';
import 'user.dart';
import 'home_page.dart';
import 'splash_screen.dart';


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
      home: SplashScreen(),
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
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [];

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

    _pages.addAll([
      HomePage(),
      UserPage(
        onProfileUpdated: _loadProfileImage, // Reload the image when profile is updated
      ),
      SettingsPage(),
    ]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Colors.lightBlueAccent,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          _profileImagePath != null
              ? CircleAvatar(
                  radius: 15,
                  backgroundImage: FileImage(File(_profileImagePath!)),
                )
              : Icon(Icons.account_circle_outlined, size: 30),
          Icon(Icons.settings, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
            _updateAppUsage();
          });
        },
      ),
      body: _pages.isNotEmpty ? _pages[_page] : Center(child: CircularProgressIndicator()), // Add loading indicator for the first build
    );
  }
}


