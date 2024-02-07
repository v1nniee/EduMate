import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorCard.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';

class TutorSeekerFindTutor extends StatelessWidget {
  const TutorSeekerFindTutor({super.key});

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
            headerTitle: 'Find a Tutor',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // You can use setState and filter your list based on the search term
              },
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Tutor').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    return FutureBuilder<QuerySnapshot>(
                      future: document.reference.collection('TutorPost').get(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> tutorPostSnapshot) {
                        if (!tutorPostSnapshot.hasData) {
                          // Show a loading indicator or a placeholder card
                          return const Card(
                            child: ListTile(
                              leading: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Extract the data from TutorPost
                        String subject = tutorPostSnapshot.data!.docs.isNotEmpty
                            ? tutorPostSnapshot.data!.docs.first
                                .get('SubjectsToTeach')
                            : 'Subject not specified';

                        // Now fetch the UserProfile data
                        return FutureBuilder<DocumentSnapshot>(
                          future: document.reference
                              .collection('UserProfile')
                              .doc(document.id)
                              .get(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot>
                                  userProfileSnapshot) {
                            if (!userProfileSnapshot.hasData) {
                              return const Card(
                                child: ListTile(
                                  leading: CircularProgressIndicator(),
                                ),
                              );
                            }

                            // Extract the image URL from UserProfile
                            String imageUrl = userProfileSnapshot.data!.exists
                                ? userProfileSnapshot.data!.get('ImageUrl')
                                : 'default_image_url_here'; // Provide a default image URL

                            return TutorCard(
                              tutorId: document.id,
                              name: document['Name'],
                              subject: subject,
                              imageURL: imageUrl,
                            );
                          },
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
