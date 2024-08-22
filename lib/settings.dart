import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'about.dart';
import 'developer.dart';
import 'feedback.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.home, color: Colors.blue),
            title: Text('Home', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text('About', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.developer_mode, color: Colors.blue),
            title: Text('Developer', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DeveloperScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: Colors.blue),
            title: Text('Feedback', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.data_usage_outlined, color: Colors.blue),
            title: Text('Usage', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

