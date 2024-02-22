import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/MyTutorCard.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class MyTutor extends StatefulWidget {
  const MyTutor({Key? key}) : super(key: key);

  @override
  State<MyTutor> createState() => _MyTutorState();
}

class _MyTutorState extends State<MyTutor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'My Tutor',
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Tutor Seeker')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                 return const Center(
                        child: Text(
                          'There are no my tutors now.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                }

                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    // This StreamBuilder listens for changes in the 'mytutor' collection for each TutorSeeker document.
                    return StreamBuilder<QuerySnapshot>(
                      stream:
                          document.reference.collection('MyTutor').snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> tutorPostSnapshot) {
                        // Check if there's data and the 'mytutor' collection is not empty.
                        if (!tutorPostSnapshot.hasData) {
                          return const Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (tutorPostSnapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No My Tutor found.'),
                          );
                        }

                        var tutorPosts = tutorPostSnapshot.data!.docs;

                        return Column(
                          children: tutorPosts.map((tutorPostDoc) {
                            String subject = tutorPostDoc.get('Subject') ??
                                'Subject not specified';
                            DateTime startDate =
                                tutorPostDoc.get('StartClassDate').toDate();
                            DateTime endDate =
                                tutorPostDoc.get('EndClassDate').toDate();
                            String day =
                                tutorPostDoc.get('Day') ?? 'Day not specified';
                            String startTime = tutorPostDoc.get('StartTime') ??
                                'StartTime not specified';
                            String endTime = tutorPostDoc.get('EndTime') ??
                                'EndTime not specified';
                             String TutorId = tutorPostDoc.get('TutorId') ??
                                'TutorId not specified';

                            String TutorPostId = tutorPostDoc.get('TutorPostId') ??
                                'TutorPostId not specified';

                            return MyTutorCard(
                              tutorId: TutorId,
                              tutorPostId: TutorPostId,
                              subject: subject,
                              startClassDate: startDate,
                              endClassDate: endDate,
                              day: day,
                              startTime: startTime,
                              endTime: endTime,
                            );
                          }).toList(),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
