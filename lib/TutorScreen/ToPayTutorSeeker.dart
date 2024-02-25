import 'package:edumateapp/TutorScreen/ApplicationDetails.dart';
import 'package:edumateapp/TutorScreen/MyStudentCard.dart';
import 'package:edumateapp/TutorScreen/ToPayTutorSeekerCard.dart';
import 'package:edumateapp/TutorSeekerScreen/ApplicationStatusTutorCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class ToPayTutorSeeker extends StatefulWidget {
  const ToPayTutorSeeker({Key? key}) : super(key: key);

  @override
  _ToPayTutorSeekerState createState() => _ToPayTutorSeekerState();
}

class _ToPayTutorSeekerState extends State<ToPayTutorSeeker> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime convertTimestampToDateTime(Timestamp timestamp) {
  return timestamp.toDate();
}

  Future<List<ToPayTutorSeekerCard>> _fetchApplicationRequests() async {
    List<ToPayTutorSeekerCard> cards = [];
    User currentUser = FirebaseAuth.instance.currentUser!;
    String tutorId = currentUser.uid;

    // Get the Application Requests for the current tutor
    var ToPayTutorSeekers = await FirebaseFirestore.instance
        .collection('Tutor/$tutorId/ToPayTutorSeeker')
        .get();

    if (ToPayTutorSeekers.size == 0) {
      return cards;
    }

    for (var applicationRequest in ToPayTutorSeekers.docs) {
      String seekerId = applicationRequest['TutorSeekerId'];
      String subject = applicationRequest['Subject'];
      String status = applicationRequest['Status'];
      String start = applicationRequest['StartTime'];
      String end = applicationRequest['EndTime'];
      String day = applicationRequest['Day'];
      DateTime acceptedDate = applicationRequest['AcceptedDate'].toDate();
      String tutorPostId = applicationRequest['TutorPostId'];

      var userProfile = await FirebaseFirestore.instance
          .collection('Tutor Seeker/$seekerId/UserProfile')
          .get();

      for (var profile in userProfile.docs) {
        String name = profile['Name'];
        String imageURL = profile['ImageUrl'];
        String grade = profile['Grade'];
        String requirement = profile['Requirement'];

        ToPayTutorSeekerCard card = ToPayTutorSeekerCard(
          tutorseekerId: seekerId,
          tutorPostId: tutorPostId,
          name: name,
          imageURL: imageURL,
          subject: subject,
          grade: grade,
          requirement: requirement,
          status: status,
          StartTime: start,
          EndTime: end,
          Day: day,
          AcceptedDate: acceptedDate,
        );

        cards.add(card);
      }
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
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
            headerTitle: 'Pending Payment',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<ToPayTutorSeekerCard>>(
              future: _fetchApplicationRequests(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<ToPayTutorSeekerCard>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<ToPayTutorSeekerCard> cards = snapshot.data!;
                  if (cards.isEmpty) {
                    return Center(child: Text('No to pay tutor seeker yet.'));
                  } else {
                    return ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        ToPayTutorSeekerCard card = cards[index];
                        return card;
                      },
                    );
                  }
                } else {
                  return Center(child: Text('No to pay tutor seeker found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
