import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';



class VoiceNoteScreen extends StatefulWidget {
  @override
  _VoiceNoteScreenState createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcribedText = '';
  String _correctedText = '';
  bool _showGeneratePdfButton = false;

  static const apiKey = "";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _transcribedText = val.recognizedWords;
          _noteController.text = _transcribedText;
        }),
      );
    }
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _processText() async {
    final combinedText = _noteController.text;

    final message =
        "Convert the text to capital first letter of each word and correct the grammatical mistakes\n$combinedText";

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _correctedText = response.text ?? "";
      _noteController.text = _correctedText;
      _showGeneratePdfButton = true;
    });
  }

  Future<void> _generatePdf(String _correctedText) async {
    try {
      final pdf = pw.Document();

      final ByteData notepadBytes =
          await rootBundle.load('assets/notepad2.png');
      final Uint8List notepadImage = notepadBytes.buffer.asUint8List();

      final ByteData instagramBytes =
          await rootBundle.load('assets/instagram.png');
      final ByteData githubBytes = await rootBundle.load('assets/github.png');
      final ByteData linkedinBytes =
          await rootBundle.load('assets/linkedin.png');
      final ByteData credlyBytes = await rootBundle.load('assets/credly.png');
      final ByteData facebookBytes =
          await rootBundle.load('assets/facebook.png');
      final ByteData cloudBytes = await rootBundle.load('assets/cloud.png');

      final Uint8List instagramImage = instagramBytes.buffer.asUint8List();
      final Uint8List githubImage = githubBytes.buffer.asUint8List();
      final Uint8List linkedinImage = linkedinBytes.buffer.asUint8List();
      final Uint8List credlyImage = credlyBytes.buffer.asUint8List();
      final Uint8List facebookImage = facebookBytes.buffer.asUint8List();
      final Uint8List cloudImage = cloudBytes.buffer.asUint8List();

      final fontSize = 15.0;
      final lineSpacing = 2.0;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(pw.MemoryImage(notepadImage)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(
                    left: 95.0,
                    // right: 30.0,
                    top: 157.0,
                    bottom: 60.0,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (String line in _correctedText.split('\n'))
                        pw.Text(
                          line,
                          style: pw.TextStyle(
                            fontSize: fontSize,
                            color: PdfColors.black,
                            height: lineSpacing,
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Positioned(
                  bottom: 20.0,
                  left: 123.0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      _buildSocialMediaIcon(instagramImage,
                          'https://www.instagram.com/_soham_soni_'),
                      pw.SizedBox(width: 22),
                      _buildSocialMediaIcon(
                          githubImage, 'https://github.com/Soham2212004'),
                      pw.SizedBox(width: 22),
                      _buildSocialMediaIcon(linkedinImage,
                          'https://www.linkedin.com/in/soham-soni-2342b4239/'),
                      pw.SizedBox(width: 22),
                      _buildSocialMediaIcon(credlyImage,
                          'https://www.credly.com/users/soni-soham'),
                      pw.SizedBox(width: 22),
                      _buildSocialMediaIcon(facebookImage,
                          'https://www.facebook.com/soham.soni.5667/'),
                      pw.SizedBox(width: 22),
                      _buildSocialMediaIcon(cloudImage,
                          'https://www.cloudskillsboost.google/public_profiles/6ebb4fad-af6b-4520-8d47-8a16a23a0df4'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/note_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF generated: ${file.path}'),
      ));

      OpenFile.open(file.path);
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error generating PDF: $e'),
      ));
    }
  }

  pw.Widget _buildSocialMediaIcon(Uint8List imageData, String url) {
    return pw.UrlLink(
      destination: url,
      child: pw.Image(
        pw.MemoryImage(imageData),
        width: 30,
        height: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Note')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.yellow[100],
              child: TextField(
                controller: _noteController,
                maxLines: null,
                decoration: InputDecoration.collapsed(
                  hintText: 'Your notes will appear here...',
                ),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
                enabled: !_isListening,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
              ),
            ],
          ),
          if (!_isListening) ...[
            ElevatedButton(
              onPressed: _processText,
              child: Text('Process Text'),
            ),
          ],
          if (_showGeneratePdfButton) ...[
            ElevatedButton(
              onPressed: () => _generatePdf(_correctedText),
              child: Text('Generate PDF'),
            ),
          ],
        ],
      ),
    );
  }
}
