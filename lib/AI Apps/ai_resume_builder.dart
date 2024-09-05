import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_multitasker/api.dart'; // Make sure you have a proper API handling mechanism.

class ResumeFormScreen extends StatefulWidget {
  const ResumeFormScreen({super.key});

  @override
  _ResumeFormScreenState createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  bool _isLoading = false;
  String _generatedResume = "";

  // Initialize Gemini API Model
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey); // Ensure you have your API key
  }

  Future<void> _generateResume() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final name = _nameController.text;
      final skills = _skillsController.text;
      final experience = _experienceController.text;
      final education = _educationController.text;

      final resumeData = await _callGeminiAPI(
        name: name,
        skills: skills,
        experience: experience,
        education: education,
      );

      setState(() {
        _generatedResume = resumeData;
        _isLoading = false;
      });

      // Navigate to the resume result screen to display the result
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResumeResultScreen(resume: _generatedResume),
        ),
      );
    }
  }

  Future<String> _callGeminiAPI({
    required String name,
    required String skills,
    required String experience,
    required String education,
  }) async {
    final message = """
    Name: $name
    Skills: $skills
    Experience: $experience
    Education: $education
    Please generate a professional resume based on the above details.
    """;

    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      return response.text ?? "Failed to generate resume.";
    } catch (e) {
      return 'Error generating resume: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Resume Builder')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(labelText: 'Skills'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your skills';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(labelText: 'Experience'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your experience';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _educationController,
                  decoration: const InputDecoration(labelText: 'Education'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your education';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _generateResume,
                        child: const Text('Generate Resume'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResumeResultScreen extends StatelessWidget {
  final String resume;

  const ResumeResultScreen({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Resume')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            resume,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
