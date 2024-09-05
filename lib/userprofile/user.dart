import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_profile.dart';

class UserPage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  UserPage({this.onProfileUpdated});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _firstName = 'First Name';
  String _lastName = 'Last Name';
  String _gender = 'Gender';
  String _email = 'Email';
  String _phoneNumber = 'Phone Number';
  String _profession = 'Profession';
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
      _firstName = prefs.getString('firstName') ?? 'First Name';
      _lastName = prefs.getString('lastName') ?? 'Last Name';
      _gender = prefs.getString('gender') ?? 'Gender';
      _email = prefs.getString('email') ?? 'Email';
      _phoneNumber = prefs.getString('phoneNumber') ?? 'Phone Number';
      _profession = prefs.getString('profession') ?? 'Profession';
      _imageFile = imageFile;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstName);
    await prefs.setString('lastName', _lastName);
    await prefs.setString('gender', _gender);
    await prefs.setString('email', _email);
    await prefs.setString('phoneNumber', _phoneNumber);
    await prefs.setString('profession', _profession);
    if (_imageFile != null) {
      await prefs.setString('profileImagePath',
          _imageFile!.path); // Save the path of the image file
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 25
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display image at the top center
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : AssetImage('assets/profile_placeholder.jpeg')
                      as ImageProvider,
            ),
            SizedBox(height: 20),
            // User information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: $_firstName $_lastName',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Gender: $_gender'),
                  SizedBox(height: 10),
                  Text('Email: $_email'),
                  SizedBox(height: 10),
                  Text('Phone: $_phoneNumber'),
                  SizedBox(height: 10),
                  Text('Profession: $_profession'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Button to update profile
            ElevatedButton(
              onPressed: () async {
                final updatedProfile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfileScreen(
                      firstName: _firstName,
                      lastName: _lastName,
                      gender: _gender,
                      email: _email,
                      phoneNumber: _phoneNumber,
                      profession: _profession,
                      imageFile: _imageFile,
                    ),
                  ),
                );

                if (updatedProfile != null) {
                  setState(() {
                    _firstName = updatedProfile['firstName'];
                    _lastName = updatedProfile['lastName'];
                    _gender = updatedProfile['gender'];
                    _email = updatedProfile['email'];
                    _phoneNumber = updatedProfile['phoneNumber'];
                    _profession = updatedProfile['profession'];
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
