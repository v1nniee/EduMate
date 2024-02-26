import 'package:edumateapp/TutorScreen/MyStudentCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class MyStudent extends StatefulWidget {
  const MyStudent({Key? key}) : super(key: key);

  @override
  State<MyStudent> createState() => _MyStudentState();
}

class _MyStudentState extends State<MyStudent> {

  
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 203, 173),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: const Color.fromARGB(255, 255, 116, 36),
            headerTitle: 'My Student',
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Tutor')
                  .doc(currentUserId)
                  .collection('MyStudent')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No My Student found.'));
                }

                // Directly use the documents to build the list
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var myStudentDoc = snapshot.data!.docs[index];
                    String subject = myStudentDoc.get('Subject') ?? 'Subject not specified';
                    DateTime startDate = (myStudentDoc.get('StartClassDate') as Timestamp).toDate();
                    DateTime endDate = (myStudentDoc.get('EndClassDate') as Timestamp).toDate();
                    String day = myStudentDoc.get('Day') ?? 'Day not specified';
                    String startTime = myStudentDoc.get('StartTime') ?? 'StartTime not specified';
                    String endTime = myStudentDoc.get('EndTime') ?? 'EndTime not specified';
                    String tutorSeekerId = myStudentDoc.get('TutorSeekerId') ?? 'TutorSeekerId not specified';
                    String tutorPostId = myStudentDoc.get('TutorPostId') ?? 'TutorPostId not specified';

                    return MyStudentCard(
                      tutorSeekerId: tutorSeekerId,
                      tutorPostId: tutorPostId,
                      subject: subject,
                      startClassDate: startDate,
                      endClassDate: endDate,
                      day: day,
                      startTime: startTime,
                      endTime: endTime,
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
