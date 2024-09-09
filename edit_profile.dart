import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/arrow_left_1_x2.svg'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Section
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: SvgPicture.asset(
                        'assets/vectors/vector_10_x2.svg',
                        width: 60,
                        height: 60,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        'EDIT',
                        style: GoogleFonts.openSans(
                          fontSize: 10,
                          color: const Color(0xFF6C6D56),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Display Name
              Text(
                'Display Name',
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  color: const Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 20.0),
              // Gender Selection
              Text(
                'Gender',
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  color: const Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 10.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GenderOption('female', true),
                  GenderOption('male', false),
                  GenderOption('other', false),
                  GenderOption('prefer not to say', false),
                ],
              ),
              const SizedBox(height: 20.0),
              // Birthday
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Birthday',
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  Text(
                    'EDIT',
                    style: GoogleFonts.openSans(
                      fontSize: 10,
                      color: const Color(0xFF6C6D56),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 20.0),
              // About Me
              Text(
                'About Me',
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  color: const Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 10.0),
              // Save Button
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    // Save action
                  },
                  child: const Text('SAVE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Gender Option Widget
class GenderOption extends StatelessWidget {
  final String gender;
  final bool isSelected;

  const GenderOption(this.gender, this.isSelected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE9CEDB) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        gender,
        style: GoogleFonts.openSans(
          fontSize: 13,
          color: const Color(0xFF000000),
        ),
      ),
    );
  }
}
