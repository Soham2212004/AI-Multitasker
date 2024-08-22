import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'developer.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Info'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModelInfoItem(context, 'Name', 'Ai Multitasker App'),
          _buildModelInfoItem(context, 'Version', '1'),
          _buildModelInfoItem(context, 'Country', 'India'),
          _buildModelInfoItem(
              context, 'Application Type', 'Mobile Application'),
          _buildModelInfoItem(context, 'Release Date', 'August 2024'),
          _buildModelInfoItem(context, 'Features', 'Various Types Of Ai Tools'),
          _buildModelInfoItem(context, 'Technology', 'Flutter'),
          _buildModelInfoItem(context, 'Supported Platforms', 'Android'),
          _buildModelInfoItem(context, 'Language', 'Dart'),
          _buildModelInfoItem(context, 'Developer', 'SOHAM SONI'),
        ],
      ),
    );
  }

  Widget _buildModelInfoItem(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: value == 'SOHAM SONI'
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeveloperScreen(),
                      ),
                    );
                  }
                : null,
            child: Text(
              value,
              style: value == 'SOHAM SONI'
                  ? TextStyle(color: Colors.blue)
                  : TextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}