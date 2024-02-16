import 'dart:convert';
import 'package:edumateapp/FCM/SendNotification.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:http/http.dart' as http;
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TutorSeekerPaymentHistory extends StatefulWidget {
  const TutorSeekerPaymentHistory({Key? key}) : super(key: key);

  @override
  _TutorSeekerPaymentHistoryState createState() => _TutorSeekerPaymentHistoryState();
}

class _TutorSeekerPaymentHistoryState extends State<TutorSeekerPaymentHistory> {
  late Stream<QuerySnapshot> _paymentStream;
  final String _tutorSeekerId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    // Initialize the payment stream
    _paymentStream = FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(_tutorSeekerId)
        .collection('Payment')
        .orderBy('PaymentDate', descending: true) 
        .snapshots();
  }

  String monthToString(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return 'Unknown';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _paymentStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No payment history found.'));
          }

          Map<String, List<DocumentSnapshot>> groupedPayments = {};
          for (var doc in snapshot.data!.docs) {
            DateTime paymentDate = (doc['PaymentDate'] as Timestamp).toDate();
             String monthYear = '${monthToString(paymentDate.month)} ${paymentDate.year}';
            if (!groupedPayments.containsKey(monthYear)) {
              groupedPayments[monthYear] = [];
            }
            groupedPayments[monthYear]!.add(doc);
          }

          return ListView(
            children: groupedPayments.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ...entry.value.map((doc) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: Icon(Icons.payment, color: Theme.of(context).primaryColor),
                        title: Text(doc['TutorName']),
                        subtitle: Text('Paid on ${DateFormat('dd MMM yyyy').format((doc['PaymentDate'] as Timestamp).toDate())}'),
                        trailing: Text('\RM${doc['PaymentAmount'].toString()}'),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
