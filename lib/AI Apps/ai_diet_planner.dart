import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_multitasker/api.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DietPlannerScreen extends StatefulWidget {
  @override
  _DietPlannerScreenState createState() => _DietPlannerScreenState();
}

class _DietPlannerScreenState extends State<DietPlannerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _badHabitsController = TextEditingController();
  final TextEditingController _targetweightcontroller = TextEditingController();
  final TextEditingController _timecontrller = TextEditingController();

  String _dietMode = 'Easy';
  String _badHabitDropdownValue = 'No'; // Default value for the dropdown
  bool _showBadHabitField = false; // To show or hide the bad habit field
  bool _isLoading = false;

  void _submitForm() {
    final name = _nameController.text;
    final height = _heightController.text;
    final weight = _weightController.text;
    final age = _ageController.text;
    final badHabits = _badHabitDropdownValue == 'Yes'
        ? _badHabitsController.text
        : 'No bad habits';
    final targetweight = _targetweightcontroller.text;
    final time = _timecontrller.text;

    final message =
        "Hey my name is $name, weight $weight, height $height, age $age, I have $badHabits, and my target weight is $targetweight. Can you please make a diet plan for $time week(s)? The mode should be $_dietMode. Your response should start with 'Goal:'";

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DietPlanResultScreen(
        message: message,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Diet Planner'),
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
            DropdownButtonFormField<String>(
              value: _badHabitDropdownValue,
              items: ['Yes', 'No'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _badHabitDropdownValue = value!;
                  _showBadHabitField = value == 'Yes';
                });
              },
              decoration: InputDecoration(
                labelText: 'Do you have bad habits?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            if (_showBadHabitField)
              TextField(
                controller: _badHabitsController,
                decoration: InputDecoration(
                  labelText: 'What Bad Habit?',
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _dietMode,
              items: ['Easy', 'Medium', 'Hard']
                  .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _dietMode = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Diet Mode',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _targetweightcontroller,
              decoration: InputDecoration(
                labelText: 'Target Weight',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _timecontrller,
              decoration: InputDecoration(
                labelText: 'Time (In Weeks)',
                border: OutlineInputBorder(),
              ),
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

class DietPlanResultScreen extends StatefulWidget {
  final String message;

  DietPlanResultScreen({required this.message});

  @override
  _DietPlanResultScreenState createState() => _DietPlanResultScreenState();
}

class _DietPlanResultScreenState extends State<DietPlanResultScreen> {
  late final GenerativeModel _model;
  String _responseText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
        model: 'gemini-pro', apiKey: geminiApiKey); // Replace with your API key
    _fetchDietPlan();
  }

  Future<void> _fetchDietPlan() async {
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
        _responseText = 'Error generating diet plan: $e';
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
              'Your Diet Plan',
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
                  thickness: 1, // adjust the thickness as needed
                  color: PdfColors.grey700, // adjust the color as needed
                ),
                pw.Text(
                  'Generated by AI Diet Planner App',
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

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/diet_plan.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the generated PDF immediately
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Diet Plan'),
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
