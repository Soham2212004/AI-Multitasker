import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';


class PersonalAIInterviewerScreen extends StatefulWidget {
  const PersonalAIInterviewerScreen({Key? key}) : super(key: key);

  @override
  State<PersonalAIInterviewerScreen> createState() =>
      _PersonalAIInterviewerScreenState();
}

class _PersonalAIInterviewerScreenState
    extends State<PersonalAIInterviewerScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _fieldController = TextEditingController();
  TextEditingController _answerController = TextEditingController();
  bool _nameEntered = false;
  bool _fieldEntered = false;
  bool _isListening = false;
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  final model = GenerativeModel(model: 'gemini-pro', apiKey: "");
  List<String> _interviewQuestions = [];
  int _currentQuestionIndex = 0;
  String _userResponse = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    checkPermissions();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('onStatus: $status');
        if (status == 'done' && _isListening) {
          _submitResponse();
        }
      },
      onError: (errorNotification) => print('onError: $errorNotification'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _userResponse = result.recognizedWords;
          });
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
      );
    }
  }

  void stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void checkPermissions() async {
    if (await Permission.microphone.request().isGranted) {
    } else {}
  }

  void _startInterview() async {
    final response = await model.generateContent([
      Content.text(
          "Generate interview questions for a ${_fieldController.text} candidate")
    ]);

    setState(() {
      _interviewQuestions = response.text!.split('\n');
      _currentQuestionIndex = 0;
      _askNextQuestion();
    });
  }

  void _askNextQuestion() async {
    if (_currentQuestionIndex < _interviewQuestions.length) {
      await _speak(_interviewQuestions[_currentQuestionIndex]);
      await Future.delayed(Duration(seconds: 1));
      await _speak("Now your turn.");
      startListening();
    }
  }

  void _submitResponse() async {
    stopListening();

    final response = await model.generateContent(
        [Content.text("Evaluate this response: $_userResponse")]);

    setState(() {
      _currentQuestionIndex++;
      _userResponse = "";
      if (_currentQuestionIndex < _interviewQuestions.length) {
        _askNextQuestion();
      } else {
        _endInterview();
      }
    });
  }

  void _endInterview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Interview Completed"),
        content: Text(
            "Thank you for your responses. Your interview has been completed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _greetUser() async {
    String name = _nameController.text;
    await _speak(
        "Welcome $name, Today I'm your virtual AI interviewer. Please tell me your field of study.");
    setState(() {
      _nameEntered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal AI Interviewer'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_nameEntered)
                Column(
                  children: [
                    Text("Please enter your name:"),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: 'Name'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _greetUser();
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              if (_nameEntered && !_fieldEntered)
                Column(
                  children: [
                    Text(
                        "Hello ${_nameController.text}! Please enter your field of study:"),
                    TextField(
                      controller: _fieldController,
                      decoration: InputDecoration(hintText: 'Field of study'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _fieldEntered = true;
                        });
                        _startInterview();
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              if (_nameEntered && _fieldEntered)
                Column(
                  children: [
                    Text(_interviewQuestions.isNotEmpty
                        ? _interviewQuestions[_currentQuestionIndex]
                        : " "),
                    SizedBox(height: 20),
                    Text("Your Answer:"),
                    Text(_userResponse),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? stopListening : startListening,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}