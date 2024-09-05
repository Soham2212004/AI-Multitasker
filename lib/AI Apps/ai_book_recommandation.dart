import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:ai_multitasker/api.dart';



class BookRecommendationApp extends StatefulWidget {
  @override
  _BookRecommendationAppState createState() => _BookRecommendationAppState();
}

class _BookRecommendationAppState extends State<BookRecommendationApp> {
  final TextEditingController _bookGenresController = TextEditingController();
  final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
  List<String> _recommendedBooks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookGenresController.addListener(_updateSubmitButtonState);
  }

  @override
  void dispose() {
    _bookGenresController.removeListener(_updateSubmitButtonState);
    _bookGenresController.dispose();
    super.dispose();
  }

  // Check if the bookGenres input is provided
  bool get _isSubmitEnabled => _bookGenresController.text.isNotEmpty;

  void _updateSubmitButtonState() {
    setState(() {});
  }

  Future<void> _getBookRecommendations() async {
    final bookGenres = _bookGenresController.text;

    final message = "Please Suggest me 9-10 books of $bookGenres genres. Your response should be like this 1.  2.  3.  4.  5.";

    setState(() {
      _isLoading = true;
    });

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _isLoading = false;
        // Processing the response to get all book suggestions
        _recommendedBooks = response.text
            ?.replaceAll('*', '') // Remove all asterisks
            .split('\n')
            .where((line) => line.trim().isNotEmpty && RegExp(r'^\d+\.\s').hasMatch(line)) // Ensure it starts with a number followed by a period and space
            .toList() ?? [];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _openGoogleSearch(String query) async {
    final url = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open Google search for $query';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Recommendations'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _bookGenresController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter book genres',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitEnabled ? () {
                print('Submit button pressed');
                _getBookRecommendations();
              } : null,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _recommendedBooks.length,
                      itemBuilder: (context, index) {
                        final book = _recommendedBooks[index];
                        return ListTile(
                          title: Text(book),
                          trailing: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () => _openGoogleSearch(book),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
