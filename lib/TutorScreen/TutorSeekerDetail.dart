import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';



class TutorSeekerDetail extends StatelessWidget {
  final String tutorId;
  final String tutorPostId;

  const TutorSeekerDetail(
      {Key? key, required this.tutorId, required this.tutorPostId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String tutorName;
    var rate;
    var mode;
    var subject;
    var aboutMe;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: firestore.collection('Tutor').doc(tutorId).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Tutor not found."));
            }

            var tutorData = snapshot.data!;
            tutorName = tutorData.get('Name') ?? 'Unavailable';

            return FutureBuilder<DocumentSnapshot>(
              future: firestore
                  .collection('Tutor')
                  .doc(tutorId)
                  .collection('TutorPost')
                  .doc(tutorPostId)
                  .get(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot> tutorPostSnapshot) {
                if (tutorPostSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!tutorPostSnapshot.hasData ||
                    !tutorPostSnapshot.data!.exists) {
                  return const Center(child: Text("Tutor post not found."));
                }

                var tutorPostData = tutorPostSnapshot.data!;
                mode = tutorPostData.get('Mode') ?? 'Unavailable';
                subject = tutorPostData.get('SubjectsToTeach') ?? 'Unavailable';
                rate = tutorPostData.get('RatePerHour') ?? 'Unavailable';

                return FutureBuilder<DocumentSnapshot>(
                  future: firestore
                      .collection('Tutor')
                      .doc(tutorId)
                      .collection('UserProfile')
                      .doc(tutorId)
                      .get(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot> userProfileSnapshot) {
                    if (userProfileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!userProfileSnapshot.hasData ||
                        !userProfileSnapshot.data!.exists) {
                      return const Center(child: Text("User profile not found."));
                    }

                    var userProfileData = userProfileSnapshot.data!;
                    aboutMe = userProfileData.get('AboutMe') ?? 'Unavailable';

                    return Column(
                      children: [
                        const PageHeader(
                          backgroundColor: Color.fromARGB(255, 255, 255, 115),
                          headerTitle: 'Tutor Details',
                        ),
                        SizedBox(height: 20),
                        Card(
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: $tutorName'),
                                Text('Rate/hour: RM$rate'),
                                Text('Mode: $mode'),
                                Text('Subject: $subject'),
                                Text('About Me: $aboutMe'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
