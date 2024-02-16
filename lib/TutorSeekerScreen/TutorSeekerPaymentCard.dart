import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/PaymentConfirmationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:edumateapp/Payment/StripePaymentHandle.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:printing/printing.dart';

class TutorSeekerPaymentCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;
  const TutorSeekerPaymentCard({
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
  _TutorSeekerPaymentCardState createState() => _TutorSeekerPaymentCardState();
}

class _TutorSeekerPaymentCardState extends State<TutorSeekerPaymentCard> {
  bool isFavorite = false;
  String _applicationStatus = '';
  DateTime? _acceptedDate; // Nullable DateTime
  DateTime? _lastPayment;
  String _tutorseekerName = '';
  String _day = '';

  @override
  void initState() {
    super.initState();
    _loadApplicationStatus();
    _loadUserProfile();
  }

  Future<void> _loadApplicationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Fetch the status of the tutor post application
      DocumentSnapshot tutorPostApplicationSnapshot = await FirebaseFirestore
          .instance
          .collection('Tutor Seeker')
          .doc(user?.uid)
          .collection('ApplicationRequest')
          .doc('${widget.tutorId}_${widget.tutorPostId}')
          .get();

      if (tutorPostApplicationSnapshot.exists) {
        setState(() {
          _applicationStatus = tutorPostApplicationSnapshot.get('Status');
        });
      } else {
        setState(() {
          _applicationStatus = 'Not found';
        });
      }
    } catch (e) {
      print('Error loading application status: $e');
    }
  }

  Future<void> _loadDate() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      DocumentSnapshot tutorPostApplicationSnapshot = await FirebaseFirestore
          .instance
          .collection('Tutor Seeker')
          .doc(user?.uid)
          .collection('ApplicationRequest')
          .doc('${widget.tutorId}_${widget.tutorPostId}')
          .get();

      if (tutorPostApplicationSnapshot.exists) {
        var acceptedDate = tutorPostApplicationSnapshot.get('AcceptedDate');
        var lastPayment = tutorPostApplicationSnapshot.get('LastPayment');

        setState(() {
          _acceptedDate = acceptedDate is Timestamp
              ? acceptedDate.toDate()
              : DateTime.now(); // Use a default or handle null appropriately
          _lastPayment = lastPayment is Timestamp
              ? lastPayment.toDate()
              : null; // Properly use null

          _day = tutorPostApplicationSnapshot.get('Day');
        });
      } else {
        setState(() {
          _applicationStatus = 'Not found';
        });
      }
    } catch (e) {
      print('Error loading date: $e');
    }
  }

  Future<void> _cancelApplication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to the TutorApplication document
      DocumentReference tutorApplicationDocRef = FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(user.uid)
          .collection('ApplicationRequest')
          .doc('${widget.tutorId}_${widget.tutorPostId}');

      DocumentReference tutorApplicationfromTSDocRef = FirebaseFirestore
          .instance
          .collection('Tutor')
          .doc(widget.tutorId)
          .collection('ApplicationRequest')
          .doc('${user.uid}_${widget.tutorPostId}');

      try {
        // Check if the specific TutorApplication document exists and delete if it does
        DocumentSnapshot tutorApplicationSnapshot =
            await tutorApplicationDocRef.get();
        if (tutorApplicationSnapshot.exists) {
          await tutorApplicationDocRef.delete();
        }

        DocumentSnapshot tutorApplicationfromTSSnapshot =
            await tutorApplicationfromTSDocRef.get();
        if (tutorApplicationfromTSSnapshot.exists) {
          await tutorApplicationfromTSDocRef.delete();
        }

        _showDialog('Cancelled', 'Application cancelled successfully');
      } catch (e) {
        _showDialog('Error', 'Error cancelling application: $e');
      }
    } else {
      _showDialog('Error', 'You are not logged in');
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

  String calculateFees() {
    // Parse the fees String to a double
    int fees = int.tryParse(widget.fees) ?? 0;

    // Multiply by 4
    int updatedFees = (fees * 4);

    // Convert back to String and return
    return updatedFees.toStringAsFixed(0);
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Fetch the status of the tutor post application
      DocumentSnapshot tutorSeekerSnapshot = await FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(user?.uid)
          .get();

      if (tutorSeekerSnapshot.exists) {
        setState(() {
          _tutorseekerName = tutorSeekerSnapshot.get('Name');
        });
      } else {
        setState(() {
          _tutorseekerName = 'Not found';
        });
      }
    } catch (e) {
      print('Error loading name: $e');
    }
  }

  int getDayOfWeekNumber(String day) {
    switch (day) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        print('4');
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        throw ArgumentError('Invalid day of the week');
    }
  }

  void _update(
      DateTime paymentDate, String paymentAmount, DateTime startClassDate, DateTime endclassDate) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String tutorseekerId = currentUser.uid;
    DateTime now = DateTime.now();

    Map<String, dynamic> updateData = {
      'Status': "paid",
      'LastPayment': paymentDate,
      'PaymentAmount': paymentAmount,
      'StartclassDate': startClassDate,
      'EndclassDate': endclassDate,
    };

    await FirebaseFirestore.instance
        .doc(
            'Tutor Seeker/${tutorseekerId}/ApplicationRequest/${widget.tutorId}_${widget.tutorPostId}')
        .update(updateData)
        .catchError((e) {
      _showDialog('Error', 'Failed to update tutor seeker status: $e');
    });

    // Update in Tutor's collection
    await FirebaseFirestore.instance
        .doc(
            'Tutor/${widget.tutorId}/ApplicationRequest/${tutorseekerId}_${widget.tutorPostId}')
        .update(updateData)
        .catchError((e) {
      _showDialog('Error', 'Failed to update status: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final stripePaymentHandle = StripePaymentHandle();

    // Check if the application status is 'accepted' before building the card
    if (_applicationStatus == 'accepted') {
      _loadDate();
      Color cardColor =
          Colors.green; // Since it's accepted, we'll use green color
      String applicationStatusText = 'Accepted';

      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  applicationStatusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.imageURL),
              ),
              title: Text(widget.name),
              subtitle: Text(widget.subject),
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
                  onPressed: () async {
                    bool result = await stripePaymentHandle
                        .stripeMakePayment(calculateFees());
                    if (result) {
                      DateTime paymentDate = DateTime.now();
                      DateTime startclassDate = _getNextClassDate(
                          paymentDate, getDayOfWeekNumber(_day));
                      DateTime endclassDate = _getEndDate(startclassDate);
                      _update(paymentDate, calculateFees(), startclassDate,endclassDate);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentConfirmationScreen(
                            tutorSeekerName: _tutorseekerName,
                            tutorName: widget.name,
                            subject: widget.subject,
                            paymentAmount: calculateFees(),
                            paymentDate: paymentDate,
                            startclassDate: startclassDate,
                            endclassDate: endclassDate,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Pay Now'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // If the application status is not 'accepted', return an empty Container or any other widget that fits your UI needs when there's no card to display
      return Container();
    }
  }

  DateTime _getNextClassDate(DateTime paymentDate, int classDayOfWeek) {
    // classDayOfWeek is an integer where 1 = Monday, 2 = Tuesday, ..., 7 = Sunday.

    // If payment is made on the class day, we need to determine if it counts for this week.
    // For this example, let's assume if payment is made before a set time (e.g., 12 PM),
    // it counts for the same day, otherwise, it starts from the next week.
    bool countForThisWeek =
        paymentDate.weekday == classDayOfWeek && paymentDate.hour < 12;

    DateTime nextClassDate = paymentDate;
    if (countForThisWeek) {
      // If the payment is early enough on the class day, it counts for the current week.
      while (nextClassDate.weekday != classDayOfWeek) {
        nextClassDate = nextClassDate.add(Duration(days: 1));
      }
    } else {
      // Otherwise, find the next class day starting from the next day.
      nextClassDate = nextClassDate.add(Duration(days: 1));
      while (nextClassDate.weekday != classDayOfWeek) {
        nextClassDate = nextClassDate.add(Duration(days: 1));
      }
    }

    return nextClassDate;
  }

  DateTime _getEndDate(DateTime startDate) {
    return startDate.add(Duration(days: 4 * 7));
  }
}
