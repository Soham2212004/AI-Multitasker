import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';




class Assistant extends StatefulWidget {
  @override
  _AssistantState createState() => _AssistantState();
}

class _AssistantState extends State<Assistant> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _callName = '';
  bool _isLoading = false;
  String _messageContent = '';
  bool _awaitingMessage = false;
  Contact? _contactForMessage;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.75);
    } catch (e) {
      print('Failed to initialize TTS: $e');
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  Future<List<Contact>> _fetchContacts() async {
    if (!(await Permission.contacts.request().isGranted)) {
      return [];
    }
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }

  Future<void> _makeCall(Contact contact) async {
    setState(() {
      _isLoading = true;
    });

    if (await Permission.phone.request().isGranted) {
      if (contact.phones!.isNotEmpty) {
        String phoneNumber = contact.phones!.first.value!;
        const platform = MethodChannel('com.example.direct_call/call');
        try {
          await platform.invokeMethod('makeCall', {'number': phoneNumber});
        } catch (e) {
          print('Error making call: $e');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error Making Call'),
                content: const Text('An error occurred while making the call.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('No Phone Number'),
              content: Text('This contact does not have a phone number.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: null,
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Phone permission not granted');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendMessage(Contact contact, String message) async {
    if (contact.phones!.isNotEmpty) {
      String phoneNumber = contact.phones!.first.value!;
      final Uri whatsappUri = Uri(
        scheme: 'https',
        host: 'api.whatsapp.com',
        path: 'send',
        queryParameters: {
          'phone': phoneNumber,
          'text': message,
        },
      );

      if (await canLaunch(whatsappUri.toString())) {
        await launch(whatsappUri.toString());
      } else {
        print('Could not launch WhatsApp');
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('No Phone Number'),
            content: Text('This contact does not have a phone number.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: null,
              ),
            ],
          );
        },
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            if (!_awaitingMessage) {
              _callName = val.recognizedWords.trim();
              if (_callName.toLowerCase() == 'hey dev wake up') {
                await _speak('Yes, sir. How can I assist you?');
              } else if (_callName.toLowerCase().startsWith('call ')) {
                _callName = _callName.replaceAll('call ', '').trim();
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _isListening = false;
                  _speech.stop();
                  await _speak(
                      'Please wait, sir. I\'m making a call to $_callName.');
                  _searchAndCall();
                }
              } else if (_callName.toLowerCase().startsWith('message ')) {
                _callName = _callName.replaceAll('message ', '').trim();
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _isListening = false;
                  _speech.stop();
                  await _speak(
                      'Please wait. I\'m preparing a message through WhatsApp.');
                  _searchAndPrepareMessage();
                }
              }
            } else {
              _messageContent = val.recognizedWords.trim();
              if (val.hasConfidenceRating && val.confidence > 0) {
                _isListening = false;
                _speech.stop();
                _sendMessageToContact();
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _searchAndCall() async {
    setState(() {
      _isLoading = true;
    });

    List<Contact> contacts = await _fetchContacts();
    Contact? selectedContact;
    for (Contact contact in contacts) {
      String givenName = contact.givenName?.trim().toLowerCase() ?? '';
      String familyName = contact.familyName?.trim().toLowerCase() ?? '';
      String displayName = contact.displayName?.trim().toLowerCase() ?? '';
      if (givenName.contains(_callName.toLowerCase()) ||
          familyName.contains(_callName.toLowerCase()) ||
          displayName.contains(_callName.toLowerCase())) {
        selectedContact = contact;
        break;
      }
    }

    if (selectedContact != null) {
      await _makeCall(selectedContact);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contact Not Found'),
            content: Text('No contact found with the name "$_callName".'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _searchAndPrepareMessage() async {
    setState(() {
      _isLoading = true;
    });

    List<Contact> contacts = await _fetchContacts();
    Contact? selectedContact;
    for (Contact contact in contacts) {
      String givenName = contact.givenName?.trim().toLowerCase() ?? '';
      String familyName = contact.familyName?.trim().toLowerCase() ?? '';
      String displayName = contact.displayName?.trim().toLowerCase() ?? '';
      if (givenName.contains(_callName.toLowerCase()) ||
          familyName.contains(_callName.toLowerCase()) ||
          displayName.contains(_callName.toLowerCase())) {
        selectedContact = contact;
        break;
      }
    }

    if (selectedContact != null) {
      _contactForMessage = selectedContact;
      setState(() {
        _isLoading = false;
        _awaitingMessage = true;
      });
      _listenForMessage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contact Not Found'),
            content: Text('No contact found with the name "$_callName".'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenForMessage() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) async {
          _messageContent = val.recognizedWords.trim();
          if (val.hasConfidenceRating && val.confidence > 0) {
            _isListening = false;
            _speech.stop();
            _sendMessageToContact();
          }
        },
      );
    }
  }

  Future<void> _sendMessageToContact() async {
    if (_contactForMessage != null) {
      await _sendMessage(_contactForMessage!, _messageContent);
      await _speak(
          'Your message has been sent to ${_contactForMessage!.displayName}.');
    }
    setState(() {
      _awaitingMessage = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Based Chatbot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (!_isListening) {
                  setState(() => _isLoading = true);
                  await _speak('Welcome! Click again to speak.');
                  _listen();
                }
              },
              child: Text(_isListening ? 'Listening...' : 'Press to Speak'),
            ),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}
