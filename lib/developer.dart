import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';


class DeveloperScreen extends StatelessWidget {
  final String developerImage = 'assets/s.jpg';
  final String developerName = 'Soham Soni';

  final String githubUrl = 'https://github.com/Soham2212004';
  final String linkedinUrl =
      'https://www.linkedin.com/in/soham-soni-2342b4239/';
  final String credlyUrl = 'https://www.credly.com/users/soni-soham';
  final String instagramUrl = 'https://www.instagram.com/_soham_soni_';
  final String cloudUrl =
      'https://www.cloudskillsboost.google/public_profiles/6ebb4fad-af6b-4520-8d47-8a16a23a0df4';
  final String facebookUrl = 'https://www.facebook.com/soham.soni.5667/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Developer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80.0,
              backgroundImage: AssetImage(developerImage),
            ),
            SizedBox(height: 20.0),
            Text(
              developerName,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _launchURL(githubUrl),
                  child: Image.asset(
                    'assets/github.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/linkedin.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(linkedinUrl),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/credly.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(credlyUrl),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/instagram.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(instagramUrl),
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/cloud.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(cloudUrl),
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/facebook.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _launchURL(facebookUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}