import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class VoiceScreen extends StatefulWidget {
  @override
  _VoiceScreenState createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  late FlutterTts flutterTts;
  String _voiceOption = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
          onResult: (val) => setState(() {
                _text = val.recognizedWords;
              }));
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _submit() {
    _stopListening();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Voice Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _voiceOption = 'male';
                  Navigator.pop(context);
                  _convertTextToSpeech();
                },
                child: Text('Male Voice'),
              ),
              ElevatedButton(
                onPressed: () {
                  _voiceOption = 'female';
                  Navigator.pop(context);
                  _convertTextToSpeech();
                },
                child: Text('Female Voice'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _convertTextToSpeech() async {
    String voiceName;
    if (_voiceOption == 'male') {
      voiceName = "en-us-x-sfg#male_1-local";
    } else if (_voiceOption == 'female') {
      voiceName = "en-gb-x-srv#female_1-local";
    } else {
      print("Invalid voice option");
      return;
    }

    await flutterTts.setVoice({"name": voiceName, "locale": "en-US"});

    flutterTts.setStartHandler(() {
      setState(() {});
    });

    flutterTts.setCompletionHandler(() {
      setState(() {});
    });

    flutterTts.setErrorHandler((msg) {
      print("Error: $msg");
      setState(() {});
    });

    await flutterTts.speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice to Voice Conversion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_text, style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.mic : Icons.mic_off),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}