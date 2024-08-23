



import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput = TextEditingController();
  static const apiKey = "";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];
  final List<Map<String, String>> _history = []; // History list
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _speech.initialize();
    _startNewSession();
    _loadHistory();
  }

  void _startNewSession() {
    final now = DateTime.now();
    _sessionId = DateFormat('dd/MM/yy - HH:mm:ss').format(now);
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history');
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
    await prefs.setString('chat_history', historyJson);
  }

  Future<void> sendMessage() async {
    final message = _userInput.text;
    if (message.isEmpty) return;

    setState(() {
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
          isUser: false, message: response.text ?? "", date: DateTime.now()));

      _history.add({
        'sessionId': _sessionId,
        'input': message,
        'output': response.text ?? "",
      });

      _saveHistory();
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _userInput.text = _lastWords + result.recognizedWords;
            _userInput.selection = TextSelection.fromPosition(
              TextPosition(offset: _userInput.text.length),
            );
          });
        },
        listenFor: Duration(minutes: 1),
        pauseFor: Duration(seconds: 5),
        onSoundLevelChange: (level) {},
        cancelOnError: true,
        partialResults: true,
      );
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'notListening' && _isListening) {
      _startListening();
    }
  }

  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
    _lastWords = _userInput.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Bot'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            color: Colors.white.withOpacity(0.7),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryNewScreen(history: _history),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: NetworkImage(
                'https://c4.wallpaperflare.com/wallpaper/899/678/503/movies-comics-xmen-wolverine-superheroes-logan-claws-3333x4929-entertainment-movies-hd-art-wallpaper-preview.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Messages(
                      isUser: message.isUser,
                      message: message.message,
                      date: DateFormat('HH:mm').format(message.date));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    color: Colors.white,
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: 'Enter Your Message',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      maxLines: null,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    padding: EdgeInsets.all(12),
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(CircleBorder()),
                    ),
                    onPressed: () {
                      sendMessage();
                      if (_isListening) {
                        _stopListening();
                      }
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryNewScreen extends StatelessWidget {
  final List<Map<String, String>> history;

  HistoryNewScreen({required this.history});

  Future<void> _clearHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history'); // Clear history from shared preferences

    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    final groupedHistory = <String, List<Map<String, String>>>{};
    for (var item in history) {
      final sessionId = item['sessionId']!;
      if (!groupedHistory.containsKey(sessionId)) {
        groupedHistory[sessionId] = [];
      }
      groupedHistory[sessionId]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: groupedHistory.entries.map((entry) {
                final sessionId = entry.key;
                final items = entry.value;

                return ExpansionTile(
                  title: Text('Session: $sessionId'),
                  children: items.map((item) {
                    return ListTile(
                      title: Text('Date: ${DateTime.now().toLocal()}'),
                      subtitle: Text('Input: ${item['input']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryNewDetailScreen(
                              input: item['input']!,
                              output: item['output']!,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              }).toList(),
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

class HistoryNewDetailScreen extends StatelessWidget {
  final String input;
  final String output;

  HistoryNewDetailScreen({required this.input, required this.output});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Details'),
      ),
      body: Padding(
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

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
  });
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: isUser ? Radius.circular(10) : Radius.zero,
          topRight: Radius.circular(10),
          bottomRight: isUser ? Radius.zero : Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            message,
            style: TextStyle(
                fontSize: 16, color: isUser ? Colors.white : Colors.black),
          ),
          SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
                fontSize: 12, color: isUser ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }
}
