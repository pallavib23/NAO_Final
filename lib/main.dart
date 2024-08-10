import 'package:flutter/material.dart';
import 'pages/log_in.dart';
import 'pages/sign_up.dart';
import 'pages/sleep.dart';
import 'pages/settings.dart';
import 'pages/edit_profile.dart';
import '/pages/connected.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LogIn(), // Default home page
      routes: {
        '/login': (context) => const LogIn(),
        '/signup': (context) => const SignUp(),
        '/sleep': (context) => const Sleep(),
        '/settings': (context) => const Settings(),
        '/edit_profile': (context) => const EditProfile(),
        '/connected' : (context) => const Connected(),
      },
    );
  }
}
