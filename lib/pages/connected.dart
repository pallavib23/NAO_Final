import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // Import for JSON decoding
import 'package:http/http.dart' as http; // Import for making HTTP requests
import 'package:nao/pages/settings.dart'; // Import the Settings page
import 'package:nao/pages/edit_profile.dart'; // Import the EditProfile page
import 'package:speech_to_text/speech_to_text.dart'; // Import for speech-to-text

class Connected extends StatefulWidget {
  const Connected({super.key});

  @override
  _ConnectedState createState() => _ConnectedState();
}

class _ConnectedState extends State<Connected> {
  String _selectedDifficulty = "Easy";
  String _generatedText = "";
  List<Map<String, String>> _questions = [];
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _loadQuestions();
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('http://172.27.160.1:5000/check_connection'));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] != 'connected') {
          _showErrorDialog('NAO robot is not connected. Please reconnect.');
        }
      } else {
        _showErrorDialog('Failed to check NAO robot connection status.');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _loadQuestions() async {
    String data = "";
    switch (_selectedDifficulty) {
      case "Easy":
        data = await rootBundle.loadString('assets/easy.json');
        break;
      case "Medium":
        data = await rootBundle.loadString('assets/medium.json');
        break;
      case "Hard":
        data = await rootBundle.loadString('assets/difficult.json');
        break;
    }
    final jsonResult = json.decode(data);
    setState(() {
      _questions = (jsonResult['questions'] as List<dynamic>)
          .map((q) => {
        "question": q['question'].toString(),
        "answer": q['answer'].toString()
      })
          .toList();
      _generatedText = _formatQuestions(_questions);
    });
  }

  String _formatQuestions(List<Map<String, String>> questions) {
    return questions.asMap().entries.map((entry) {
      int index = entry.key + 1; // Question number
      var q = entry.value; // Question data
      return "$index. Question:\n${q['question']}\nAnswer:\n${q['answer']}";
    }).join("\n\n");
  }

  void _setDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
      _loadQuestions(); // Reload questions based on the selected difficulty
    });
  }

  Future<void> _askAllQuestions() async {
    for (var question in _questions) {
      await _askQuestion(question);
    }
  }

  Future<void> _askQuestion(Map<String, String> question) async {
    try {
      final response = await http.post(
        Uri.parse('http://172.27.160.1:5000/ask_questions'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": question['question']}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _generatedText = question['question']!;
        });

        // Introduce a delay to allow NAO to finish asking the question
        await Future.delayed(const Duration(seconds: 10)); // Adjust the delay as needed

        // Start listening for the user's response
        _startListening();
      } else {
        _showErrorDialog('Failed to send question to NAO.');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(onResult: (result) async {
        if (result.finalResult) {
          setState(() {
            _isListening = false;
          });

          // Send the user's response to NAO for evaluation
          await _checkAnswer(result.recognizedWords);
        }
      });
    }
  }

  Future<void> _checkAnswer(String answer) async {
    try {
      final response = await http.post(
        Uri.parse('http://172.27.160.1:5000/check_answer'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"answer": answer}),
      );

      if (response.statusCode == 200) {
        final feedback = jsonDecode(response.body);
        // Display feedback or perform any action
        print('Feedback from NAO: ${feedback['feedback']}');

        // Move to the next question
        int currentIndex =
        _questions.indexWhere((q) => q['question'] == _generatedText);
        if (currentIndex < _questions.length - 1) {
          await _askQuestion(_questions[currentIndex + 1]);
        } else {
          print('Quiz completed.');
          // Handle quiz completion
        }
      } else {
        _showErrorDialog('Failed to check answer.');
      }
    } catch (e) {
      _showErrorDialog('Error checking answer: $e');
    }
  }

  Future<void> _sendTextToNao() async {
    try {
      final response = await http.post(
        Uri.parse('http://172.27.160.1:5000/send_text'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": _textController.text}),
      );

      if (response.statusCode == 200) {
        print("Text sent to NAO.");
      } else {
        _showErrorDialog('Failed to send text to NAO.');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  void _showErrorDialog(String message) {
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF00C6FF), Color(0xFF0072FF)],
            stops: <double>[0.0, 1.0],
          ),
        ),
        constraints: BoxConstraints(minHeight: screenHeight),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 74),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/vectors/user_square_1_x2.svg',
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfile()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      iconSize: 40,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE9CEDB), Color(0xFFE6F7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    width: 305,
                    height: 313,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Hello. I'm NAO!",
                          style: GoogleFonts.alatsi(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            height: 1.2,
                            letterSpacing: -0.3,
                            color: const Color(0xFF0F4C7D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/images/nao_turned_on_1.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Tell me what to say : ",
                  style: GoogleFonts.alatsi(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    height: 1.2,
                    letterSpacing: -0.3,
                    color: const Color(0xFFFFFFFF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: null,
                    expands: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your text here...",
                      hintStyle: GoogleFonts.alatsi(
                        color: Colors.grey,
                      ),
                    ),
                    style: GoogleFonts.alatsi(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 133,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF72C6FF), Color(0xFF004E8F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: _sendTextToNao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      "SEND",
                      style: GoogleFonts.alatsi(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 1.2,
                        letterSpacing: -0.3,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDifficultyButton("Easy"),
                    _buildDifficultyButton("Medium"),
                    _buildDifficultyButton("Hard"),
                  ],
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE9CEDB), Color(0xFFE6F7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _generatedText,
                          style: GoogleFonts.alatsi(
                            fontSize: 18,
                            color: const Color(0xFF0F4C7D),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 133,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF72C6FF), Color(0xFF004E8F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton(
                            onPressed: _askAllQuestions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              "SEND",
                              style: GoogleFonts.alatsi(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                height: 1.2,
                                letterSpacing: -0.3,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE9CEDB), Color(0xFFE6F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ElevatedButton(
          onPressed: () {
            _setDifficulty(label);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.alatsi(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.2,
              letterSpacing: -0.3,
              color: const Color(0xFF0F4C7D),
            ),
          ),
        ),
      ),
    );
  }
}
