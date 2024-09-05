import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart'; // Import for Clipboard

class TextExtractionScreen extends StatefulWidget {
  const TextExtractionScreen({super.key});

  @override
  State<TextExtractionScreen> createState() => _TextExtractionScreenState();
}

class _TextExtractionScreenState extends State<TextExtractionScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedMedia;
  String _extractedText = '';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedMedia = file;
      });
      _extractText(file);
    }
  }

  Future<void> _extractText(File file) async {
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    final inputImage = InputImage.fromFile(file);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        _extractedText = recognizedText.text;
      });
    } catch (e) {
      print('Error extracting text: $e');
    } finally {
      textRecognizer.close();
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _extractedText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text Recognition"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              if (_selectedMedia != null) Image.file(_selectedMedia!),
              const SizedBox(height: 20),
              const Text(
                'Extracted Text:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SelectableText(
                _extractedText,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _copyToClipboard,
                child: const Text('Copy to Clipboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:flutter/services.dart'; // Import for Clipboard
// import 'package:google_generative_ai/google_generative_ai.dart'; // Gemini API package

// class TextExtractionScreen extends StatefulWidget {
//   const TextExtractionScreen({super.key});

//   @override
//   State<TextExtractionScreen> createState() => _TextExtractionScreenState();
// }

// class _TextExtractionScreenState extends State<TextExtractionScreen> {
//   final ImagePicker _picker = ImagePicker();
//   File? _selectedMedia;
//   String _extractedText = '';
//   String _geminiResponse = '';
//   bool _isLoading = false;

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       final file = File(pickedFile.path);
//       setState(() {
//         _selectedMedia = file;
//       });
//       _extractText(file);
//     }
//   }

//   Future<void> _extractText(File file) async {
//     final textRecognizer = TextRecognizer(
//       script: TextRecognitionScript.latin,
//     );
//     final inputImage = InputImage.fromFile(file);

//     try {
//       final recognizedText = await textRecognizer.processImage(inputImage);
//       setState(() {
//         _extractedText = recognizedText.text;
//       });
//       // After extracting the text, send it to Gemini API
//       _sendToGeminiAPI(_extractedText);
//     } catch (e) {
//       print('Error extracting text: $e');
//     } finally {
//       textRecognizer.close();
//     }
//   }

//   Future<void> _sendToGeminiAPI(String extractedText) async {
//     setState(() {
//       _isLoading = true;
//     });

//     final message =
//         "This text is extracted from image, please correct the text if something is missing in it and make this in format:\n\n$extractedText";

//     try {
//       final GenerativeModel model =
//           GenerativeModel(model: 'gemini-pro', apiKey: 'your-gemini-api-key'); // Replace with your API key

//       final response = await model.generateContent([Content.text(message)]);

//       setState(() {
//         _geminiResponse = response.text ?? 'No response from Gemini API';
//       });
//     } catch (e) {
//       print('Error sending text to Gemini API: $e');
//       setState(() {
//         _geminiResponse = 'Failed to process the text.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _copyToClipboard() {
//     Clipboard.setData(ClipboardData(text: _geminiResponse)).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Response copied to clipboard')),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Text Recognition & Correction"),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 child: const Text('Pick Image'),
//               ),
//               const SizedBox(height: 20),
//               if (_selectedMedia != null) Image.file(_selectedMedia!),
//               const SizedBox(height: 20),
//               const Text(
//                 'Extracted Text:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               SelectableText(
//                 _extractedText,
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 20),
//               if (_isLoading)
//                 const CircularProgressIndicator()
//               else ...[
//                 const Text(
//                   'Corrected & Formatted Text from Gemini:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 SelectableText(
//                   _geminiResponse,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _copyToClipboard,
//                   child: const Text('Copy Response to Clipboard'),
//                 ),
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
