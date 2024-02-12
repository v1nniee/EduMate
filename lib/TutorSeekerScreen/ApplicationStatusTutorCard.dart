import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _cancelApplication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the TutorApplication document
      DocumentReference tutorApplicationDocRef = FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(user.uid)
          .collection('TutorApplication')
          .doc(widget.tutorId);

      // Reference to the TutorPostApplication document
      DocumentReference tutorPostApplicationDocRef = tutorApplicationDocRef
          .collection('TutorPostApplication')
          .doc(widget.tutorPostId);

      DocumentReference tutorApplicationfromTSDocRef = FirebaseFirestore.instance
          .collection('Tutor')
          .doc(widget.tutorId)
          .collection('TutorApplication')
          .doc(user.uid);

      // Reference to the TutorPostApplication document
      DocumentReference tutorPostApplicationfromTSDocRef = tutorApplicationfromTSDocRef
          .collection('TutorPostApplication')
          .doc(widget.tutorPostId);

      try {
        // Delete the TutorPostApplication document
        await tutorPostApplicationDocRef.delete();
        await tutorPostApplicationfromTSDocRef.delete();

        // Check if there are any other documents in TutorPostApplication collection
        QuerySnapshot tutorPostApplications = await tutorApplicationDocRef
            .collection('TutorPostApplication')
            .get();

        if (tutorPostApplications.docs.isEmpty) {
          // If the TutorPostApplication collection is empty, delete the TutorApplication document
          await tutorApplicationDocRef.delete();
        }

        QuerySnapshot tutorPostApplicationsfromTutor = await tutorApplicationfromTSDocRef
            .collection('TutorPostApplication')
            .get();
        if (tutorPostApplicationsfromTutor.docs.isEmpty) {
          // If the TutorPostApplication collection is empty, delete the TutorApplication document
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
    
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
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
              ElevatedButton(
                onPressed:  _cancelApplication, 
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
