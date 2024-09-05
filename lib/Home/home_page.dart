import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AI Apps/ai_chat_bot.dart';
import '../AI Apps/ai_assistant.dart';
import '../AI Apps/ai_code_explainer.dart';
import '../AI Apps/ai_voice_note.dart';
import '../AI Apps/ai_recipe_generator.dart';
import '../AI Apps/AI_text_summarizer.dart';
import '../AI Apps/ai_job_interviewcoach.dart';
import 'package:ai_multitasker/AI Apps/ai_study_buddy.dart';
import '../AI Apps/ai_financial_planner.dart';
import 'package:ai_multitasker/AI Apps/ai_translator.dart';
import 'package:ai_multitasker/AI%20Apps/ai_music_suggestion.dart';
import 'package:ai_multitasker/AI Apps/ai_book_recommandation.dart';
import 'package:ai_multitasker/AI Apps/ai_story_teller.dart';
import 'package:ai_multitasker/AI Apps/ai_travel_planner.dart';
import 'package:ai_multitasker/AI Apps/ai_image_generator.dart';
import 'package:ai_multitasker/AI Apps/extract_text.dart';
import 'package:ai_multitasker/AI Apps/ai_diet_planner.dart';
import 'package:ai_multitasker/AI Apps/ai_resume_builder.dart';
import 'ai_workout_coach.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final List<AppItem> allApps = [
    AppItem(name: 'Chat Bot', imagePath: 'assets/chatbot.jpeg'),
    AppItem(name: 'Code Explainer', imagePath: 'assets/code.png'),
    AppItem(name: 'AI Voice Note', imagePath: 'assets/voice.jpeg'),
    AppItem(name: 'AI Assistant', imagePath: 'assets/assistent.jpeg'),
    AppItem(name: 'AI Recipe Generator', imagePath: 'assets/cook.png'),
    AppItem(name: 'AI Text Summarizer', imagePath: 'assets/vocabulary.jpeg'),
    AppItem(name: 'AI Job Interview Coach', imagePath: 'assets/coach.png'),
    AppItem(name: 'AI Financial Planner', imagePath: 'assets/finance.png'),
    AppItem(name: 'AI Study Buddy', imagePath: 'assets/study.png'),
    AppItem(name: 'AI Language Translator', imagePath: 'assets/language.png'),
    AppItem(name: 'AI Music Suggestion', imagePath: 'assets/music.png'),
    AppItem(name: 'AI Book Recommandation', imagePath: 'assets/book.png'),
    AppItem(name: 'AI Story Teller', imagePath: 'assets/story.png'),
    AppItem(name: 'AI Travel Planner', imagePath: 'assets/travel.png'),
    AppItem(name: 'AI Image Generator', imagePath: 'assets/image.png'),
    AppItem(name: 'AI Text Extractor', imagePath: 'assets/text.png'),
    AppItem(name: 'AI Diet Planner', imagePath: 'assets/diet.png'),
    AppItem(name: 'AI Resume Builder', imagePath: 'assets/diet.png'),
    AppItem(name: 'AI Workout Coach', imagePath: 'assets/diet.png')


  ];

  List<AppItem> favoriteApps = [];
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Timer _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent * _animation.value,
          );
        }
      });

    _loadFavoriteApps();
    _startScrolling();
  }

  void _startScrolling() {
    _scrollTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_scrollController.hasClients && !_animationController.isAnimating) {
        _animationController.repeat();
      }
    });
  }

  void _stopScrolling() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _scrollTimer.cancel();
    super.dispose();
  }

  void toggleFavorite(AppItem app) async {
    setState(() {
      if (favoriteApps.contains(app)) {
        favoriteApps.remove(app);
      } else {
        favoriteApps.add(app);
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteAppNames =
        favoriteApps.map((app) => app.name).toList();
    await prefs.setStringList('favoriteApps', favoriteAppNames);
  }

  void _loadFavoriteApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteAppNames = prefs.getStringList('favoriteApps') ?? [];

    setState(() {
      favoriteApps =
          allApps.where((app) => favoriteAppNames.contains(app.name)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Multitasker',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorite',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onPanDown: (_) => _stopScrolling(),
              onPanCancel: _startScrolling,
              child: Container(
                height: 120,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: favoriteApps.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10.0),
                      width: 100,
                      child: _buildAppItem(favoriteApps[index], context),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Apps',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: allApps.length,
                itemBuilder: (context, index) {
                  return _buildAppItem(allApps[index], context, true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppItem(AppItem app, BuildContext context,
      [bool showFavoriteIcon = false]) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        switch (app.name) {
          case 'Chat Bot':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
            break;
          case 'Code Explainer':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CodeExplainer()),
            );
            break;
          case 'AI Voice Note':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => VoiceNoteScreen()),
            );
            break;
          case 'AI Assistant':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Assistant()),
            );
            break;
          case 'AI Recipe Generator':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RecipeGeneratorScreen()),
            );
            break;
          case 'AI Text Summarizer':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TextSummarizerScreen()),
            );
            break;
          case 'AI Job Interview Coach':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => JobInterviewCoach()),
            );
            break;
          case 'AI Financial Planner':
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => AiFinancialPlannerScreen()),
            );
            break;
          case 'AI Study Buddy':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AIStudyBuddy()),
            );
            break;
          case 'AI Language Translator':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TranslatorScreen()),
            );
            break;
          case 'AI Music Suggestion':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MusicSuggestionScreen()),
            );
            break;
          case 'AI Book Recommandation':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => BookRecommendationApp()),
            );
            break;
          case 'AI Story Teller':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => StoryGeneratorScreen()),
            );
            break;
          case 'AI Travel Planner':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TravelPlannerScreen()),
            );
            break;
          case 'AI Image Generator':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AiImageGenerator()),
            );
            break;
          case 'AI Text Extractor':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TextExtractionScreen()),
            );
            break;
          case 'AI Diet Planner':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DietPlannerScreen()),
            );
            break;
                      case 'AI Resume Builder':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ResumeFormScreen()),
            );
            break;
                      case 'AI Workout Coach':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => WorkoutPlannerScreen()),
            );
            break;
          default:
            break;
        }
      },
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .transparent, // Transparent background to let the image show
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset(
                      app.imagePath,
                      fit: BoxFit
                          .cover, // Ensures the image fills the entire box
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5), // Space between the image and the text
              Text(
                app.name,
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black, // Adjust text color based on theme
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Truncate text with "..."
                maxLines: 1, // Limit text to a single line
                textAlign: TextAlign.center,
              ),
            ],
          ),
          if (showFavoriteIcon)
            Positioned(
              right: 10,
              top: 10,
              child: GestureDetector(
                onTap: () {
                  toggleFavorite(app);
                },
                child: Icon(
                  favoriteApps.contains(app)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoriteApps.contains(app) ? Colors.red : Colors.white,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppItem {
  final String name;
  final String imagePath;

  AppItem({required this.name, required this.imagePath});
}
