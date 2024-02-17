import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';

class MyStudentCard extends StatefulWidget {
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

  const MyStudentCard({
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
  _MyStudentCardState createState() => _MyStudentCardState();
}

class _MyStudentCardState extends State<MyStudentCard> {
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

  void _updateStatus(String newStatus) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String tutorId = currentUser.uid;
    // Get the current date/time as the accepted date
    DateTime now = DateTime.now();

    Map<String, dynamic> updateData = {
      'Status': newStatus,
      'LastPayment': null,
    };

    // Only add the AcceptedDate field if the new status is 'accepted'
    if (newStatus == 'accepted') {
      updateData['AcceptedDate'] = now;
    }

    // Update in Tutor Seeker's collection
    await FirebaseFirestore.instance
        .doc(
            'Tutor Seeker/${widget.tutorseekerId}/ApplicationRequest/${tutorId}_${widget.tutorPostId}')
        .update(updateData)
        .catchError((e) {
      _showDialog('Error', 'Failed to update tutor seeker status: $e');
    });

    await FirebaseFirestore.instance
        .doc(
            'Tutor/$tutorId/ApplicationRequest/${widget.tutorseekerId}_${widget.tutorPostId}')
        .update(updateData)
        .catchError((e) {
      _showDialog('Error', 'Failed to update status: $e');
    });

    _sendNotification(widget.tutorseekerId, "Application Update",
        "Your Application from ${_name} has been ${widget.status}.", now);
  }

  void _sendNotification(
      String tutorseekerId, String title, String content, DateTime NotificationTime) async {
    Map<String, dynamic> NotificationData = {
      'Title': title,
      'Content': content,
      'Status': "Unsend",
      'NotificationTime': NotificationTime,
    };

    try {
      await FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(tutorseekerId)
          .collection('Notification')
          .add(NotificationData);
    } catch (error) {
      print('Error saving notification: $error');
    }
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
                      if (widget.requirement != "N/A")
                        Text('Requirement: ${widget.requirement}',
                            style: TextStyle(fontSize: 13)),
                      Text(
                          'Day: ${widget.Day} ${widget.StartTime} - ${widget.EndTime}',
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
