import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_profile.dart';



class UserPage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  UserPage({this.onProfileUpdated});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _name = 'Name';
  String _gender = 'Gender';
  String _email = 'Mail';
  String _phoneNumber = 'Mobile Number';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load the user data when the screen initializes
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImagePath');

    File? imageFile;
    if (imagePath != null) {
      imageFile = File(imagePath);
    }

    setState(() {
      _name = prefs.getString('name') ?? 'Name';
      _gender = prefs.getString('gender') ?? 'Gender';
      _email = prefs.getString('email') ?? 'Mail';
      _phoneNumber = prefs.getString('phoneNumber') ?? 'Mobile Number';
      _imageFile = imageFile;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('gender', _gender);
    await prefs.setString('email', _email);
    await prefs.setString('phoneNumber', _phoneNumber);
    if (_imageFile != null) {
      await prefs.setString('profileImagePath', _imageFile!.path); // Save the path of the image file
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : AssetImage('assets/profile_placeholder.jpeg') as ImageProvider,
            ),
            SizedBox(height: 20),
            Text('Name: $_name'),
            Text('Gender: $_gender'),
            Text('Email: $_email'),
            Text('Phone: $_phoneNumber'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedProfile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfileScreen(
                      name: _name,
                      gender: _gender,
                      email: _email,
                      phoneNumber: _phoneNumber,
                      imageFile: _imageFile,
                    ),
                  ),
                );

                if (updatedProfile != null) {
                  setState(() {
                    _name = updatedProfile['name'];
                    _gender = updatedProfile['gender'];
                    _email = updatedProfile['email'];
                    _phoneNumber = updatedProfile['phoneNumber'];
                    _imageFile = updatedProfile['imageFile'];
                  });

                  await _saveUserData(); // Save updated data

                  // Notify the HomeScreen to refresh its profile image
                  if (widget.onProfileUpdated != null) {
                    widget.onProfileUpdated!();
                  }
                }
              },
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}