import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:provider/provider.dart';

class TutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;
  const TutorCard({
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
  _TutorCardState createState() => _TutorCardState();
}

class _TutorCardState extends State<TutorCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('Tutor Seeker')
          .doc(user.uid)
          .collection('FavoriteTutors')
          .doc(widget.tutorId)
          .get();

      if (doc.exists) {
        setState(() {
          isFavorite =
              doc.data()?['tutorPostIds'].contains(widget.tutorPostId) ?? false;
        });
      }
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (isFavorite) {
        FirebaseFirestore.instance
            .collection('Tutor Seeker')
            .doc(user.uid)
            .collection('FavoriteTutors')
            .doc(widget.tutorId)
            .set({
          'TutorID': widget.tutorId,
          'tutorPostIds': FieldValue.arrayUnion([widget.tutorPostId]),
        }, SetOptions(merge: true));
      } else {
        FirebaseFirestore.instance
            .collection('Tutor Seeker')
            .doc(user.uid)
            .collection('FavoriteTutors')
            .doc(widget.tutorId)
            .update({
          'tutorPostIds': FieldValue.arrayRemove([widget.tutorPostId]),
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getAvailabilitySlot(
      String tutorId) async {
    List<Map<String, dynamic>> slotsList = [];

    // Retrieve the AvailabilitySlot collection for the given tutorId
    var snapshot = await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(tutorId)
        .collection('AvailibilitySlot')
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data();
      if (data.containsKey('day') &&
          data.containsKey('startTime') &&
          data.containsKey('endTime')) {
        slotsList.add({
          'day': data['day'],
          'startTime': data['startTime'],
          'endTime': data['endTime'],
        });
      }
    }
    return slotsList;
  }

  void _clickApply() async {
    final BuildContext dialogContext = context;
    try {
      List<Map<String, dynamic>> slots =
          await _getAvailabilitySlot(widget.tutorId);
      // ignore: use_build_context_synchronously
      _showAvailabilityDialog(dialogContext, slots);
    } catch (e) {
      print(e);
    }
  }

  void _handleSlotSelection(Map<String, dynamic> slot) {
    print(
        'Selected slot: ${slot['day']} from ${slot['startTime']} to ${slot['endTime']}');
    Navigator.of(context).pop();
  }

  Future<void> _showAvailabilityDialog(
      BuildContext context, List<Map<String, dynamic>> slots) async {
    int? selectedSlotIndex;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Choose an Availability Slot'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: List<Widget>.generate(slots.length, (index) {
                    bool isSelected = selectedSlotIndex == index;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey, // Change color based on selection
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ListTile(
                        title: Text(
                            '${slots[index]['day']} from ${slots[index]['startTime']} to ${slots[index]['endTime']}'),
                        onTap: () {
                          setState(() {
                            selectedSlotIndex =
                                index; // Update the selected index
                          });
                          _handleSlotSelection(slots[index]);
                        },
                      ),
                    );
                  }),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                if (selectedSlotIndex != null)
                  TextButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      // Confirm the selected slot and close the dialog
                      Navigator.of(dialogContext).pop();
                      // Optionally, handle the confirmed slot here or pass it back to the caller
                    },
                  ),
              ],
            );
          },
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
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
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
                onPressed: () => _clickApply(),
                child: Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
