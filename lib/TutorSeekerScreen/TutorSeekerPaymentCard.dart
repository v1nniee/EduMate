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

  DateTime? _acceptedDate;
  DateTime? _dueDate;
  String _tutorseekerName = '';
  String _day = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadAcceptedDate();
  }

  Future<void> _loadAcceptedDate() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Fetch the status of the tutor post application
      DocumentSnapshot tutorPostApplicationSnapshot = await FirebaseFirestore
          .instance
          .collection('Tutor Seeker')
          .doc(user?.uid)
          .collection('ToPay')
          .doc('${widget.tutorId}_${widget.tutorPostId}')
          .get();

      if (tutorPostApplicationSnapshot.exists) {
        setState(() {
          _acceptedDate =
              tutorPostApplicationSnapshot.get('AcceptedDate').toDate();
          _day = tutorPostApplicationSnapshot.get('Day');
          ;
        });
        _dueDate = _acceptedDate?.add(Duration(days: 7));
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
    // Parse the fees String to a double
    int fees = int.tryParse(widget.fees) ?? 0;

    int updatedFees = (fees * 4);

    // Convert back to String and return
    return updatedFees.toStringAsFixed(0);
  }

  String removeCommisionFees() {
    // Parse the fees String to a double
    int fees = int.tryParse(widget.fees) ?? 0;

    int updatedFees = (fees * 4) - 10;

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
      'TutorName': widget.name,
    };

    await FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(tutorseekerId)
        .collection('Payment')
        .add(paymentData);
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
                backgroundImage: NetworkImage(widget.imageURL),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(widget.name)),
                ],
              ),
              subtitle: Text(widget.subject),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoWithIcon(Icons.star,
                      'Rating: ${widget.rating.toStringAsFixed(1)}'),
                  _buildInfoWithIcon(Icons.monetization_on, 'RM${widget.fees}'),
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
                ElevatedButton.icon(
                  icon: Icon(Icons.payment, size: 16.0),
                  label: Text('Pay Now'),
                  onPressed: () async {
                    bool result = await stripePaymentHandle
                        .stripeMakePayment(calculateFees());
                    if (result) {
                      print("hi");
                      DateTime paymentDate = DateTime.now();
                      print(_day);
                      int dayOfWeekNumber = getDayOfWeekNumber(_day);
                      
                      // Define startclassDate and endclassDate before the async gap
                      DateTime startclassDate =
                          _getNextClassDate(paymentDate, dayOfWeekNumber);
                      DateTime endclassDate = _getEndDate(startclassDate);

                      // Update the payment details
                      _updateTutor(paymentDate, removeCommisionFees(),
                          startclassDate, endclassDate);

                      _updateTutorSeeker(paymentDate, calculateFees(),
                          startclassDate, endclassDate);

                      // Store the BuildContext in a variable before the async operation
                      BuildContext currentContext = context;

                      // Use the stored context to navigate to the next screen after the async operation
                      Navigator.push(
                        currentContext,
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

DateTime _getNextClassDate(DateTime paymentDate, int classDayOfWeek) {
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

Widget _buildInfoWithIcon(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16.0),
      SizedBox(width: 4.0),
      Text(text),
    ],
  );
}
