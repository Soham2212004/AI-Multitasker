import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_multitasker/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart'; // Import open_file package

class WorkoutPlannerScreen extends StatefulWidget {
  @override
  _WorkoutPlannerScreenState createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _fitnessGoalsController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _workoutDurationController = TextEditingController();

  String _workoutIntensity = 'Moderate';
  bool _isLoading = false;

  void _submitForm() {
    final name = _nameController.text;
    final height = _heightController.text;
    final weight = _weightController.text;
    final age = _ageController.text;
    final fitnessGoals = _fitnessGoalsController.text;
    final targetWeight = _targetWeightController.text;
    final workoutDuration = _workoutDurationController.text;

    final message =
        "Hey, my name is $name, my height is $height cm, I weigh $weight kg, and I'm $age years old. My fitness goals are: $fitnessGoals. My target weight is $targetWeight kg, and I can dedicate $workoutDuration hours per week for workout. Please suggest a workout plan with $_workoutIntensity intensity.";

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WorkoutPlanResultScreen(
        message: message,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Workout Coach'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _fitnessGoalsController,
              decoration: InputDecoration(
                labelText: 'Fitness Goals',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _workoutIntensity,
              items: ['Low', 'Moderate', 'High']
                  .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _workoutIntensity = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Workout Intensity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _targetWeightController,
              decoration: InputDecoration(
                labelText: 'Target Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _workoutDurationController,
              decoration: InputDecoration(
                labelText: 'Workout Duration (hours/week)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutPlanResultScreen extends StatefulWidget {
  final String message;

  WorkoutPlanResultScreen({required this.message});

  @override
  _WorkoutPlanResultScreenState createState() => _WorkoutPlanResultScreenState();
}

class _WorkoutPlanResultScreenState extends State<WorkoutPlanResultScreen> {
  late final GenerativeModel _model;
  String _responseText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
        model: 'gemini-pro', apiKey: geminiApiKey); // Replace with your API key
    _fetchWorkoutPlan();
  }

  Future<void> _fetchWorkoutPlan() async {
    try {
      final content = [Content.text(widget.message)];
      final response = await _model.generateContent(content);

      setState(() {
        _responseText = response.text?.replaceAll(RegExp(r'\*'), '') ??
            'No response received.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _responseText = 'Error generating workout plan: $e';
        _isLoading = false;
      });
    }
  }

Future<void> _generatePdf() async {
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
            'Your Workout Plan',
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 18,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Paragraph(
            text: _responseText,
            style: pw.TextStyle(font: ttfRegular),
          ),
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
              pw.Text(
                'Generated by AI Workout Coach App',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 12,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        );
      }));

  // Save and open the PDF
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/workout_plan.pdf");
  await file.writeAsBytes(await pdf.save());

  // Open the PDF using the open_file package
  await OpenFile.open(file.path);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Workout Plan'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _isLoading ? null : _generatePdf,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Text(
                _responseText,
                style: TextStyle(fontSize: 16.0),
              ),
      ),
    );
  }
}
