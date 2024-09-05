import 'package:ai_multitasker/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about.dart';
import 'developer.dart';
import 'feedback.dart';
import '../Home/home.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load the theme preference from shared preferences
  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save the theme preference to shared preferences
  void _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _isDarkMode ? Colors.blue : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 25
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.home, color: iconColor),
            title: Text('Home',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w900)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: iconColor),
            title: Text('About',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w900)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.developer_mode, color: iconColor),
            title: Text('Developer',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w900)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DeveloperScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: iconColor),
            title: Text('Feedback',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w900)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              );
            },
          ),
          SwitchListTile(
            title: Text('Dark Mode',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w900)),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                _saveThemePreference(_isDarkMode);
              });
              // Update the theme mode
              if (_isDarkMode) {
                AIMultitaskerApp.of(context)?.setThemeData(ThemeData.dark());
              } else {
                AIMultitaskerApp.of(context)?.setThemeData(ThemeData.light());
              }
            },
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
