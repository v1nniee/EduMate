import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';

class TutorSeekerCard extends StatefulWidget {
  final String tutorseekerId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String grade;
  final String imageURL;
  final String requirement;
  final String status;
  final String StartTime;
  final String EndTime;
  final String Day;

  const TutorSeekerCard({
    Key? key,
    required this.tutorseekerId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.tutorPostId,
    required this.grade,
    required this.requirement,
    required this.status,
    required this.StartTime,
    required this.EndTime,
    required this.Day,
  }) : super(key: key);

  @override
  _TutorSeekerCardState createState() => _TutorSeekerCardState();
}

class _TutorSeekerCardState extends State<TutorSeekerCard> {
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
    User currentUser = FirebaseAuth.instance.currentUser!;
    Color cardColor;
    String applicationStatusText;

    switch (widget.status) {
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

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12.0), // Set a neutral background color
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 20.0, horizontal: 13.0), // Increase padding
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 40, // Increased avatar size
              backgroundImage: NetworkImage(widget.imageURL),
            ),
            SizedBox(width: 20), // Space between avatar and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)), // Increase text size
                  SizedBox(height: 8), // Space between text lines
                  Text('Subject: ${widget.subject}',
                      style: TextStyle(fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Grade: ${widget.grade}',
                      style: TextStyle(fontSize: 13)),
                  if (widget.requirement != "N/A")
                    Text('Requirement: ${widget.requirement}',
                        style: TextStyle(fontSize: 13)),
                  SizedBox(height: 4),
                  Text(
                      'Day: ${widget.Day} ${widget.StartTime} - ${widget.EndTime}',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.check_circle_outline,
                      size: 40, color: Colors.green), // Increase icon size
                  onPressed: () {
                    // TODO: Implement accept logic
                  },
                ),
                SizedBox(height: 15), // Space between buttons
                IconButton(
                  icon: Icon(Icons.cancel_outlined,
                      size: 45, color: Colors.red), // Increase icon size
                  onPressed: () {
                    // TODO: Implement reject logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
