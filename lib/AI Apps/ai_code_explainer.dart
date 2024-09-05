import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ai_multitasker/api.dart';


class CodeExplainer extends StatefulWidget {
  @override
  _CodeExplainerState createState() => _CodeExplainerState();
}

class _CodeExplainerState extends State<CodeExplainer> {
  TextEditingController _userInput = TextEditingController();

  final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
  String _outputMessage = '';
  bool _isLoading = false;

  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> explainCode() async {
    final code = _userInput.text;
    final message =
        "Explain This Code Line By Line and the output should be starts like : language- , Explanation- , Full Code:- , Output\n$code"; // Prepare message

    setState(() {
      _isLoading = true;
      _userInput.clear();
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _isLoading = false;

      // Remove all instances of "**" from the response text
      _outputMessage = (response.text ?? "").replaceAll("**", "");

      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yy - HH:mm:ss').format(now);

      _history.add({
        'date': formattedDate,
        'input': code,
        'output': _outputMessage,
      });

      _saveHistory(); // Save history after updating
    });
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('code_explainer_history');
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
    await prefs.setString('code_explainer_history', historyJson);
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
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Code Explainer'),
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
                controller: _userInput,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your code here...',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: explainCode,
                child: Text('Explain Code'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Fetching The Output Please Wait ...',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: SelectableText(
                          _outputMessage,
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

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> history;

  HistoryScreen({required this.history});

  Future<void> _clearHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('code_explainer_history'); // Use the correct key

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
                // Truncate the input for display
                final truncatedInput = item['input']!.length > 30
                    ? '${item['input']!.substring(0, 30)}...'
                    : item['input']!;

                return ListTile(
                  title: Text('Date: ${item['date']}'),
                  subtitle: Text('Input: $truncatedInput'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailScreen(
                          input: item['input']!,
                          output: item['output']!,
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
  final String input;
  final String output;

  HistoryDetailScreen({required this.input, required this.output});

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
              'Input:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(input, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              'Output:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(output, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
