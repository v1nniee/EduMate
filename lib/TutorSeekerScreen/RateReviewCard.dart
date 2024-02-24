import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateReviewCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String subject;
  final String fees;

  const RateReviewCard({
    Key? key,
    required this.tutorId,
    required this.subject,
    required this.fees,
    required this.tutorPostId,
  }) : super(key: key);

  @override
  _RateReviewCardState createState() => _RateReviewCardState();
}

class _RateReviewCardState extends State<RateReviewCard> {
  double _userRating = 0;
  String _reviewText = '';
  String _tutorName = '';
  String _imageURL = '';
  double _rate = 0.0;
  int _numberOfRating = 0;

  @override
  void initState() {
    super.initState();
    _loadTutorProfile();
  }

  Future<void> _loadTutorProfile() async {
    try {
      DocumentSnapshot tutorSnapshot = await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(widget.tutorId)
          .collection('UserProfile')
          .doc(widget.tutorId)
          .get();

      if (tutorSnapshot.exists) {
        setState(() {
          _tutorName = tutorSnapshot.get('Name');
          _imageURL = tutorSnapshot.get('ImageUrl');
          _rate = tutorSnapshot.get('Rating');
          _numberOfRating = tutorSnapshot.get('NumberOfRating');
        });
      } else {
        setState(() {
          _tutorName = 'Not found';
        });
      }
    } catch (e) {
      print('Error loading tutor name: $e');
    }
  }

  Future<void> _submitRatingAndReview() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case where the user is not logged in
      print("User is not logged in.");
      return;
    }

    DocumentReference tutorRef =
        FirebaseFirestore.instance.collection('Tutor').doc(widget.tutorId);

    // Add the new rating and review to RatingsAndReviews subcollection
    await tutorRef.collection('RatingsAndReviews').add({
      'TutorSeekerId': user.uid,
      'Rating': _userRating,
      'Review': _reviewText,
      'Timestamp': Timestamp.now(),
    });

    // Increment the number of ratings
    _numberOfRating += 1;

    // Calculate the new total rating including the user's rating
    double newTotalRating = (_rate * (_numberOfRating - 1)) + _userRating;

    // Calculate the new average rating
    double newAverageRating = newTotalRating / _numberOfRating;

    // Update the UserProfile data with new values
    await tutorRef.collection('UserProfile').doc(widget.tutorId).update({
      'Rating': newAverageRating,
      'NumberOfRating': _numberOfRating,
    });

    // Optionally, to ensure UI updates with the latest data
    await _loadTutorProfile();

    // Close the dialog if open
    Navigator.pop(context);

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rating and review submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    String ratingText = _numberOfRating != 0
        ? '${_rate.toStringAsFixed(1)} (${_numberOfRating})'
        : "No ratings yet";
    return Card(
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
                backgroundImage: NetworkImage(_imageURL),
              ),
              title: Text(_tutorName,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle:
                  Text(widget.subject, style: TextStyle(color: Colors.black)),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoWithIcon(Icons.star, 'Rating: ${ratingText}'),
                  _buildInfoWithIcon(Icons.attach_money, 'RM ${widget.fees}'),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline, size: 16.0),
                  label: const Text('Details'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TutorDetailPage(
                          tutorId: widget.tutorId,
                          tutorPostId: widget.tutorPostId,
                          imageURL: _imageURL,
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
                  label: const Text('Rate & Review'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Rate & Review'),
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
                                itemBuilder: (context, _) => const Icon(
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
                                decoration: const InputDecoration(
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
