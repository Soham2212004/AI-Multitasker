import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ai_multitasker/api.dart';
import 'package:open_file/open_file.dart';

class AIStudyBuddy extends StatefulWidget {
  @override
  _AIStudyBuddyState createState() => _AIStudyBuddyState();
}

class _AIStudyBuddyState extends State<AIStudyBuddy> {
  final _nameController = TextEditingController();
  final _topicController = TextEditingController();
  final _difficultyLevelController = TextEditingController();
  final _typeController = TextEditingController();
  final _numberOfQuestionsController = TextEditingController();

  void _navigateToQuestionsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          name: _nameController.text,
          topic: _topicController.text,
          difficultyLevel: _difficultyLevelController.text,
          type: _typeController.text,
          numberOfQuestions:
              int.tryParse(_numberOfQuestionsController.text) ?? 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Study Buddy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(labelText: 'Topic Name'),
            ),
            TextField(
              controller: _difficultyLevelController,
              decoration: InputDecoration(labelText: 'Difficulty Level'),
            ),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Question Type (MCQ / Long Questions)',
                hintText: 'e.g. MCQ',
              ),
            ),
            TextField(
              controller: _numberOfQuestionsController,
              decoration: InputDecoration(
                labelText: 'Number of Questions',
                hintText: 'e.g. 5',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToQuestionsScreen,
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionsScreen extends StatefulWidget {
  final String name;
  final String topic;
  final String difficultyLevel;
  final String type;
  final int numberOfQuestions;

  QuestionsScreen({
    required this.name,
    required this.topic,
    required this.difficultyLevel,
    required this.type,
    required this.numberOfQuestions,
  });

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);

  bool _isGeneratingQuestions = false;
  bool _isSubmittingAnswers = false;
  List<Map<String, String>> _questions = [];
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  Future<void> _generateQuestions() async {
    final prompt =
        "Hello my name is ${widget.name}. I am studying ${widget.topic} at a ${widget.difficultyLevel} level. Please generate ${widget.numberOfQuestions} ${widget.type} questions for this topic. The response should start with Question-1, and each question should be on a new line without additional spacing, and if it is mcq then please make sure that all mcq's are in the same line as question like this : Question-1 gvqhjwdvwhadvwhjdbawhdvawhdvsahcvahdvadbawnhdvawdbawdhvaw. a) hvav b) awhdv c) wdf d) defh";

    setState(() {
      _isGeneratingQuestions = true;
    });

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      var questionsText = response.text ?? '';

      // Process the response into a list of questions
      questionsText = questionsText.replaceAll('**', '');

      final questions = questionsText
          .split('\n')
          .where((line) => line.isNotEmpty)
          .map((q) => {'question': q, 'answer': ''})
          .toList();

      setState(() {
        _questions = questions;
        _controllers = List.generate(
          _questions.length,
          (index) => TextEditingController(),
        );
        _isGeneratingQuestions = false;
      });
    } catch (e) {
      setState(() {
        _isGeneratingQuestions = false;
      });
      // Handle error
    }
  }

  Future<void> _submitAnswers() async {
    final answers = _questions
        .map((q) => 'Q. ${q['question']}\nA. ${q['answer']}')
        .join('\n\n');

    final prompt =
        'Are these answers correct? If not, please provide the correct answers along with the questions.\n\n$answers';

    setState(() {
      _isSubmittingAnswers = true;
    });

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      var feedback = response.text ?? '';

      // Clean up the response text
      feedback = feedback.replaceAll('**', '');

      // Navigate to FeedbackScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackScreen(
            feedback: feedback,
            questions: _questions,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmittingAnswers = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isGeneratingQuestions)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Generating your quiz questions...'),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${index + 1}. ${question['question']}'),
                        TextField(
                          controller: _controllers[index],
                          onChanged: (value) {
                            setState(() {
                              _questions[index]['answer'] = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Your Answer',
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            if (!_isGeneratingQuestions)
              _isSubmittingAnswers
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Submitting your answers...'),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _questions
                              .every((q) => q['answer']?.isNotEmpty ?? false)
                          ? _submitAnswers
                          : null,
                      child: Text('Submit Answers'),
                    ),
          ],
        ),
      ),
    );
  }
}

class FeedbackScreen extends StatelessWidget {
  final String feedback;
  final List<Map<String, String>> questions;

  FeedbackScreen({
    required this.feedback,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final cleanedFeedback = feedback.replaceAll('**', '');

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _generatePdf(questions);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feedback:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(cleanedFeedback),
            SizedBox(height: 20),
            Text(
              'Questions and Answers:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            ...questions.map((question) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Q. ${question['question']}'),
                  Text('A. ${question['answer']}'),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf(List<Map<String, String>> questions) async {
    final pdf = pw.Document();

    // Load fonts
    final regularFont =
        await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final boldFont = await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");

    final ttfRegular = pw.Font.ttf(regularFont);
    final ttfBold = pw.Font.ttf(boldFont);

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(
              'Feedback:',
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 18,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              width: 500, // adjust the width as needed
              child: pw.Paragraph(
                text: feedback,
                style: pw.TextStyle(font: ttfRegular),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Questions and Answers:',
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 18,
              ),
            ),
            pw.SizedBox(height: 10),
            ...questions.map((question) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Paragraph(
                    text: 'Q. ${question['question']}',
                    style: pw.TextStyle(font: ttfRegular),
                  ),
                  pw.Paragraph(
                    text: 'A. ${question['answer']}',
                    style: pw.TextStyle(font: ttfRegular),
                  ),
                  pw.SizedBox(height: 10),
                ],
              );
            }).toList(),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.only(top: 20),
            child: pw.Column(
              children: [
                pw.Divider(
                  thickness: 1, // adjust the thickness as needed
                  color: PdfColors.grey700, // adjust the color as needed
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'This PDF is generated by AI Study Buddy App Developed By Soham Soni',
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }));

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/questions_and_answers.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the generated PDF immediately
    await OpenFile.open(file.path);
  }
}
