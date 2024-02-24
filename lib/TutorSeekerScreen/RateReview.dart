import 'package:edumateapp/TutorSeekerScreen/RateReviewCard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class RateReview extends StatefulWidget {
  const RateReview({Key? key}) : super(key: key);

  @override
  State<RateReview> createState() => _RateReviewState();
}

class _RateReviewState extends State<RateReview> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final myTutorRef = FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(currentUser.uid)
        .collection('MyTutor');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Rate and Review',
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: myTutorRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No tutors found in "MyTutor".'));
                }

                final tutorPosts = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tutorPosts.length,
                  itemBuilder: (context, index) {
                    final tutorPostDoc = tutorPosts[index];
                    String subject =
                        tutorPostDoc.get('Subject') ?? 'Subject not specified';
                    String fees = tutorPostDoc.get('RatePerClass') ??
                        'Rate not specified';
                    String tutorPostId = tutorPostDoc.get('TutorPostId');
                    String tutorId = tutorPostDoc.get('TutorId');
                    return RateReviewCard(
                      tutorId: tutorId,
                      tutorPostId: tutorPostId,
                      subject: subject,
                      fees: fees,
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
