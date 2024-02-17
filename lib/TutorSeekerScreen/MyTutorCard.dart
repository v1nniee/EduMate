import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';

class MyTutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;
  const MyTutorCard({
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
  _MyTutorCardState createState() => _MyTutorCardState();
}

class _MyTutorCardState extends State<MyTutorCard> {
  bool isFavorite = false;
  String _applicationStatus = '';
  DateTime? _acceptedDate; // Nullable DateTime
  DateTime? _lastPayment; // Nullable DateTime

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

  Future<void> _loadDate() async {
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
          _acceptedDate =
              tutorPostApplicationSnapshot.get('AcceptedDate')?.toDate() ??
                  DateTime.now(); // Provide a default value or handle null
          _lastPayment =
              tutorPostApplicationSnapshot.get('LastPayment')?.toDate() ??
                  Null; // Provide a default value or handle null
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
    // Check if the application status is 'accepted' before building the card
    if (_applicationStatus == 'paid') {
      _loadDate();
      Color cardColor =
          const Color.fromARGB(255, 207, 240, 208); // Since it's accepted, we'll use green color
      String applicationStatusText = 'Paid';

      return Card(
        color: cardColor,
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
                title: Text(widget.name,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                subtitle:
                    Text(widget.subject, style: TextStyle(color: Colors.black)),
                trailing: Text(
                  applicationStatusText,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoWithIcon(Icons.star,
                        'Rating: ${widget.rating.toStringAsFixed(1)}'),
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
                      foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.cancel, size: 16.0),
                    label: Text('Cancel Application'),
                    onPressed: _cancelApplication,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // If the application status is not 'accepted', return an empty Container or any other widget
      return Container();
    }
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

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.black, // Replace with your onPrimary color
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
