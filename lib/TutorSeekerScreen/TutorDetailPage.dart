import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';

class TutorDetailPage extends StatelessWidget {
  final String tutorId;
  final String tutorPostId;
  final String imageURL;

  const TutorDetailPage(
      {Key? key,
      required this.tutorId,
      required this.tutorPostId,
      required this.imageURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buildInfoCard(String title, String value, IconData icon) {
      return ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      );
    }

    String tutorName;
    var rate;
    var mode;
    var subject;
    var aboutMe;
    var address;
    var city;
    var state;
    var zipcode;
    var gender;
    var teachingLevel;

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
              builder:
                  (context, AsyncSnapshot<DocumentSnapshot> tutorPostSnapshot) {
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
                teachingLevel = tutorPostData.get('LevelofTeaching') ?? 'Unavailable';

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
                      return const Center(
                          child: Text("User profile not found."));
                    }

                    var userProfileData = userProfileSnapshot.data!;
                    aboutMe = userProfileData.get('AboutMe') ?? 'Unavailable';
                    address = userProfileData.get('Address') ?? 'Unavailable';
                    city = userProfileData.get('City') ?? 'Unavailable';
                    state = userProfileData.get('State') ?? 'Unavailable';
                    zipcode = userProfileData.get('ZipCode') ?? 'Unavailable';
                    gender = userProfileData.get('Gender') ?? 'Unavailable';

                    return Column(
                      children: [
                        const PageHeader(
                          backgroundColor: Color.fromARGB(255, 255, 255, 115),
                          headerTitle: 'Tutor Details',
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(imageURL),
                              ),
                              SizedBox(height: 10),
                              buildInfoCard('Name', tutorName, Icons.person),
                              buildInfoCard(
                                  'Gender', gender, Icons.transgender),
                              buildInfoCard(
                                  'Fees/class', 'RM$rate', Icons.money),
                              buildInfoCard('Mode', mode, Icons.computer),
                              buildInfoCard('Subject', subject, Icons.book),
                              buildInfoCard('Level of Teaching', subject, Icons.leaderboard),
                              buildInfoCard('About Me', aboutMe, Icons.info),
                              if (mode != "Online")
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      buildInfoCard(
                                          'Address', address, Icons.home),
                                      buildInfoCard(
                                          'City', city, Icons.location_city),
                                      buildInfoCard('State', state, Icons.map),
                                      buildInfoCard(
                                          'Zip Code', zipcode, Icons.pin_drop),
                                    ],
                                  ),
                                ),
                            ],
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
