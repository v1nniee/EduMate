import 'package:edumateapp/TutorSeekerScreen/Favorite.dart';
import 'package:edumateapp/TutorSeekerScreen/MyTutorCard.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerPaymentCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorCard.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';


class TutorSeekerPayment extends StatefulWidget {
  const TutorSeekerPayment({Key? key}) : super(key: key);

  @override
  State<TutorSeekerPayment> createState() => _TutorSeekerPaymentState();
}

class _TutorSeekerPaymentState extends State<TutorSeekerPayment> {
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Payment',
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Tutor Seeker')
                  .doc(currentUserId)
                  .collection('ToPay')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Pending Payment Found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                // Directly use the documents to build the list
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var toPayDoc = snapshot.data!.docs[index];
                    String subject = toPayDoc.get('Subject') ?? 'Subject not specified';
                    String day = toPayDoc.get('Day') ?? 'Day not specified';
                    String startTime = toPayDoc.get('StartTime') ?? 'StartTime not specified';
                    String endTime = toPayDoc.get('EndTime') ?? 'EndTime not specified';
                    String TutorId = toPayDoc.get('TutorId') ?? 'TutorSeekerId not specified';
                    String tutorPostId = toPayDoc.get('TutorPostId') ?? 'TutorPostId not specified';
                    String ratePerClass = toPayDoc.get('RatePerClass') ?? 'ratePerClass not specified';
                    DateTime acceptedDate = toPayDoc.get('AcceptedDate').toDate();

                    return TutorSeekerPaymentCard(
                      tutorId: TutorId,
                      tutorPostId: tutorPostId,
                      subject: subject,
                      day: day,
                      startTime: startTime,
                      endTime: endTime,
                      fees: ratePerClass,
                      acceptedDate: acceptedDate,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

