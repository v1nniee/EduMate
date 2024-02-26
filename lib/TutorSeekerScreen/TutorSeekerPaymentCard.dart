import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/FCM/StoreNotification.dart';
import 'package:edumateapp/TutorSeekerScreen/PaymentConfirmationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:edumateapp/Payment/StripePaymentHandle.dart';

class TutorSeekerPaymentCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String day;
  final String subject;
  final String startTime;
  final String endTime;
  final String fees;
  final DateTime acceptedDate;
  const TutorSeekerPaymentCard({
    Key? key,
    required this.tutorId,
    required this.day,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.fees,
    required this.tutorPostId,
    required this.acceptedDate,
  }) : super(key: key);

  @override
  _TutorSeekerPaymentCardState createState() => _TutorSeekerPaymentCardState();
}

class _TutorSeekerPaymentCardState extends State<TutorSeekerPaymentCard> {
  bool isFavorite = false;

  DateTime? _dueDate;
  String _tutorseekerName = '';
  String _tutorName = '';
  String _imageURL = '';
  late String _DocumentUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _deleteDuePayment();
    _loadTutorProfile();
  }

  Future<void> updateAvailabilitySlots(
      String day, String startTime, String endTime, String tutorId) async {
    
    var availabilitySlotsRef = FirebaseFirestore.instance
        .collection('Tutor')
        .doc(tutorId)
        .collection('AvailabilitySlot');

    var querySnapshot = await availabilitySlotsRef
        .where('day', isEqualTo: day)
        .where('startTime', isEqualTo: startTime)
        .where('endTime', isEqualTo: endTime)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'status': 'unavailable'});
    }
  }

  Future<void> _deleteDuePayment() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      DocumentSnapshot tutorPostApplicationSnapshot = await FirebaseFirestore
          .instance
          .collection('Tutor Seeker')
          .doc(user?.uid)
          .collection('ToPayTutorSeeker')
          .doc('${widget.tutorId}_${widget.tutorPostId}')
          .get();

      if (tutorPostApplicationSnapshot.exists) {
        _dueDate = widget.acceptedDate.add(Duration(days: 7));
        DateTime now = DateTime.now();

        if (now.isAfter(_dueDate!)) {
          DocumentReference ToPayTutorSeekerDocRef = FirebaseFirestore.instance
              .collection('Tutor')
              .doc(widget.tutorId)
              .collection('ToPayTutorSeeker')
              .doc('${user?.uid}_${widget.tutorPostId}');

          DocumentSnapshot ToPayTutorSeekerSnapshot =
              await ToPayTutorSeekerDocRef.get();
          if (ToPayTutorSeekerSnapshot.exists) {
            await ToPayTutorSeekerDocRef.delete();
          }

          DocumentReference ToPayDocRef = FirebaseFirestore.instance
              .collection('Tutor Seeker')
              .doc(widget.tutorId)
              .collection('ToPay')
              .doc('${widget.tutorId}_${widget.tutorPostId}');

          DocumentSnapshot ToPaySnapshot = await ToPayDocRef.get();
          if (ToPaySnapshot.exists) {
            await ToPayDocRef.delete();
          }

          DocumentReference ApplicationRequestDocRef = FirebaseFirestore
              .instance
              .collection('Tutor Seeker')
              .doc(user?.uid)
              .collection('ApplicationRequest')
              .doc('${widget.tutorId}_${widget.tutorPostId}');

          DocumentSnapshot ApplicationRequestSnapshot =
              await ApplicationRequestDocRef.get();
          if (ApplicationRequestSnapshot.exists) {
            await ApplicationRequestDocRef.delete();
          }

          DocumentReference ApplicationRequestfromtutorDocRef =
              FirebaseFirestore.instance
                  .collection('Tutor')
                  .doc(widget.tutorId)
                  .collection('ApplicationRequest')
                  .doc('${user?.uid}_${widget.tutorPostId}');

          DocumentSnapshot ApplicationRequestfromTutorSnapshot =
              await ApplicationRequestfromtutorDocRef.get();
          if (ApplicationRequestfromTutorSnapshot.exists) {
            await ApplicationRequestfromtutorDocRef.delete();
          }

          StoreNotification().sendNotificationtoTutor(
              widget.tutorId,
              "Pending Payment Alert",
              "Payment from ${_tutorseekerName} is due. The application has been cancelled.",
              now);

          StoreNotification().sendNotificationtoTutorSeeker(
              user!.uid,
              "Payment Overdue",
              "Your payment for sessions with ${_tutorName} on ${widget.subject} is due. The application has been cancelled.",
              now);
        }
      }
    } catch (e) {
      print('Error loading accepted date: $e');
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
    int fees = int.tryParse(widget.fees) ?? 0;
    int updatedFees = (fees * 4);
    return updatedFees.toStringAsFixed(0);
  }

  String removeCommisionFees() {
    int fees = int.tryParse(widget.fees) ?? 0;
    int updatedFees = (fees * 4) - 10;
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
          _DocumentUrl = tutorSeekerSnapshot.get('DocumentUrl');
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

  Future<void> _loadTutorProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Fetch the status of the tutor post application
      DocumentSnapshot tutorSeekerSnapshot = await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(widget.tutorId)
          .collection('UserProfile')
          .doc(widget.tutorId)
          .get();

      if (tutorSeekerSnapshot.exists) {
        setState(() {
          _tutorName = tutorSeekerSnapshot.get('Name');
          _imageURL = tutorSeekerSnapshot.get('ImageUrl');
        });
      } else {
        setState(() {
          _tutorName = 'Not found';
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

  void _updateTutor(DateTime paymentDate, String paymentAmount,
      DateTime startClassDate, DateTime endClassDate) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String tutorseekerId = currentUser.uid;

    Map<String, dynamic> updateData = {
      'PaymentDate': paymentDate,
      'PaymentAmount': paymentAmount,
      'StartClassDate': startClassDate,
      'EndClassDate': endClassDate,
    };

    String tutorDocumentId = "${tutorseekerId}_${widget.tutorPostId}";
    var toPayTutorSeekerRequestDocRef = FirebaseFirestore.instance
        .doc('Tutor/${widget.tutorId}/ToPayTutorSeeker/$tutorDocumentId');
    var myStudentDocRef = FirebaseFirestore.instance
        .collection('Tutor')
        .doc(widget.tutorId)
        .collection('MyStudent')
        .doc(tutorDocumentId);

    try {
      var docSnapshot = await toPayTutorSeekerRequestDocRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> existingData =
            docSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> mergedData = {...existingData, ...updateData};

        await myStudentDocRef.set(mergedData);

        await toPayTutorSeekerRequestDocRef.delete();
      } else {
        _showDialog('Error', 'Document does not exist');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to transfer data: $e');
    }

    Map<String, dynamic> studentPaymentData = {
      'PaymentDate': paymentDate,
      'PaymentAmount': paymentAmount,
      'TutorSeekerId': tutorseekerId,
      'TutorSeekerName': _tutorseekerName,
    };


    DocumentReference ApplicationRequestDocRef = FirebaseFirestore.instance
        .collection('Tutor')
        .doc(widget.tutorId)
        .collection('ApplicationRequest')
        .doc('${currentUser.uid}_${widget.tutorPostId}');

    DocumentSnapshot ApplicationRequestSnapshot =
        await ApplicationRequestDocRef.get();
    if (ApplicationRequestSnapshot.exists) {
      await ApplicationRequestDocRef.delete();
    }
    DateTime now = DateTime.now();

    StoreNotification().sendNotificationtoTutor(
        widget.tutorId,
        "Payment",
        "Payment from ${_tutorseekerName} has been successfully processed.",
        now);

    await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(widget.tutorId)
        .collection('StudentPayment')
        .add(studentPaymentData);
  }

  void _updateTutorSeeker(DateTime paymentDate, String paymentAmount,
      DateTime startClassDate, DateTime endClassDate) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDialog('Error', 'User not logged in');
      return;
    }
    String tutorseekerId = currentUser.uid;

    Map<String, dynamic> updateData = {
      'PaymentDate': paymentDate,
      'PaymentAmount': paymentAmount,
      'StartClassDate': startClassDate,
      'EndClassDate': endClassDate,
    };

    String documentId = "${widget.tutorId}_${widget.tutorPostId}";
    var toPayDocRef = FirebaseFirestore.instance
        .doc('Tutor Seeker/$tutorseekerId/ToPay/$documentId');
    var myTutorDocRef = FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(tutorseekerId)
        .collection('MyTutor')
        .doc(documentId);

    try {
      var docSnapshot = await toPayDocRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> existingData =
            docSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> mergedData = {...existingData, ...updateData};

        await myTutorDocRef.set(mergedData);

        await toPayDocRef.delete();
      } else {
        _showDialog('Error', 'Document does not exist');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to transfer data: $e');
    }

    Map<String, dynamic> paymentData = {
      'PaymentDate': paymentDate,
      'PaymentAmount': paymentAmount,
      'TutorId': widget.tutorId,
      'TutorName': _tutorName,
    };

    await FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(tutorseekerId)
        .collection('Payment')
        .add(paymentData);

    DocumentReference ApplicationRequestDocRef = FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(currentUser.uid)
        .collection('ApplicationRequest')
        .doc('${widget.tutorId}_${widget.tutorPostId}');

    DocumentSnapshot ApplicationRequestSnapshot =
        await ApplicationRequestDocRef.get();
    if (ApplicationRequestSnapshot.exists) {
      await ApplicationRequestDocRef.delete();
    }

    DateTime now = DateTime.now();

    StoreNotification().sendNotificationtoTutorSeeker(
        currentUser!.uid,
        "Payment Success",
        "Your payment for sessions with ${_tutorName} in ${widget.subject} has been successfully processed.",
        now);
  }

  @override
  Widget build(BuildContext context) {
    final stripePaymentHandle = StripePaymentHandle();
    String text = 'Payment Due: ${_dueDate}';

    print(widget.tutorId);

    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(_imageURL),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(_tutorName)),
                ],
              ),
              subtitle: Text(widget.subject),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoWithIcon(Icons.monetization_on, 'RM${widget.fees}'),
                  SizedBox(height: 8),
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
                          DocumentUrl: _DocumentUrl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.payment, size: 16.0),
                  label: Text('Pay Now'),
                  onPressed: () async {
                    bool result = await stripePaymentHandle
                        .stripeMakePayment(calculateFees());
                    if (result) {
                      DateTime paymentDate = DateTime.now();
                      int dayOfWeekNumber = getDayOfWeekNumber(widget.day);
                      DateTime startclassDate = _getNextClassDate(
                          paymentDate, dayOfWeekNumber, widget.startTime);
                      DateTime endclassDate =
                          _getEndDate(startclassDate, widget.endTime);
                      _updateTutor(paymentDate, removeCommisionFees(),
                          startclassDate, endclassDate);
                      updateAvailabilitySlots(
                          widget.day, widget.startTime, widget.endTime, widget.tutorId);

                      _updateTutorSeeker(paymentDate, calculateFees(),
                          startclassDate, endclassDate);
                      BuildContext currentContext = context;
                      Navigator.push(
                        currentContext,
                        MaterialPageRoute(
                          builder: (context) => PaymentConfirmationScreen(
                            tutorSeekerName: _tutorseekerName,
                            tutorName: _tutorName,
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

DateTime _getNextClassDate(
    DateTime paymentDate, int classDayOfWeek, String startTime) {
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

  List<String> timeParts = startTime.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  // Set the hour and minute to the nextClassDate
  nextClassDate = DateTime(
      nextClassDate.year, nextClassDate.month, nextClassDate.day, hour, minute);

  return nextClassDate;
}

DateTime _getEndDate(DateTime startDate, String endTime) {
  DateTime endDate = startDate.add(Duration(days: 4 * 7));

  List<String> parts = endTime.split(':');
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);

  endDate = DateTime(endDate.year, endDate.month, endDate.day, hour, minute);
  return endDate;
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
