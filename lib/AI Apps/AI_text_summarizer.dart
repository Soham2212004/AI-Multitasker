import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_multitasker/api.dart';


class TextSummarizerScreen extends StatefulWidget {
  @override
  _TextSummarizerScreenState createState() => _TextSummarizerScreenState();
}

class _TextSummarizerScreenState extends State<TextSummarizerScreen> {
  TextEditingController _textController = TextEditingController();

  final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
  String _summaryResponse = '';
  bool _isLoading = false;

  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _summarizeText() async {
    final text = _textController.text;
    final message =
        "Summarize this text: $text"; // Prepare message

    setState(() {
      _isLoading = true;
      _textController.clear();
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _isLoading = false;
      _summaryResponse = response.text ?? "";

      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yy - HH:mm:ss').format(now);

      _history.add({
        'date': formattedDate,
        'text': text,
        'summary': _summaryResponse,
      });

      _saveHistory(); // Save history after updating
    });
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('text_summarizer_history');
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
    await prefs.setString('text_summarizer_history', historyJson);
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(history: _history),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Text Summarizer'),
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
              Text(
                'Please provide your text in the below box:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your text here...',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _summarizeText,
                child: Text('Submit'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Summarizing your text, please wait...',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: SelectableText(
                          _summaryResponse,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
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

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> history;

  HistoryScreen({required this.history});

  Future<void> _clearHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('text_summarizer_history'); // Use the correct key

    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final truncatedText = item['text']!.length > 30
                    ? '${item['text']!.substring(0, 30)}...'
                    : item['text']!;

                return ListTile(
                  title: Text('Date: ${item['date']}'),
                  subtitle: Text('Text: $truncatedText'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailScreen(
                          text: item['text']!,
                          summary: item['summary']!,
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

class HistoryDetailScreen extends StatelessWidget {
  final String text;
  final String summary;

  HistoryDetailScreen({required this.text, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(text, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Summary:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(summary, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
