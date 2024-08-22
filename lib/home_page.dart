import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'chat_bot.dart';
import 'ai_assistant.dart';
import 'code_explainer.dart';
import 'voice_note.dart';



class HomePage extends StatelessWidget {
  final List<AppItem> apps = [
    AppItem(name: 'Chat Bot', icon: Icons.chat, color: Colors.blue),
    AppItem(name: 'Code Explainer', icon: Icons.code, color: Colors.pink),
    AppItem(name: 'AI Voice Note', icon: Icons.record_voice_over, color: Colors.orange),
    AppItem(name: 'AI Assistant', icon: Icons.assistant, color: Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Multitasker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            return _buildAppItem(apps[index], context);
          },
        ),
      ),
    );
  }

  Widget _buildAppItem(AppItem app, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective screen based on the app name
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
          default:
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: app.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(app.icon, size: 50, color: app.color),
            const SizedBox(height: 10),
            Text(
              app.name,
              style: TextStyle(
                fontSize: 16,
                color: app.color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AppItem {
  final String name;
  final IconData icon;
  final Color color;

  AppItem({required this.name, required this.icon, required this.color});
}
