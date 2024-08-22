import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';



class FeedbackScreen extends StatelessWidget {
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
    // You can use a package like flutter_rating_bar for star ratings
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
              onSaved: (value) {
                // Save feedback here
              },
            ),
            SizedBox(
                height: 16.0), // Add space between TextFormField and button
            Center(
              // Center the button horizontally
              child: ElevatedButton(
                onPressed: () {
                  // Implement save functionality here
                },
                child: Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}