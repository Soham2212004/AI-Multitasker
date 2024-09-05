import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'sign_in_screen.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _navigateToSignInScreen();
  }

  Future<void> _loadUserName() async {
    // final prefs = await SharedPreferences.getInstance();
    setState(() {
      // _userName = prefs.getString('name') ?? 'User';
    });
  }

  void _navigateToSignInScreen() {
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
          SizedBox(height: 200),
          Center(
            child: Image.asset(
              'assets/Designer.png',
              height: 200,
              width: 200,
            ),
          ),
          SizedBox(height: 20), // Space between the image and the text
          Text(
            'AI Multitasker App',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
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
