// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'home.dart';

// class SignInScreen extends StatefulWidget {
//   @override
//   _SignInScreenState createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final LocalAuthentication _localAuth = LocalAuthentication();
//   bool _isAuthenticated = false;

//   @override
//   void initState() {
//     super.initState();
//     _authenticateWithBiometrics();
//   }

//   Future<void> _authenticateWithBiometrics() async {
//     bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
//     if (canCheckBiometrics) {
//       try {
//         bool didAuthenticate = await _localAuth.authenticate(
//           localizedReason: 'Please authenticate to sign in',
//         );
//         if (didAuthenticate) {
//           setState(() {
//             _isAuthenticated = true;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Successfully logged in')),
//           );
//           _navigateToHomeScreen();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Wrong fingerprint')),
//           );
//         }
//       } catch (e) {
//         print(e);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Authentication error: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Biometrics not available on this device')),
//       );
//     }
//   }

//   void _navigateToHomeScreen() {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => HomeScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     );
//   }
// }
