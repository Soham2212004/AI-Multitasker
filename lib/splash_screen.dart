import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _navigateToHomeScreen();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User';
    });
  }

  void _navigateToHomeScreen() {
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Add a SizedBox to push the image down
          SizedBox(height: 200), // Adjust this value to move the image lower or higher
          Center(
            child: Image.asset(
              'assets/Designer.png', // Ensure this image is in your assets folder
              height: 200, // Adjust size as needed
              width: 200, // Adjust size as needed
            ),
          ),
          Spacer(), // Pushes the text to the bottom
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Powered by Gemini AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
