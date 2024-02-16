import 'package:edumateapp/TutorScreen/ApplicationDetails.dart';
import 'package:edumateapp/TutorScreen/TutorSeekerCard.dart';
import 'package:edumateapp/TutorSeekerScreen/ApplicationStatusTutorCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:edumateapp/TutorScreen/TutorSeekerCard.dart';

class TutorSeekerApplicationRequest extends StatefulWidget {
  const TutorSeekerApplicationRequest({Key? key}) : super(key: key);

  @override
  _TutorSeekerApplicationRequestState createState() =>
      _TutorSeekerApplicationRequestState();
}

class _TutorSeekerApplicationRequestState
    extends State<TutorSeekerApplicationRequest> {
  final TextEditingController _searchController = TextEditingController();
  

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<TutorSeekerCard>> _fetchApplicationRequests() async {
    List<TutorSeekerCard> cards = [];
    User currentUser = FirebaseAuth.instance.currentUser!;
    String tutorId = currentUser.uid;

    // Get the Application Requests for the current tutor
    var applicationRequests = await FirebaseFirestore.instance
        .collection('Tutor/$tutorId/ApplicationRequest')
        .get();

    for (var applicationRequest in applicationRequests.docs) {
      String seekerId = applicationRequest['TutorSeekerId'];
      String subject = applicationRequest['Subject'];
      String status = applicationRequest['Status'];
      String start = applicationRequest['StartTime'];
      String end = applicationRequest['EndTime'];
      String day = applicationRequest['Day'];
      String tutorPostId = applicationRequest['TutorPostId'];

      // Get the Tutor Seeker's User Profile
      var userProfile = await FirebaseFirestore.instance
          .collection('Tutor Seeker/$seekerId/UserProfile')
          .get();

      for (var profile in userProfile.docs) {
        String name = profile['Name'];
        String imageURL = profile[
            'ImageUrl']; // Make sure the field name matches your Firestore
        String grade =
            profile['Grade']; // Make sure the field name matches your Firestore
        String requirement = profile[
            'Requirement']; // Make sure the field name matches your Firestore

        // Create a TutorSeekerCard for each application
        TutorSeekerCard card = TutorSeekerCard(
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Tutor Seeker Application Request',
          ),
          
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<TutorSeekerCard>>(
              future: _fetchApplicationRequests(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TutorSeekerCard>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<TutorSeekerCard> cards = snapshot.data!;
                  return ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      // Implement search filtering logic if needed
                      TutorSeekerCard card = cards[index];
                      return card;
                    },
                  );
                } else {
                  return Center(child: Text('No application requests found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
