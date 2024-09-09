import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'connected.dart';
import 'edit_profile.dart';
import 'settings.dart';

class Sleep extends StatelessWidget {
  const Sleep({super.key});

  Future<void> connectToNao(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse('http://172.27.160.1:5000/connect_nao'));

      print("Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("JSON response: $jsonResponse");
        if (jsonResponse['status'] == 'connected') {
          // Navigate to the connected screen
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Connected()),
            );
          }
        } else {
          if (context.mounted) {
            _showErrorDialog(context, 'Failed to connect to NAO robot.');
          }
        }
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Connection error: $e');
      }
    }
  }


  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF00C6FF), Color(0xFF0072FF)],
            stops: <double>[0.5, 1],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/vectors/user_square_x2.svg',
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfile()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      iconSize: 40, 
                      color: Colors.white, 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Settings()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'SLEEPING...',
                  style: GoogleFonts.alatsi(
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    color: const Color(0xE80F4C7D),
                  ),
                ),
                const SizedBox(height: 30),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SvgPicture.asset(
                        'assets/vectors/rectangle_12_x2.svg',
                        width: 254,
                        height: 269,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 254,
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/images/rectangle_11.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Please connect to continue using the app!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alatsi(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5), 
                      child: Container(
                        width: 300, 
                        height: 450, 
                        color: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'To connect to NAO Robot:\n\n'
                          '1. Requirement:\n'
                          '   - Choregraph, Terminal, NAO Robot\n'
                          '2. Connection:\n'
                          '   - Press the button on NAO\'s chest to start the robot, press one more time to know the IP Address of NAO\n'
                          '   - Open Terminal: Ping IP Address of NAO\n'
                          '   - If successful, connection was made.\n'
                          '3. Open Choregraph, click on connection button in toolbar, connect to NAO.\n'
                          '4. Use the app!',
                          style: GoogleFonts.alatsi(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: const Color(0xE80F4C7D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF000046), Color(0xFF1CB5E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ElevatedButton(
                    onPressed: () => connectToNao(context), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      shadowColor: Colors.transparent, 
                    ),
                    child: Text(
                      'Successfully connected?',
                      style: GoogleFonts.alatsi(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
