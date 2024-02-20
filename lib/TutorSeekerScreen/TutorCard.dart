import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';

//IF THE STUDENT/TUTOR TIME OVERLAP
//IF THE TUTOR DOES NOT HAVE SLOT ANYMORE
//IF THE STUDENT APPLY ON THE SAME POST
//IF THE STUDENT APPLY ON THE SAME DATE

class TutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;
  final String mode;
  const TutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.rating,
    required this.fees,
    required this.tutorPostId,
    required this.mode,
  }) : super(key: key);

  @override
  _TutorCardState createState() => _TutorCardState();
}

class _TutorCardState extends State<TutorCard> {
  bool isFavorite = false;
  Map<String, dynamic>? selectedSlot;
  String? applicationStatus;

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
        }).then((_) {
          FirebaseFirestore.instance
              .collection('Tutor Seeker')
              .doc(user.uid)
              .collection('FavoriteTutors')
              .doc(widget.tutorId)
              .get()
              .then((docSnapshot) {
            if (docSnapshot.exists &&
                docSnapshot.data()?['tutorPostIds'].isEmpty == true) {
              FirebaseFirestore.instance
                  .collection('Tutor Seeker')
                  .doc(user.uid)
                  .collection('FavoriteTutors')
                  .doc(widget.tutorId)
                  .delete();
            }
          });
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
    setState(() {
      selectedSlot = slot;
    });
  }

  void _sendNotification(String tutorseekerId, String title, String content,
      DateTime NotificationTime) async {
    Map<String, dynamic> NotificationData = {
      'Title': title,
      'Content': content,
      'Status': "Unsend",
      'NotificationTime': NotificationTime,
    };

    try {
      await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(tutorseekerId)
          .collection('Notification')
          .add(NotificationData);
    } catch (error) {
      print('Error saving notification: $error');
    }
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
                          color: isSelected ? Colors.yellow : Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ListTile(
                        title: Text(
                            '${slots[index]['day']} ${slots[index]['startTime']} - ${slots[index]['endTime']}'),
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
                    onPressed: selectedSlotIndex != null
                        ? () async {
                            assert(selectedSlotIndex != null,
                                'selectedSlotIndex must not be null');
                            Map<String, dynamic> selectedSlot =
                                slots[selectedSlotIndex!];

                            // Extract the start time, end time, and day from the selected slot
                            String startTime = selectedSlot['startTime'];
                            String endTime = selectedSlot['endTime'];
                            String day = selectedSlot['day'];

                            // Rest of your logic to save the selected slot...
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Map<String, dynamic> tutorPostApplicationData = {
                                'Day': day,
                                'StartTime': startTime,
                                'EndTime': endTime,
                                'Status': "pending",
                                "Subject": widget.subject,
                                'TutorPostId': widget.tutorPostId,
                                'TutorId': widget.tutorId,
                              };

                              Map<String, dynamic> tutorApplicationFromTsData =
                                  {
                                'Day': day,
                                'StartTime': startTime,
                                'EndTime': endTime,
                                'Status': "pending",
                                "Subject": widget.subject,
                                'TutorPostId': widget.tutorPostId,
                                'TutorSeekerId': user.uid,
                              };

                              String TSdocumentId =
                                  '${widget.tutorId}_${widget.tutorPostId}';

                              FirebaseFirestore.instance
                                  .collection('Tutor Seeker')
                                  .doc(user.uid)
                                  .collection('ApplicationRequest')
                                  .doc(TSdocumentId)
                                  .set(tutorPostApplicationData);

                              String documentId =
                                  '${user.uid}_${widget.tutorPostId}';

                              FirebaseFirestore.instance
                                  .collection('Tutor')
                                  .doc(widget.tutorId)
                                  .collection('ApplicationRequest')
                                  .doc(documentId)
                                  .set(tutorApplicationFromTsData);

                              DateTime now = DateTime.now();

                              _sendNotification(
                                  widget.tutorId,
                                  "Application Request",
                                  "You have Received Application from ${widget.name}.",
                                  now);
                            }
                            // Close the dialog
                            Navigator.of(dialogContext).pop();

                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: dialogContext,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Applied Successfully!"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null,
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
      elevation: 2.0,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.imageURL),
            ),
            title: Text(widget.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.subject),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoWithIcon(
                    Icons.star, 'Rating: ${widget.rating.toStringAsFixed(1)}'),
                _buildInfoWithIcon(Icons.monetization_on, 'RM${widget.fees}'),
                _buildInfoWithIcon(
                    widget.mode == 'Online' ? Icons.wifi : Icons.person,
                    widget.mode),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(context, 'Details', Icons.info_outline, () {
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
              }),
              _buildActionButton(context, 'Apply', Icons.send, _clickApply),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWithIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.0),
        SizedBox(width: 4.0),
        Text(text),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String text, IconData icon,
      VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.0),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor:
            Theme.of(context).primaryColor, // replace with your onPrimary color
      ),
    );
  }
}
