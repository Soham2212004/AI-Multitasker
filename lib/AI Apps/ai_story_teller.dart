import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_multitasker/api.dart';

class StoryGeneratorScreen extends StatefulWidget {
  @override
  _StoryGeneratorScreenState createState() => _StoryGeneratorScreenState();
}

class _StoryGeneratorScreenState extends State<StoryGeneratorScreen> {
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final GenerativeModel _model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);

  bool _isLoading = false;
  bool _isSpeaking = false;
  String _story = '';
  double _speechRate = 0.5; // Default speech rate
  Map<String, String>? _selectedVoice; // Placeholder for voice selection

  @override
  void initState() {
    super.initState();
    _flutterTts.setSpeechRate(_speechRate); // Initialize speech rate
  }



  Future<void> _generateStory() async {
    final genre = _genreController.text;
    final language = _languageController.text;
    final message = "I want a story for $genre genre in $language language.";

    setState(() {
      _isLoading = true;
      _story = '';
      _isSpeaking = false; // Ensure speaking is stopped when generating a new story
    });

    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);

      setState(() {
        _story = response.text?.replaceAll(RegExp(r'\*\*'), '') ?? '';
        _isLoading = false;
      });

      await _setLanguageForTts(language);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error generating story: $e");
    }
  }

  Future<void> _setLanguageForTts(String language) async {
    String languageCode;
    switch (language.toLowerCase()) {
      case 'hindi':
        languageCode = 'hi-IN';
        break;
      case 'gujarati':
        languageCode = 'gu-IN';
        break;
      default:
        languageCode = 'en-US'; // Default to English if language is not supported
    }

    try {
      final languages = await _flutterTts.getLanguages;
      if (languages.contains(languageCode)) {
        await _flutterTts.setLanguage(languageCode);
      } else {
        await _flutterTts.setLanguage('en-US'); // Fallback to English
      }
    } catch (e) {
      print("Error setting language: $e");
      await _flutterTts.setLanguage('en-US'); // Fallback to English
    }
  }

  Future<void> _startSpeaking() async {
    if (!_isSpeaking) {
      await _flutterTts.setSpeechRate(_speechRate);
      if (_selectedVoice != null) {
        await _flutterTts.setVoice(_selectedVoice!);
      }
      await _flutterTts.speak(_story);
      setState(() {
        _isSpeaking = true;
      });
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Interactive AI Storyteller'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          TextField(
            controller: _genreController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter story genre',
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _languageController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter story language',
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _generateStory,
            child: Text('Generate Story'),
          ),
          SizedBox(height: 10),
          if (!_isLoading && _story.isNotEmpty)
            ElevatedButton(
              onPressed: _isSpeaking ? _stopSpeaking : _startSpeaking,
              child: Text(_isSpeaking ? 'Stop Speaking' : 'Start Speaking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSpeaking ? Colors.red : Colors.green,
              ),
            ),
          SizedBox(height: 10),
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
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: SingleChildScrollView(
                    child: Text(_story),
                  ),
                ),
        ],
      ),
    ),
  );
}
}