import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pdf/pdf.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ai_multitasker/api.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class JobInterviewCoach extends StatefulWidget {
  @override
  _JobInterviewCoachState createState() => _JobInterviewCoachState();
}

class _JobInterviewCoachState extends State<JobInterviewCoach> {
  final _nameController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _jobRoleController = TextEditingController();
  final _questionTypeController = TextEditingController();
  final _numberOfQuestionsController = TextEditingController();

  void _navigateToQuestionsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          name: _nameController.text,
          fieldOfStudy: _fieldOfStudyController.text,
          jobRole: _jobRoleController.text,
          questionType: _questionTypeController.text,
          numberOfQuestions: int.tryParse(_numberOfQuestionsController.text) ?? 5, // Default to 5 if input is invalid
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Job Interview Coach'),
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
              controller: _fieldOfStudyController,
              decoration: InputDecoration(labelText: 'Field Of Study'),
            ),
            TextField(
              controller: _jobRoleController,
              decoration: InputDecoration(labelText: 'Job Role'),
            ),
            TextField(
              controller: _questionTypeController,
              decoration: InputDecoration(
                labelText: 'Question Type (Technical / Non Technical)',
                hintText: 'e.g. Technical',
              ),
            ),
            TextField(
              controller: _numberOfQuestionsController,
              decoration: InputDecoration(
                labelText: 'Number Of Questions',
                hintText: 'e.g. 5',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToQuestionsScreen,
              child: Text('Generate Questions'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionsScreen extends StatefulWidget {
  final String name;
  final String fieldOfStudy;
  final String jobRole;
  final String questionType;
  final int numberOfQuestions;

  QuestionsScreen({
    required this.name,
    required this.fieldOfStudy,
    required this.jobRole,
    required this.questionType,
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  int? _currentQuestionIndex;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _generateQuestions();
  }

  @override
  void dispose() {
    // Dispose all the TextEditingControllers when the widget is disposed
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeSpeechRecognition() async {
    bool available = await _speech.initialize();
    if (!available) {
      print('Speech recognition not available');
    }
  }

  Future<void> _generateQuestions() async {
    final prompt =
        "Hello my name is ${widget.name}, I am studying in ${widget.fieldOfStudy}, and I want to apply for a ${widget.jobRole} job role, so please provide me ${widget.numberOfQuestions} ${widget.questionType} questions for this job role, Your Responce should starts with Question-1 , and the each question does not conatin any spacing between lines";

    setState(() {
      _isGeneratingQuestions = true;
    });

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      var questionsText = response.text ?? '';

      // Remove '**' from the response text
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
        .map((q) => 'Q.\n${q['question']}\nA.\n${q['answer']}')
        .join('\n\n');

    final prompt = 'Are the answers correct? If not, please provide correct answers along with the questions. like Q.  A. ';

    setState(() {
      _isSubmittingAnswers = true;
    });

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      var feedback = response.text ?? '';

      // Remove '**' from the feedback text
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

  void _startListening(int index) async {
    if (_isListening) {
      return; // Ignore if already listening
    }

    setState(() {
      _isListening = true;
      _currentQuestionIndex = index;
    });

    _speech.listen(onResult: (result) {
      if (result.hasConfidenceRating && result.confidence > 0) {
        setState(() {
          _questions[index]['answer'] = result.recognizedWords;
          _controllers[index].text = result.recognizedWords;
          _isListening = false;
          _speech.stop();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Job Interview Coach'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isGeneratingQuestions)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Wait, your questions are being generated...'),
                ],
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
                          decoration: InputDecoration(labelText: 'Answer'),
                          enabled: !_isListening || _currentQuestionIndex != index,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isListening
                              ? null
                              : () => _startListening(index),
                          child: Icon(Icons.mic),
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            if (!_isGeneratingQuestions)
              _isSubmittingAnswers
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Submitting your answers...'),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _questions.every((q) => q['answer']?.isNotEmpty ?? false)
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
              width: 500,
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
                  thickness: 1,
                  color: PdfColors.grey700,
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'This PDF is generated by AI Job Interview Coach App Developed By Soham Soni',
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