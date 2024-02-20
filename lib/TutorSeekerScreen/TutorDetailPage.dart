import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
                rate = tutorPostData.get('RatePerClass') ?? 'Unavailable';
                teachingLevel =
                    tutorPostData.get('LevelofTeaching') ?? 'Unavailable';

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
                              buildInfoCard('Level of Teaching', subject,
                                  Icons.leaderboard),
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
                        Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Reviews',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              FutureBuilder<QuerySnapshot>(
                                future: firestore
                                    .collection('Tutor')
                                    .doc(tutorId)
                                    .collection('RatingsAndReviews')
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: Text("No reviews available."));
                                  }
                                  // Extract and display reviews
                                  return Column(
                                    children: snapshot.data!.docs
                                        .map((DocumentSnapshot doc) {
                                      Map<String, dynamic> data =
                                          doc.data() as Map<String, dynamic>;
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            RatingBar.builder(
                                              initialRating: data['Rating'],
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemSize: 20,
                                              itemPadding: const EdgeInsets.symmetric(
                                                  horizontal: 2.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                              },
                                            ),
                                            SizedBox(width: 8),
                                            
                                          ],
                                        ),
                                        subtitle: Text(data['Review']),
                                      );
                                    }).toList(),
                                  );
                                },
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
