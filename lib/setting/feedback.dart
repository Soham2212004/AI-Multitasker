import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatelessWidget {
  final TextEditingController _feedbackController = TextEditingController();
  final String phoneNumber = '9723441407'; // The number to send feedback to

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSection(),
          SizedBox(height: 16.0),
          _buildFeedbackTextBox(),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Text(
            'Rating:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 16.0),
          _buildStarRating(),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: 32.0,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        // Handle rating update here
      },
    );
  }

  Widget _buildFeedbackTextBox() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _feedbackController, // Connect the controller
              maxLines: 5,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Write your feedback',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your feedback';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _sendFeedback();
                },
                child: Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendFeedback() async {
    final feedbackText = _feedbackController.text;
    final uri = 'sms:$phoneNumber?body=${Uri.encodeComponent(feedbackText)}';

    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // Handle the error when the messaging app cannot be launched
      print('Could not launch $uri');
    }
  }
}
