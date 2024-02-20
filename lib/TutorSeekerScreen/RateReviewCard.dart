import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateReviewCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;

  const RateReviewCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.rating,
    required this.fees,
    required this.tutorPostId,
  }) : super(key: key);

  @override
  _RateReviewCardState createState() => _RateReviewCardState();
}

class _RateReviewCardState extends State<RateReviewCard> {
  double _userRating = 0;
  String _reviewText = '';

  Future<void> _submitRatingAndReview() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // Create a document reference for the tutor's ratings and reviews
    DocumentReference tutorRef = FirebaseFirestore.instance.collection('Tutor').doc(widget.tutorId);

    // Add the user's rating and review to the tutor's document
    await tutorRef.collection('RatingsAndReviews').add({
      'TutorSeekerId': user!.uid,
      'Rating': _userRating,
      'Review': _reviewText,
      'Timestamp': Timestamp.now(),
    });

    // Close the dialog
    Navigator.pop(context);

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rating and review submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 207, 240, 208),
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.imageURL),
              ),
              title: Text(widget.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.subject, style: TextStyle(color: Colors.black)),
              trailing: Text(
                'Paid',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoWithIcon(Icons.star, 'Rating: ${widget.rating.toStringAsFixed(1)}'),
                  _buildInfoWithIcon(Icons.attach_money, 'RM ${widget.fees}'),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.info_outline, size: 16.0),
                  label: Text('Details'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TutorDetailPage(
                          tutorId: widget.tutorId,
                          tutorPostId: widget.tutorPostId,
                          imageURL: widget.imageURL,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.star_rate, size: 16.0),
                  label: Text('Rate & Review'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Rate & Review'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RatingBar.builder(
                                initialRating: _userRating,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 40.0,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (value) {
                                  setState(() {
                                    _userRating = value;
                                  });
                                },
                              ),
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _reviewText = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Write your review here...',
                                ),
                                maxLines: null,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _submitRatingAndReview();
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoWithIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: Colors.black),
        SizedBox(width: 4.0),
        Text(text, style: TextStyle(color: Colors.black)),
      ],
    );
  }
}
