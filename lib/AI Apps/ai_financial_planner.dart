import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'dart:async';
import 'package:ai_multitasker/api.dart';


class AiFinancialPlannerScreen extends StatefulWidget {
  @override
  _AiFinancialPlannerScreenState createState() => _AiFinancialPlannerScreenState();
}

class _AiFinancialPlannerScreenState extends State<AiFinancialPlannerScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _monthlySalaryController = TextEditingController();
  final _monthlySavingsController = TextEditingController();
  final _futurePlansController = TextEditingController();
  final _retirementAgeController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ai Financial Planner'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _monthlySalaryController,
                  decoration: InputDecoration(labelText: 'Monthly Salary (₹)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _monthlySavingsController,
                  decoration: InputDecoration(labelText: 'Monthly Savings (₹)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _futurePlansController,
                  decoration: InputDecoration(labelText: 'Future Plans'),
                ),
                TextField(
                  controller: _retirementAgeController,
                  decoration: InputDecoration(labelText: 'Retirement Age'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitAiFinancialPlannerInfo,
                  child: Text('Submit'),
                ),
                _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('Making a Financial Plan For You...'),
                          ],
                        ),
                      )
                    : Container(),
              ],
            )),
      ),
    );
  }

  void _submitAiFinancialPlannerInfo() async {
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;
    final age = int.parse(_ageController.text);
    final monthlySalary = int.parse(_monthlySalaryController.text);
    final monthlySavings = int.parse(_monthlySavingsController.text);
    final futurePlans = _futurePlansController.text;
    final retirementAge = int.parse(_retirementAgeController.text);

    final prompt =
        "Hello my name is $name and my current age is $age, I earn $monthlySalary ₹ and my monthly savings is $monthlySavings ₹, my future plans are $futurePlans, and I want to retire at the age of $retirementAge. So can you make me some finance plan to satisfy my needs. Your answer should be starts with plan-1 and so on";

    final response = await _sendRequestToGeminiApi(prompt);

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponseScreen(response: response),
      ),
    );
  }

  Future<String> _sendRequestToGeminiApi(String prompt) async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);

    final response = await model.generateContent([Content.text(prompt)]);

    return response.text ?? '';
  }
}


class ResponseScreen extends StatelessWidget {
  final String response;

  ResponseScreen({required this.response});

  @override
  Widget build(BuildContext context) {
    // Clean up the response by removing '**' characters
    final cleanedResponse = response.replaceAll(RegExp(r'\*\*'), '');

    // Split the cleaned response into individual plans
    final plans = _splitIntoPlans(cleanedResponse);

    return Scaffold(
      appBar: AppBar(
        title: Text('Response'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: plans.map((plan) {
            final planNumber = _getPlanNumber(plan);
            final color = _getPlanColor(planNumber);

            return Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                plan.trim(),
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Split the response into plans based on "plan-" prefixes
  List<String> _splitIntoPlans(String response) {
    // Split the response at each "plan-" and include the part after each split
    final parts = response.split(RegExp(r'(?=plan-\d+)'));
    // Filter out empty strings and return the result
    return parts.where((part) => part.trim().isNotEmpty).toList();
  }

  // Extract the plan number from the text
  int _getPlanNumber(String plan) {
    final match = RegExp(r'plan-(\d+)').firstMatch(plan);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  // Return a color based on the plan number
  Color _getPlanColor(int planNumber) {
    switch (planNumber) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.purple;
      // Add more colors as needed
      default:
        return Colors.transparent;
    }
  }
}