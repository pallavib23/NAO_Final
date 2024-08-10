import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.openSans(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/arrow_left_x2.svg'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0, // Reduce spacing between leading icon and title
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjusted padding
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              const SizedBox(height: 10), // Reduce space here
              Text(
                'ACCOUNT',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: const Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/vectors/vector_7_x2.svg',
                  width: 34.7,
                  height: 34.7,
                ),
                title: Text(
                  'Profile',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: const Color(0xFF000000),
                  ),
                ),
                trailing: SvgPicture.asset(
                  'assets/vectors/vector_2_x2.svg',
                  width: 25.6,
                  height: 31,
                ),
                onTap: () {
                  // Navigate to Profile screen
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/vectors/container_x2.svg',
                  width: 34.7,
                  height: 34.7,
                ),
                title: Text(
                  'Turn on Location',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: const Color(0xFF000000),
                  ),
                ),
                trailing: SvgPicture.asset(
                  'assets/vectors/vector_3_x2.svg',
                  width: 25.6,
                  height: 31,
                ),
                onTap: () {
                  // Toggle location settings
                },
              ),
              const Divider(color: Colors.grey),
              // Notifications Section
              const SizedBox(height: 10),
              Text(
                'NOTIFICATIONS',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: const Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text(
                  'Activities notifications',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: const Color(0xFF000000),
                  ),
                ),
                value: true,
                onChanged: (value) {
                  // Toggle activities notifications
                },
              ),
              SwitchListTile(
                title: Text(
                  'Email notifications',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: const Color(0xFF000000),
                  ),
                ),
                value: false,
                onChanged: (value) {
                  // Toggle email notifications
                },
              ),
              const Divider(color: Colors.grey),
              // Security Section
              const SizedBox(height: 10),
              Text(
                'SECURITY',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: const Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/vectors/vector_9_x2.svg',
                  width: 34.7,
                  height: 34.7,
                ),
                title: Text(
                  'Sign in with face ID',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: const Color(0xFF000000),
                  ),
                ),
                trailing: SvgPicture.asset(
                  'assets/vectors/vector_5_x2.svg',
                  width: 25.6,
                  height: 31,
                ),
                onTap: () {
                  // Navigate to face ID settings
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/vectors/vector_6_x2.svg',
                  width: 34.7,
                  height: 34.7,
                ),
                title: Text(
                  'Change Password',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: const Color(0xFF000000),
                  ),
                ),
                trailing: SvgPicture.asset(
                  'assets/vectors/vector_x2.svg',
                  width: 25.6,
                  height: 31,
                ),
                onTap: () {
                  // Navigate to change password
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
