import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';

class TutorSeekerDetails extends StatelessWidget {
  final String tutorSeekerid;
  final String imageURL;

  const TutorSeekerDetails({Key? key, required this.tutorSeekerid, required this.imageURL})
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

    var address;
    var city;
    var state;
    var zipcode;
    var gender;
    var mobilenumber;
    var name;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: firestore.collection('Tutor Seeker').doc(tutorSeekerid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Tutor not found."));
            }

            var tutorData = snapshot.data!;
            name = tutorData.get('Name') ?? 'Unavailable';

            return FutureBuilder<DocumentSnapshot>(
              future: firestore
                  .collection('Tutor Seeker')
                  .doc(tutorSeekerid)
                  .collection('UserProfile')
                  .doc(tutorSeekerid)
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> userProfileSnapshot) {
                if (userProfileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userProfileSnapshot.hasData || !userProfileSnapshot.data!.exists) {
                  return const Center(child: Text("User profile not found."));
                }

                var userProfileData = userProfileSnapshot.data!;
                mobilenumber = userProfileData.get('MobileNumber') ?? 'Unavailable';
                address = userProfileData.get('Address') ?? 'Unavailable';
                city = userProfileData.get('City') ?? 'Unavailable';
                state = userProfileData.get('State') ?? 'Unavailable';
                zipcode = userProfileData.get('ZipCode') ?? 'Unavailable';
                gender = userProfileData.get('Gender') ?? 'Unavailable';

                return Column(
                  children: [
                    const PageHeader(
                      backgroundColor: Color.fromARGB(255, 255, 116, 36),
                      headerTitle: 'Tutor Seeker Details',
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
                          buildInfoCard('Name', name, Icons.person),
                          buildInfoCard('Gender', gender, Icons.transgender),
                          buildInfoCard('Mobile Number', mobilenumber, Icons.phone),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                buildInfoCard('Address', address, Icons.home),
                                buildInfoCard('City', city, Icons.location_city),
                                buildInfoCard('State', state, Icons.map),
                                buildInfoCard('Zip Code', zipcode, Icons.pin_drop),
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
