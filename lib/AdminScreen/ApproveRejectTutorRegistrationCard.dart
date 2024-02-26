import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/AdminScreen/ApproveRejectTutorRegistrationDetail.dart';
import 'package:edumateapp/FCM/StoreNotification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorRegistrationCard extends StatefulWidget {
  final String tutorId;
  final String name;
  final String qualification;
  final String imageURL;
  final String documentURL;

  const TutorRegistrationCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.imageURL,
    required this.qualification,
    required this.documentURL,
  }) : super(key: key);

  @override
  _TutorRegistrationCardState createState() => _TutorRegistrationCardState();
}

class _TutorRegistrationCardState extends State<TutorRegistrationCard> {
  @override
  void initState() {
    super.initState();
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
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateAccepted() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String adminId = currentUser.uid;
    // Get the current date/time as the accepted date
    DateTime now = DateTime.now();

    var tutorApplicationRequestDocRef = FirebaseFirestore.instance
        .doc('Admin/$adminId/TutorRegistrationRequest/${widget.tutorId}');

    try {
      var docSnapshot = await tutorApplicationRequestDocRef.get();
      if (docSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(widget.tutorId)
            .set({'UserType': "Tutor"}, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(widget.tutorId)
            .collection('UserProfile')
            .doc(widget.tutorId)
            .set({'Status': "Verified"}, SetOptions(merge: true));

        await tutorApplicationRequestDocRef.delete();
      } else {
        _showDialog('Error', 'Document does not exist');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to transfer data: $e');
    }

    StoreNotification().sendNotificationtoTutor(
        widget.tutorId,
        "Registration Application Update",
        "Your Registration Request from has been accepted.",
        now);

    _showDialog(
        'Application Update', 'The registration status has been updated.');
  }

  void _updateReject() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String adminId = currentUser.uid;
    // Get the current date/time as the accepted date
    DateTime now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(widget.tutorId)
        .collection('UserProfile')
        .doc(widget.tutorId)
        .set({'Status': "Rejected"}, SetOptions(merge: true));

    var tutorApplicationRequestDocRef = FirebaseFirestore.instance
        .doc('Admin/$adminId/TutorRegistrationRequest/${widget.tutorId}');
    await tutorApplicationRequestDocRef.delete();

    StoreNotification().sendNotificationtoTutorSeeker(
        widget.tutorId,
        "Application Rejected",
        "Tutor Registration Request has been rejected.",
        now);
    _showDialog(
        'Application Update', 'The registration status has been updated.');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(widget.imageURL),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Ensuring text is black
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Qualification: ${widget.qualification}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black, // Ensuring text is black
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                spacing: 8, // space between buttons
                children: <Widget>[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person, color: Colors.blue),
                    label:
                        const Text('Profile', style: TextStyle(color: Colors.blue)),
                    onPressed: () => _navigateToProfile(),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.document_scanner, color: Colors.blue),
                    label: const Text('Certification',
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () => _launchDocumentURL(),
                  ),
                  const SizedBox(width: 4,),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.thumb_down, size: 20, color: Colors.blue,),
                    label: const Text('Reject'),
                    onPressed: _updateReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 205, 204),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4,),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.thumb_up, size: 20, color: Colors.blue,),
                    label: const Text('Accept'),
                    onPressed: _updateAccepted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 199, 226, 200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApproveRejectTutorRegistrationDetail(
          tutorId: widget.tutorId,
        ),
      ),
    );
  }

  void _launchDocumentURL() async {
    // ignore: deprecated_member_use
    if (await canLaunch(widget.documentURL)) {
      // ignore: deprecated_member_use
      await launch(widget.documentURL);
    } else {
      _showDialog('Error', 'Could not launch document.');
    }
  }
}
