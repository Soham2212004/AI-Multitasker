import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart'; // Import the open_file package

import 'package:ai_multitasker/api.dart';

class TravelPlannerScreen extends StatefulWidget {
  @override
  _TravelPlannerScreenState createState() => _TravelPlannerScreenState();
}

class _TravelPlannerScreenState extends State<TravelPlannerScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey); // Replace with your API key

  bool _isLoading = false;
  bool _isSpeaking = false;
  String _responseText = '';
  double _speechRate = 0.5; // Default speech rate

  @override
  void initState() {
    super.initState();
    _flutterTts.setSpeechRate(_speechRate); // Initialize speech rate
  }

  Future<void> _generateTravelPlan() async {
    final city = _cityController.text;
    final days = _daysController.text;
    final language = _languageController.text;
    final message = "Can you make me a travel plan for $city city for $days days in $language language?";

    setState(() {
      _isLoading = true;
      _responseText = '';
      _isSpeaking = false; // Ensure speaking is stopped when generating a new plan
    });

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _responseText = response.text?.replaceAll(RegExp(r'\*'), '') ?? '';
        _isLoading = false;
      });

      await _generateAudioFile(_responseText);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error generating travel plan: $e");
    }
  }

  Future<void> _speakResponse(String text) async {
    try {
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setLanguage('en-US'); // Adjust as needed
      await _flutterTts.speak(text);

      setState(() {
        _isSpeaking = true;
      });
    } catch (e) {
      print("Error speaking response: $e");
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

Future<void> _generateAudioFile(String text) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/travel_plan.mp3';
    final file = File(filePath);

    // Print the path for debugging
    print("Saving audio file to: $filePath");

    // Generate the audio file
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setLanguage('en-US'); // Adjust as needed
    await _flutterTts.synthesizeToFile(text, file.path);

    // Wait for a moment to ensure file is created
    await Future.delayed(Duration(seconds: 2));

    // Check if file exists
    if (await file.exists()) {
      final fileLength = await file.length();
      if (fileLength > 0) {
        // Open the generated audio file
        await OpenFile.open(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio file saved and opened at: $filePath')),
        );
      } else {
        throw Exception("File is empty: $filePath");
      }
    } else {
      throw Exception("File does not exist: $filePath");
    }
  } catch (e) {
    print("Error generating or opening audio file: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating or opening audio file')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Travel Planner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter city',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _daysController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter number of days',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _languageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter language',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _generateTravelPlan,
              child: Text('Submit'),
            ),
            SizedBox(height: 10),
            if (_isLoading) CircularProgressIndicator(),
            if (!_isLoading && _responseText.isNotEmpty)
              ElevatedButton(
                onPressed: _isSpeaking ? _stopSpeaking : () => _speakResponse(_responseText),
                child: Text(_isSpeaking ? 'Stop Speaking' : 'Start Speaking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSpeaking ? Colors.red : Colors.green,
                ),
              ),
            SizedBox(height: 10),
            if (!_isLoading && _responseText.isNotEmpty)
              ElevatedButton(
                onPressed: () => _generateAudioFile(_responseText),
                child: Text('Generate Audio File'),
              ),
            SizedBox(height: 20),
            Text('Speech Rate: ${_speechRate.toStringAsFixed(2)}'),
            Slider(
              value: _speechRate,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _speechRate.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _speechRate = value;
                });
                _flutterTts.setSpeechRate(value);
              },
            ),
            SizedBox(height: 20),
            Text(_responseText),
          ],
        ),
      ),
    );
  }
}
