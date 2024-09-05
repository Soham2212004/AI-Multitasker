import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_multitasker/api.dart';

class MusicSuggestionScreen extends StatefulWidget {
  @override
  _MusicSuggestionScreenState createState() => _MusicSuggestionScreenState();
}

class _MusicSuggestionScreenState extends State<MusicSuggestionScreen> {
  final TextEditingController _moodController = TextEditingController();
  final GenerativeModel _model =
      GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
  List<String> _suggestedMusic = [];
  bool _isLoading = false;

  Future<void> _getMusicSuggestion() async {
    final mood = _moodController.text.trim();
    final message =
        "Hi, I'm in $mood mood. Please suggest me some music. Your response starts with 1.";

    setState(() {
      _isLoading = true;
      _suggestedMusic = [];
    });

    final content = [Content.text(message)];
    final response = await _model.generateContent(content);

    setState(() {
      _isLoading = false;
      // Assuming response.text contains a newline-separated list of songs
      _suggestedMusic = (response.text ?? "")
          .split('\n')
          .where((song) => song.isNotEmpty)
          .toList();
    });
  }

  Future<void> _openSpotify(String music) async {
    final query = Uri.encodeComponent(music);
    final url = 'spotify:search:$query';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open Spotify.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Music Suggestion'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _moodController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Your Mood',
                hintText: 'E.g., Happy, Sad, Energetic',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getMusicSuggestion,
              child: Text('Get Music Suggestion'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _suggestedMusic.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _suggestedMusic.length,
                          itemBuilder: (context, index) {
                            final music = _suggestedMusic[index];
                            return ListTile(
                              title: Text(music),
                              trailing: GestureDetector(
                                onTap: () => _openSpotify(music),
                                child: Image.asset(
                                  'assets/spotify.png', // Path to your PNG image
                                  width: 24, // Adjust the size as needed
                                  height: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Text('Enter your mood to get a suggestion.'),
          ],
        ),
      ),
    );
  }
}
