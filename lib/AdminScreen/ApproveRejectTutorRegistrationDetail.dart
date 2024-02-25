import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ApproveRejectTutorRegistrationDetail extends StatelessWidget {
  final String tutorId;

  const ApproveRejectTutorRegistrationDetail({
    Key? key,
    required this.tutorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buildInfoCard(String title, dynamic value, IconData icon) {
      return ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.toString()),
      );
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 16, 212, 252),
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
            String tutorName = tutorData.get('Name') ?? 'Unavailable';

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
                var aboutMe = userProfileData.get('AboutMe') ?? 'Unavailable';
                var address = userProfileData.get('Address') ?? 'Unavailable';
                var city = userProfileData.get('City') ?? 'Unavailable';
                var state = userProfileData.get('State') ?? 'Unavailable';
                var zipcode = userProfileData.get('ZipCode') ?? 'Unavailable';
                var gender = userProfileData.get('Gender') ?? 'Unavailable';
                var qualification =
                    userProfileData.get('HighestQualification') ??
                        'Unavailable';
                var mobileNumber = userProfileData.get('MobileNumber') ?? 0;
                var imageURL = userProfileData.get('ImageUrl') ??
                    'assets/images/tutor_seeker_profile.png';

                return Column(
                  children: [
                    // Ensure PageHeader is defined elsewhere
                    const PageHeader(
                      backgroundColor: const Color.fromARGB(255, 16, 212, 252),
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
                          buildInfoCard('Gender', gender, Icons.transgender),
                          buildInfoCard('Mobile Number',
                              mobileNumber.toString(), Icons.phone),
                          buildInfoCard('Highest Qualification', qualification,
                              Icons.school),
                          buildInfoCard('About Me', aboutMe, Icons.info),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                buildInfoCard('Address', address, Icons.home),
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
        ),
      ),
    );
  }
}
