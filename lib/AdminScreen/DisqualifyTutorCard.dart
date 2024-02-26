import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/FCM/StoreNotification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DisqualifyTutorCard extends StatefulWidget {
  final String tutorId;
  final String name;
  final String imageURL;
  final double rate;
  final int numberofRating;

  const DisqualifyTutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.imageURL,
    required this.rate,
    required this.numberofRating,
  }) : super(key: key);

  @override
  _DisqualifyTutorCardState createState() => _DisqualifyTutorCardState();
}

class _DisqualifyTutorCardState extends State<DisqualifyTutorCard> {
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

/*
  Future<void> deleteSubcollections(String parentDocPath) async {
    List<String> subcollections = ['UserProfile', 'TutorPost'];

    for (String subcol in subcollections) {
      // Reference to the subcollection
      QuerySnapshot subcolSnapshot = await FirebaseFirestore.instance
          .collection(parentDocPath)
          .doc(widget.tutorId)
          .collection(subcol)
          .get();

      // Iterate through all the documents in the subcollection and delete them
      for (DocumentSnapshot subcolDoc in subcolSnapshot.docs) {
        await subcolDoc.reference.delete().catchError((error) {
          print("Error deleting subcollection document: $error");
          // Handle the error
        });
      }
    }
  }
*/
  void _updateDisqualify() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }

    // Get the current date/time as the accepted date
    DateTime now = DateTime.now();

    /*
    await deleteSubcollections('Tutor/$tutorId').then((_) {
      print('All documents in the collection have been deleted successfully.');
    }).catchError((error) {
      print('Error deleting documents: $error');
    });
    */

    await FirebaseFirestore.instance
        .collection('Admin')
        .doc(currentUser.uid)
        .collection('TutorUnderRate')
        .doc(widget.tutorId)
        .delete();

    await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(widget.tutorId)
        .set({'Status': 'Deleted'}, SetOptions(merge: true)).catchError((e) {
      print('Error updating tutor status: $e');
    });

    StoreNotification().sendNotificationtoTutor(
        widget.tutorId,
        "Tutor Disqualified",
        "Your have been disqualified due to low rating",
        now);
    _showDialog('Disqualified Sucessfully', 'The tutor has been disqualified.');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(widget.imageURL),
                ),
                const SizedBox(width: 30),
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
                      const SizedBox(height: 8),
                      Text(
                          'Rating: ${widget.rate} (${widget.numberofRating} reviews)',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _updateDisqualify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Disqualify Tutor',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
