import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:intl/intl.dart';

class MyTutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String subject;
  final DateTime startClassDate;
  final DateTime endClassDate;
  final String day;
  final String startTime;
  final String endTime;

  const MyTutorCard({
    Key? key,
    required this.tutorId,
    required this.subject,
    required this.tutorPostId,
    required this.startClassDate,
    required this.endClassDate,
    required this.day,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  _MyTutorCardState createState() => _MyTutorCardState();
}

class _MyTutorCardState extends State<MyTutorCard> {
  String _name = '';
  String _imageURL = '';
  @override
  void initState() {
    super.initState();
    _loadTutorInfo();
  }

  Future<void> _loadTutorInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      DocumentSnapshot tutorPostApplicationSnapshot = await FirebaseFirestore
          .instance
          .collection('Tutor')
          .doc(widget.tutorId)
          .collection('UserProfile')
          .doc(widget.tutorId)
          .get();

      if (tutorPostApplicationSnapshot.exists) {
        setState(() {
          _name = tutorPostApplicationSnapshot["Name"];
          _imageURL = tutorPostApplicationSnapshot["ImageUrl"];
        });
      }
    } catch (e) {
      print('Error loading application status: $e');
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    

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
              title: Text(_name,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle:
                  Text(widget.subject, style: TextStyle(color: Colors.black)),
              
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Align the content to the start of the column
                children: [
                  _buildInfoWithIcon(Icons.schedule,
                      '${_formatDate(widget.startClassDate)} - ${_formatDate(widget.endClassDate)}'),
                  SizedBox(
                      height: 8), // Add some vertical spacing between the rows
                  _buildInfoWithIcon(Icons.timeline,
                      '${widget.day} ${widget.startTime} - ${widget.endTime}'),
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

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.black, // Replace with your onPrimary color
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
