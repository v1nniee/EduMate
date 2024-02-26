import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/FCM/StoreNotification.dart';
import 'package:edumateapp/TutorScreen/TutorSeekerDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<bool> checkAvailabilitySlots(
      String day, String startTime, String endTime, String tutorId) async {
    // Reference to the availability slots of the tutor
    var availabilitySlotsRef = FirebaseFirestore.instance
        .collection('Tutor')
        .doc(tutorId)
        .collection('AvailabilitySlot');

    // Query for slots that match the day, start time, and end time and are available
    var querySnapshot = await availabilitySlotsRef
        .where('day', isEqualTo: day)
        .where('startTime', isEqualTo: startTime)
        .where('endTime', isEqualTo: endTime)
        .where('status', isEqualTo: 'unavailable')
        .get();

    return querySnapshot.docs.isEmpty;
  }

  void _updateAccepted() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String tutorId = currentUser.uid;
    // Get the current date/time as the accepted date
    DateTime now = DateTime.now();

    Map<String, dynamic> updateData = {
      'Status': "accepted",
      'AcceptedDate': now,
    };

    String tutorDocumentId = "${widget.tutorseekerId}_${widget.tutorPostId}";
    print(tutorId);
    var tutorApplicationRequestDocRef = FirebaseFirestore.instance
        .doc('Tutor/${tutorId}/ApplicationRequest/$tutorDocumentId');
    var toPayTutorSeekerDocRef = FirebaseFirestore.instance
        .collection('Tutor')
        .doc(tutorId)
        .collection('ToPayTutorSeeker')
        .doc(tutorDocumentId);

    try {
      var docSnapshot = await tutorApplicationRequestDocRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> existingData =
            docSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> mergedData = {...existingData, ...updateData};

        await toPayTutorSeekerDocRef.set(mergedData).then((_) async {
          await tutorApplicationRequestDocRef.delete();
        });
      } else {
        _showDialog('Error', 'Document does not exist');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to transfer data: $e');
    }

    String tutorSeekerDocumentId = "${tutorId}_${widget.tutorPostId}";
    var tutorSeekerApplicationRequestDocRef = FirebaseFirestore.instance.doc(
        'Tutor Seeker/${widget.tutorseekerId}/ApplicationRequest/$tutorSeekerDocumentId');
    var toPayDocRef = FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(widget.tutorseekerId)
        .collection('ToPay')
        .doc(tutorSeekerDocumentId);

    try {
      var docSnapshot = await tutorSeekerApplicationRequestDocRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> existingData =
            docSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> mergedData = {...existingData, ...updateData};

        await toPayDocRef.set(mergedData);

        await tutorSeekerApplicationRequestDocRef
            .update(updateData)
            .catchError((e) {
          _showDialog('Error', 'Failed to update tutor seeker status: $e');
        });
      }
    } catch (e) {
      _showDialog('Error', 'An error occurred: $e');
    }

    StoreNotification().sendNotificationtoTutorSeeker(
        widget.tutorseekerId,
        "Application Update",
        "Your Application from ${_name} has been accepted.",
        now);

    _showDialog(
        'Application Update', 'The application status has been updated.');
  }

  void _updateReject() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String tutorId = currentUser.uid;
    // Get the current date/time as the accepted date
    DateTime now = DateTime.now();

    Map<String, dynamic> updateData = {
      'Status': "rejected",
    };

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

    StoreNotification().sendNotificationtoTutorSeeker(
        widget.tutorseekerId,
        "Application Update",
        "Your Application from ${_name} has been rejected.",
        now);
    _showDialog(
        'Application Update', 'The application status has been updated.');
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
            Padding(
              padding:
                  const EdgeInsets.only(top: 8.0), // Add padding at the top
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Align buttons to the start of the row
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: Icon(Icons.info_outline, size: 16.0),
                    label: Text('Details'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TutorSeekerDetails(
                            tutorSeekerid: widget.tutorseekerId,
                            imageURL: widget.imageURL,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateReject();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Background color for Reject
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      bool available = await checkAvailabilitySlots(
                        widget.Day,
                        widget.StartTime,
                        widget.EndTime,
                        currentUser.uid,
                      );
                      if (available) {
                        _updateAccepted();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Slot Unavailable'),
                              content: Text('The availability slot is full.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Dismiss the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // Background color for Accept
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        Text('Accept', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
