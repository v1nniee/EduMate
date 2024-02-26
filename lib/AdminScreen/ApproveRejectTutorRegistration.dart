import 'package:edumateapp/AdminScreen/ApproveRejectTutorRegistrationCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class ApproveRejectTutorRegistration extends StatefulWidget {
  const ApproveRejectTutorRegistration({Key? key}) : super(key: key);

  @override
  _ApproveRejectTutorRegistrationState createState() =>
      _ApproveRejectTutorRegistrationState();
}

class _ApproveRejectTutorRegistrationState
    extends State<ApproveRejectTutorRegistration> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<List<TutorRegistrationCard>> _fetchRegistrationRequests() async {
    List<TutorRegistrationCard> cards = [];
    User currentUser = FirebaseAuth.instance.currentUser!;
    String adminid = currentUser.uid;

    var registrationRequests = await FirebaseFirestore.instance
        .collection('Admin/$adminid/TutorRegistrationRequest')
        .get();
    if (registrationRequests.docs.isEmpty) {
      return cards;
    }

    for (var registrationRequests in registrationRequests.docs) {
      String tutorid = registrationRequests.id;
      String name = registrationRequests['Name'];
      String imageURL = registrationRequests['ImageUrl']??
                'assets/images/tutor_seeker_profile.png';
      String qualification = registrationRequests['HighestQualification'];
      String documentURL = registrationRequests['DocumentUrl'];

      

      TutorRegistrationCard card = TutorRegistrationCard(
        tutorId: tutorid,
        name: name,
        imageURL: imageURL,
        qualification: qualification,
        documentURL: documentURL,
      );

      cards.add(card);
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 16, 212, 252),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor:  Color.fromARGB(255, 16, 212, 252),
            headerTitle: 'Tutor Registration',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<TutorRegistrationCard>>(
              future: _fetchRegistrationRequests(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TutorRegistrationCard>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<TutorRegistrationCard> cards = snapshot.data!;
                  if (cards.isEmpty) {
                    return const Center(
                        child: Text('No tutor registration requests found.'));
                  } else {
                    return ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        // Implement search filtering logic if needed
                        TutorRegistrationCard card = cards[index];
                        return card;
                      },
                    );
                  }
                } else {
                  return const Center(child: Text('No tutor registration requests found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
