import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ai_multitasker/stability.dart';

final homeProvider = ChangeNotifierProvider<HomeProvider>((ref) => HomeProvider());

class AiImageGenerator extends ConsumerWidget {
  AiImageGenerator({super.key});
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fWatch = ref.watch(homeProvider);
    final fRead = ref.read(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Image Generator'),
        actions: [
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  fWatch.isLoading
                      ? Container(
                          alignment: Alignment.center,
                          height: 320,
                          width: 320,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Image.memory(fWatch.imageData!),
                        )
                      : Container(
                          alignment: Alignment.center,
                          height: 320,
                          width: 320,
                          decoration: BoxDecoration(
                              color: const Color(0xff424242),
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 100,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No Image has been generated yet.',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        GoogleFonts.openSans().fontFamily),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 50),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xff424242),
                        borderRadius: BorderRadius.circular(12.0)),
                    child: TextField(
                      controller: textController,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontFamily: GoogleFonts.openSans().fontFamily),
                      cursorColor: Colors.white,
                      maxLines: 5,
                      decoration: InputDecoration(
                          hintText: 'Enter your prompt here...',
                          hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: GoogleFonts.openSans().fontFamily),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12.0)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          fRead.textToImage(textController.text, context);
                          fRead.searchingChange(true);
                          // Save to history
                          await _saveHistory(textController.text, fWatch.imageData!);
                        },
                        child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            width: 160,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.deepPurpleAccent,
                                      Colors.purple
                                    ]),
                                color: Colors.purpleAccent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0))),
                            child: fWatch.isSearching == false
                                ? Text(
                                    'Generate',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily:
                                            GoogleFonts.openSans().fontFamily),
                                  )
                                : const CircularProgressIndicator(
                                    color: Colors.white,
                                  )),
                      ),
                      GestureDetector(
                        onTap: () {
                          fRead.loadingChange(false);
                          textController.clear();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          width: 160,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.pink, Colors.red]),
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.openSans().fontFamily),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveHistory(String prompt, Uint8List imageData) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('image_generator_history');
    List<Map<String, dynamic>> history = [];

    if (historyJson != null) {
      history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yy - HH:mm:ss').format(now);

    history.add({
      'date': formattedDate,
      'prompt': prompt,
      'image': base64Encode(imageData),
    });

    final updatedHistoryJson = jsonEncode(history);
    await prefs.setString('image_generator_history', updatedHistoryJson);
  }
}

