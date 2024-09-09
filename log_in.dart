import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/database_helper.dart';
import '../data/user_list.dart';  // Adjust the import to match the folder structure


class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool isChecked = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Focus nodes to manage focus between text fields
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Future<void> signIn(String username, String password) async {
    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUser(username);

      if (user != null) {
        // Ensure password is not null and matches the provided password
        if (user['password'] != null && user['password'] == password) {
          debugPrint('Login successful');
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/sleep');
          }
        } else {
          debugPrint('Invalid password');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid password'),
              ),
            );
          }
        }
      } else {
        debugPrint('User not found');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again. Error: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background_login.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            // Welcome back text
            Positioned(
              top: screenHeight * 0.1,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: Text(
                'Welcome back',
                style: GoogleFonts.alatsi(
                  fontSize: screenWidth * 0.1, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // White rounded container with gradient
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: screenWidth,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.05,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEBF4FF), Color(0xFFE5ECFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LOG IN',
                          style: GoogleFonts.alatsi(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: const Color(0xFF0F4C7D),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Please sign in to continue.',
                          style: GoogleFonts.alatsi(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: const Color(0xFF0F4C7D),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Username TextField with validation
                        TextFormField(
                          controller: usernameController,
                          focusNode: _usernameFocusNode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              debugPrint('Username is required');
                              return 'Username is required';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: GoogleFonts.alatsi(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Password TextField with validation
                        TextFormField(
                          controller: passwordController,
                          focusNode: _passwordFocusNode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              debugPrint('Password is required');
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              debugPrint('Password must be at least 6 characters');
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.alatsi(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          obscureText: true,
                          onFieldSubmitted: (_) {
                            if (formKey.currentState?.validate() ?? false) {
                              debugPrint('Form validated, calling signIn...');
                              signIn(usernameController.text, passwordController.text);
                            } else {
                              debugPrint('Form not valid');
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Remember me checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  isChecked = newValue ?? false;
                                });
                              },
                              activeColor: const Color(0xFF0F4C7D),
                            ),
                            Text(
                              "Remember me next time.",
                              style: GoogleFonts.alatsi(
                                color: const Color(0xFF0F4C7D),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                debugPrint('Sign in button pressed, calling signIn...');
                                signIn(usernameController.text, passwordController.text);
                              } else {
                                debugPrint('Form not valid');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        // Sign up link with partial underline
                        Text.rich(
                          TextSpan(
                            text: "Don't have an account yet? ",
                            style: GoogleFonts.alatsi(
                              color: const Color(0xFF0F4C7D),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign up',
                                style: GoogleFonts.alatsi(
                                  color: const Color(0xFF0F4C7D),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/signup');
                                  },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Small button to navigate to user list screen
                        SizedBox(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.05,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the UserList screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserList(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  'User List',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
