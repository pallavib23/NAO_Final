import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/database_helper.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp(String username, String password) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.registerUser(username, password);
      Navigator.pushNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
    } catch (e) {
      print('Error during sign-up: $e');
      if (e.toString().contains('UNIQUE constraint failed: users.username')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
      } else if (e.toString().contains('NetworkError')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please check your connection.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageHeight = screenHeight * 0.4;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background Image covering the upper part
            Container(
              width: screenWidth,
              height: imageHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/aldebaran_robotics_nao_screen_wallpaper_1.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Semi-transparent rectangle covering the bottom part
            Container(
              width: screenWidth,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), // Rounded corners for the top
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'REGISTER',
                    style: GoogleFonts.alatsi(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.08,
                      color: const Color(0xFF0F4C7D),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Please sign up to continue.',
                    style: GoogleFonts.alatsi(
                      fontSize: screenWidth * 0.04,
                      color: const Color(0xFF0F4C7D),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        buildTextField(
                          controller: usernameController,
                          placeholder: 'Username',
                          icon: Icons.person_outline,
                          isPasswordField: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        buildTextField(
                          controller: phoneController,
                          placeholder: 'Phone Number',
                          icon: Icons.phone_outlined,
                          isPasswordField: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        buildTextField(
                          controller: passwordController,
                          placeholder: 'Password',
                          icon: Icons.lock_outline,
                          isPasswordField: true,
                          isVisible: isPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        buildTextField(
                          controller: confirmPasswordController,
                          placeholder: 'Confirm Password',
                          icon: Icons.lock_outline,
                          isPasswordField: true,
                          isVisible: isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        buildSignUpButton(screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.alatsi(
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: Text(
                                'Login',
                                style: GoogleFonts.alatsi(
                                  fontSize: screenWidth * 0.035,
                                  color: const Color(0xFF1CB5E0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPasswordField = false,
    bool isVisible = false,
    Function()? onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPasswordField && !isVisible,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.alatsi(),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFF0F4C7D)),
          suffixIcon: isPasswordField
              ? IconButton(
            icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF0F4C7D)),
            onPressed: onVisibilityToggle,
          )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget buildSignUpButton(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF1CB5E0), Color(0xFF000046)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if (formKey.currentState?.validate() ?? false) {
            signUp(usernameController.text, passwordController.text);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please correct the form errors')),
            );
          }
        },
        child: Text(
          'Sign Up',
          style: GoogleFonts.alatsi(
            fontWeight: FontWeight.w400,
            fontSize: screenWidth * 0.05,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
