import 'package:flutter/material.dart';
import 'pages/log_in.dart';
import 'pages/sign_up.dart';
import 'data/user_list.dart';
import 'pages/sleep.dart';
import 'pages/connected.dart';

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
      home: const Sleep(), // Set LogIn as the initial route
      routes: {
        '/login': (context) => const LogIn(),
        '/signup': (context) => const SignUp(),
        '/userList': (context) => const UserList(),
        '/sleep': (context) => const Sleep(),
        '/connected' : (context) => const Connected(),
      },
    );
  }
}
