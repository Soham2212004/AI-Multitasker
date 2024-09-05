import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ai_multitasker/api.dart';

class TranslatorScreen extends StatefulWidget {
  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  TextEditingController _sentenceController = TextEditingController();
  TextEditingController _languageController = TextEditingController();

  final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
  String _translatedText = '';
  bool _isLoading = false;

  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> translateText() async {
    final sentence = _sentenceController.text;
    final language = _languageController.text;
    final message = "Please translate \"$sentence\" into $language language."; // Prepare message

    setState(() {
      _isLoading = true;
      _sentenceController.clear();
      _languageController.clear();
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _isLoading = false;

      // Remove all instances of "**" from the response text
      _translatedText = (response.text ?? "").replaceAll("**", "");

      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yy - HH:mm:ss').format(now);

      _history.add({
        'date': formattedDate,
        'sentence': sentence,
        'language': language,
        'translation': _translatedText,
      });

      _saveHistory(); // Save history after updating
    });
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('translator_history');
    if (historyJson != null) {
      final List<dynamic> historyList = jsonDecode(historyJson);
      setState(() {
        _history
            .addAll(historyList.map((item) => Map<String, String>.from(item)));
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_history);
    await prefs.setString('translator_history', historyJson);
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranslatorHistoryScreen(history: _history),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Language Translator'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _sentenceController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your sentence here...',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _languageController,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the language...',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: translateText,
                child: Text('Translate'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Translating, please wait...',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: SelectableText(
                          _translatedText,
                          style: TextStyle(fontSize: 16.0, color: textColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class TranslatorHistoryScreen extends StatelessWidget {
  final List<Map<String, String>> history;

  TranslatorHistoryScreen({required this.history});

  Future<void> _clearHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('translator_history');

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translation History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final truncatedSentence = item['sentence']!.length > 30
                    ? '${item['sentence']!.substring(0, 30)}...'
                    : item['sentence']!;

                return ListTile(
                  title: Text('Date: ${item['date']}'),
                  subtitle: Text('Sentence: $truncatedSentence'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TranslatorHistoryDetailScreen(
                          sentence: item['sentence']!,
                          language: item['language']!,
                          translation: item['translation']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _clearHistory(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red, // Text color
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Clear History'),
            ),
          ),
        ],
      ),
    );
  }
}

class TranslatorHistoryDetailScreen extends StatelessWidget {
  final String sentence;
  final String language;
  final String translation;

  TranslatorHistoryDetailScreen({
    required this.sentence,
    required this.language,
    required this.translation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translation Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sentence:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(sentence, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Language:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(language, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Translation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(translation, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
