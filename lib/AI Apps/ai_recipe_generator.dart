import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_multitasker/api.dart';

class RecipeGeneratorScreen extends StatefulWidget {
  @override
  _RecipeGeneratorScreenState createState() => _RecipeGeneratorScreenState();
}

class _RecipeGeneratorScreenState extends State<RecipeGeneratorScreen> {
  TextEditingController _ingredientsController = TextEditingController();
  TextEditingController _languageController = TextEditingController();
  TextEditingController _recipeLanguageController = TextEditingController();

  final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
  List<String> _dishNames = [];
  Map<String, String> _fullRecipes = {};
  bool _isLoading = false;

  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _generateRecipe() async {
    final ingredients = _ingredientsController.text;
    final language = _languageController.text.isNotEmpty
        ? _languageController.text
        : 'English';
    final message =
        "Which dishes can I make using these ingredients: $ingredients? Please list them as 1. Dish Name 2. Dish Name etc., in $language language.";

    setState(() {
      _isLoading = true;
      _ingredientsController.clear();
      _languageController.clear();
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _isLoading = false;
      _dishNames = response.text
              ?.replaceAll(RegExp(r'\*\*'), '') // Remove all asterisks
              .split('\n')
              .where((line) =>
                  line.trim().isNotEmpty && RegExp(r'^\d+\.\s').hasMatch(line))
              .map((line) => line.trim().replaceFirst(RegExp(r'^\d+\.\s'), ''))
              .toList() ??
          [];
    });
  }

  Future<void> _getFullRecipe(String dishName) async {
    final recipeLanguage = _recipeLanguageController.text.isNotEmpty
        ? _recipeLanguageController.text
        : 'English'; // Default to English if no language is provided

    final message =
        "Please give me the full recipe of how to make $dishName in $recipeLanguage language.";

    setState(() {
      _isLoading = true;
    });

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _isLoading = false;
        final cleanedRecipe =
            response.text?.replaceAll(RegExp(r'\*'), '') ?? "";

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullRecipeScreen(
              dishName: dishName,
              recipe: cleanedRecipe,
              language: recipeLanguage, // Pass the language to the next screen
            ),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching recipe: $e");
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('recipe_generator_history');
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
    await prefs.setString('recipe_generator_history', historyJson);
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
        title: Text('Recipe Generator'),
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
                controller: _ingredientsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your ingredients here...',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _languageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the language for dish names...',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _generateRecipe,
                child: Text('Generate Dishes'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Generating your recipe, please wait...',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _dishNames.map((dish) {
                        return ListTile(
                          title: Text(dish),
                          trailing: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Select Recipe Language'),
                                    content: TextField(
                                      controller: _recipeLanguageController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter recipe language...',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _getFullRecipe(dish);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Get Full Recipe'),
                          ),
                        );
                      }).toList(),
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
    await prefs.remove('recipe_generator_history'); // Use the correct key

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
                final truncatedIngredients = item['ingredients']!.length > 30
                    ? '${item['ingredients']!.substring(0, 30)}...'
                    : item['ingredients']!;

                return ListTile(
                  title: Text('Date: ${item['date']}'),
                  subtitle: Text('Ingredients: $truncatedIngredients'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailScreen(
                          ingredients: item['ingredients']!,
                          recipe: item['recipe']!,
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
  final String ingredients;
  final String recipe;

  HistoryDetailScreen({required this.ingredients, required this.recipe});

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
              'Ingredients:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(ingredients),
            SizedBox(height: 20),
            Text(
              'Generated Recipe:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(recipe),
          ],
        ),
      ),
    );
  }
}

class FullRecipeScreen extends StatelessWidget {
  final String dishName;
  final String recipe;
  final String language;

  FullRecipeScreen({
    required this.dishName,
    required this.recipe,
    required this.language, // Add the language parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$dishName Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dish: $dishName ($language)', // Display the language
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            SelectableText(recipe, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
