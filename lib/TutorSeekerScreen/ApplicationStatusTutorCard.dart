import 'package:cloud_firestore/cloud_firestore.dart';
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
  const ApplicationStatusTutorCard({
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
  _ApplicationStatusTutorCardState createState() =>
      _ApplicationStatusTutorCardState();
}

class _ApplicationStatusTutorCardState
    extends State<ApplicationStatusTutorCard> {
  bool isFavorite = false;
  String _applicationStatus = ''; // Add this line

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

        _showDialog('Cancelled', 'Application cancelled successfully');
      } catch (e) {
        _showDialog('Error', 'Error cancelling application: $e');
      }
    } else {
      _showDialog('Error', 'You are not logged in');
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

  @override
  Widget build(BuildContext context) {
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
        applicationStatusText = 'Unknown';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                applicationStatusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.imageURL),
            ),
            title: Text(widget.name),
            subtitle: Text(widget.subject),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Rating: ${widget.rating}'),
                Text('Price: ${widget.fees}/hr'),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TutorDetailPage(
                        tutorId: widget.tutorId,
                        tutorPostId: widget.tutorPostId,
                      ),
                    ),
                  );
                },
                child: Text('Details'),
              ),
              _applicationStatus == "accepted"
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TutorSeekerPayment()),
                        );
                      },
                      child: Text('Pay Now'),
                    )
                  : ElevatedButton(
                      onPressed: _cancelApplication,
                      child: Text('Cancel Application'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
