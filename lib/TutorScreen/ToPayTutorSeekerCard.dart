import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToPayTutorSeekerCard extends StatefulWidget {
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
  final DateTime AcceptedDate;

  const ToPayTutorSeekerCard({
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
    required this.AcceptedDate,
  }) : super(key: key);

  @override
  _ToPayTutorSeekerCardState createState() => _ToPayTutorSeekerCardState();
}

class _ToPayTutorSeekerCardState extends State<ToPayTutorSeekerCard> {
  String _name = '';
  @override
  void initState() {
    super.initState();
    _loadTutorName();
  }

  Future<void> _loadTutorName() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Fetch the status of the tutor post application
      DocumentSnapshot tutorSnapshot = await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(user?.uid)
          .get();

      if (tutorSnapshot.exists) {
        setState(() {
          _name = tutorSnapshot.get('Name');
        });
      } else {
        setState(() {
          _name = 'Not found';
        });
      }
    } catch (e) {
      print('Error loading tutor doc: $e');
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
    User currentUser = FirebaseAuth.instance.currentUser!;
    Color cardColor;
    String applicationStatusText;

    DateTime originalDate = widget.AcceptedDate;
    DateTime duedate = originalDate.add(Duration(days: 7));

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
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // First Row: Avatar and Text
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(widget.imageURL),
                ),
                SizedBox(width: 30), // Space between avatar and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8), // Space between text lines
                      Text('Subject: ${widget.subject}',
                          style: TextStyle(fontSize: 13)),
                      Text('Grade: ${widget.grade}',
                          style: TextStyle(fontSize: 13)),
                      Text(
                          'Day: ${widget.Day} ${widget.StartTime} - ${widget.EndTime}',
                          style: TextStyle(fontSize: 13)),
                      Text(
                          'Payment Due: ${DateFormat('yyyy-MM-dd').format(duedate)}',
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            // Second Row: Buttons
          ],
        ),
      ),
    );
  }
}
