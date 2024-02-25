import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorCard.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerFindTutor.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerPayment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';

class ApplicationStatusTutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;
  final int numberOfRating;
  final String DocumentUrl;
  const ApplicationStatusTutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.rating,
    required this.fees,
    required this.numberOfRating,
    required this.tutorPostId,
    required this.DocumentUrl,
  }) : super(key: key);

  @override
  _ApplicationStatusTutorCardState createState() =>
      _ApplicationStatusTutorCardState();
}

class _ApplicationStatusTutorCardState
    extends State<ApplicationStatusTutorCard> {
  bool isFavorite = false;
  String _applicationStatus = 'pending';
  bool isApplicationCanceled = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadApplicationStatus();
  }

  Future<void> _loadApplicationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Fetch the status of the tutor post application
      DocumentSnapshot tutorPostApplicationSnapshot = await FirebaseFirestore
          .instance
          .collection('Tutor Seeker')
          .doc(user?.uid)
          .collection('ApplicationRequest')
          .doc('${widget.tutorId}_${widget.tutorPostId}')
          .get();

      if (tutorPostApplicationSnapshot.exists) {
        setState(() {
          _applicationStatus = tutorPostApplicationSnapshot.get('Status');
        });
      } else {
        setState(() {
          _applicationStatus = 'Not found';
        });
      }
    } catch (e) {
      print('Error loading application status: $e');
    }
  }

  Future<void> _cancelApplication() async {
    setState(() {
      _isCancelling = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the TutorApplication document
      DocumentReference tutorApplicationDocRef = FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(user.uid)
          .collection('ApplicationRequest')
          .doc('${widget.tutorId}_${widget.tutorPostId}');

      DocumentReference tutorApplicationfromTSDocRef = FirebaseFirestore
          .instance
          .collection('Tutor')
          .doc(widget.tutorId)
          .collection('ApplicationRequest')
          .doc('${user.uid}_${widget.tutorPostId}');

      try {
        // Check if the specific TutorApplication document exists and delete if it does
        DocumentSnapshot tutorApplicationSnapshot =
            await tutorApplicationDocRef.get();
        if (tutorApplicationSnapshot.exists) {
          await tutorApplicationDocRef.delete();
        }

        DocumentSnapshot tutorApplicationfromTSSnapshot =
            await tutorApplicationfromTSDocRef.get();
        if (tutorApplicationfromTSSnapshot.exists) {
          await tutorApplicationfromTSDocRef.delete();
        }
        setState(() {
          _isCancelling = false;
        });

        _showDialog('Cancelled', 'Application cancelled successfully');
        _loadApplicationStatus();
        setState(() {
          isApplicationCanceled = true;
        });
      } catch (e) {
        _showDialog('Error', 'Error cancelling application: $e');
        setState(() {
          _isCancelling = false;
        });
      }
    } else {
      _showDialog('Error', 'You are not logged in');
      setState(() {
        _isCancelling = false;
      });
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelled() {
    setState(() {
      isApplicationCanceled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String ratingText = widget.numberOfRating != 0
        ? '${widget.rating.toStringAsFixed(1)} (${widget.numberOfRating})'
        : "No ratings yet";
    Color cardColor;
    String applicationStatusText;

    switch (_applicationStatus) {
      case 'rejected':
        cardColor = Colors.red;
        applicationStatusText = 'Rejected';
        break;
      case 'pending':
        cardColor = Colors.orange;
        applicationStatusText = 'Pending';
        break;
      case 'accepted':
        cardColor = Colors.green;
        applicationStatusText = 'Accepted';
        break;
      default:
        cardColor = Colors.grey;
        applicationStatusText = '';
    }

    double topPadding = 8.0;

    return Card(
      margin: EdgeInsets.all(4.0),
      elevation: 2.0,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.imageURL),
              ),
              title: Text(
                widget.name,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(widget.subject),
              trailing: Text(
                applicationStatusText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoWithIcon(Icons.star, 'Rating: ${ratingText}'),
                  _buildInfoWithIcon(Icons.monetization_on, 'RM${widget.fees}'),
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
                          DocumentUrl: widget.DocumentUrl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
                if (_applicationStatus == "accepted")
                  ElevatedButton.icon(
                    icon: Icon(Icons.payment, size: 16.0),
                    label: Text('Pay Now'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TutorSeekerPayment()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  )
                else
                  _isCancelling
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : ElevatedButton.icon(
                          icon: Icon(
                              isApplicationCanceled
                                  ? Icons.cancel_sharp
                                  : Icons.cancel,
                              size: 16.0),
                          label: Text(isApplicationCanceled
                              ? 'Application Cancelled'
                              : 'Cancel Application'),
                          onPressed:
                              isApplicationCanceled ? null : _cancelApplication,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: isApplicationCanceled
                                ? Colors.red
                                : const Color.fromRGBO(244, 67, 54, 1),
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
        Icon(icon, size: 16.0),
        SizedBox(width: 4.0),
        Text(text),
      ],
    );
  }
}
