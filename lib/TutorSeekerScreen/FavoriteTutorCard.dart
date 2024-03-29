import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/FCM/StoreNotification.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerChat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';

//IF THE STUDENT/TUTOR TIME OVERLAP
//IF THE STUDENT APPLY ON THE SAME DATE

class FavoriteTutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final String fees;
  final String mode;
  const FavoriteTutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.fees,
    required this.tutorPostId,
    required this.mode,
  }) : super(key: key);

  @override
  _FavoriteTutorCardState createState() => _FavoriteTutorCardState();
}

class _FavoriteTutorCardState extends State<FavoriteTutorCard> {
  bool isFavorite = false;

  Map<String, dynamic>? selectedSlot;
  double _rating = 0.0;
  int _numberOfRating = 0;
  late String _DocumentUrl;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> _loadTutorUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Fetch the status of the tutor post application
      DocumentSnapshot tutorPostApplicationSnapshot = await FirebaseFirestore
          .instance
          .collection('Tutor')
          .doc(widget.tutorId)
          .collection('UserProfile')
          .doc(widget.tutorId)
          .get();

      if (tutorPostApplicationSnapshot.exists) {
        setState(() {
          _rating = tutorPostApplicationSnapshot.get('Rating');
          _numberOfRating = tutorPostApplicationSnapshot.get('NumberOfRating');
          _DocumentUrl = tutorPostApplicationSnapshot.get('DocumentUrl');
        });
      } else {
        setState(() {
          _rating = 0.00;
          _numberOfRating = 0;
        });
      }
    } catch (e) {
      print('Error loading application status: $e');
    }
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

  Future<bool> checkApplication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('Tutor Seeker')
          .doc(user.uid)
          .collection('ApplicationRequest')
          .doc('${widget.tutorId}_${widget.tutorPostId}')
          .get();

      if (doc.exists) {
        return true;
      }
    }
    return false;
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

    var snapshot = await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(tutorId)
        .collection('AvailibilitySlot')
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data();
      if (data['status'] == "available") {
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
    }
    return slotsList;
  }

  void _clickApply() async {
    if (!await checkApplication()) {
      final BuildContext dialogContext = context;
      try {
        List<Map<String, dynamic>> slots =
            await _getAvailabilitySlot(widget.tutorId);

        // Show availability dialog
        _showAvailabilityDialog(dialogContext, slots);
      } catch (e) {
        print(e);
      }
    } else {
      // User has already applied
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Already Applied'),
            content:
                const Text('You have already applied for this tutor post.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleSlotSelection(Map<String, dynamic> slot) {
    setState(() {
      selectedSlot = slot;
    });
  }

  Future<void> _showAvailabilityDialog(
      BuildContext context, List<Map<String, dynamic>> slots) async {
    int? selectedSlotIndex;
    if (slots.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('No Availability Slots'),
            content: const Text(
                'There are no availability slots. You may chat with this tutor to let them add slots.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Chat'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TutorSeekerChat(ReceiverUserId: widget.tutorId)),
                  );
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
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
                              selectedSlotIndex = index;
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

                              String startTime = selectedSlot['startTime'];
                              String endTime = selectedSlot['endTime'];
                              String day = selectedSlot['day'];

                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Map<String, dynamic> tutorPostApplicationData =
                                    {
                                  'Day': day,
                                  'StartTime': startTime,
                                  'EndTime': endTime,
                                  'Status': "pending",
                                  "RatePerClass": widget.fees,
                                  "Subject": widget.subject,
                                  'TutorPostId': widget.tutorPostId,
                                  'TutorId': widget.tutorId,
                                };

                                Map<String, dynamic>
                                    tutorApplicationFromTsData = {
                                  'Day': day,
                                  'StartTime': startTime,
                                  'EndTime': endTime,
                                  'Status': "pending",
                                  "RatePerClass": widget.fees,
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

                                StoreNotification().sendNotificationtoTutor(
                                    widget.tutorId,
                                    "Application Request",
                                    "You have Received Application from ${widget.name}.",
                                    now);
                              }

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
  }

  @override
  Widget build(BuildContext context) {
    _loadTutorUserProfile();
    String ratingText = _numberOfRating != 0
        ? '${_rating.toStringAsFixed(1)} (${_numberOfRating})'
        : "No ratings yet";
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
                _buildInfoWithIcon(Icons.star, 'Rating: ${ratingText}'),
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
              _buildActionButton(context, 'Chat', Icons.chat, () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TutorSeekerChat(ReceiverUserId: widget.tutorId)),
                );
              }),
              _buildActionButton(context, 'Details', Icons.info_outline, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TutorDetailPage(
                      tutorId: widget.tutorId,
                      tutorPostId: widget.tutorPostId,
                      imageURL: widget.imageURL,
                      DocumentUrl: _DocumentUrl,
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
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
