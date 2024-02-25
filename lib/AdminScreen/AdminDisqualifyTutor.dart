import 'package:edumateapp/AdminScreen/DisqualifyTutorCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';


class AdminDisqualifyTutor extends StatefulWidget {
  const AdminDisqualifyTutor({Key? key}) : super(key: key);

  @override
  _AdminDisqualifyTutorState createState() => _AdminDisqualifyTutorState();
}

class _AdminDisqualifyTutorState extends State<AdminDisqualifyTutor> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<DisqualifyTutorCard>> _fetchApplicationRequests() async {
    List<DisqualifyTutorCard> cards = [];
    User currentUser = FirebaseAuth.instance.currentUser!;
    String adminId = currentUser.uid;

    // Get the Application Requests for the current tutor
    var TutorUnderRate = await FirebaseFirestore.instance
        .collection('Admin/$adminId/TutorUnderRate')
        .get();
    if (TutorUnderRate.docs.isEmpty) {
      return cards;
    }

    for (var tutor in TutorUnderRate.docs) {
      String tutorId = tutor['TutorId'];
      String name = tutor['Name'];
      double rate = tutor['Rate'];
      String imageURL = tutor['ImageUrl']??'assets/images/tutor_seeker_profile.png';
      int numberofRating = tutor['NumberOfRating'];

      DisqualifyTutorCard card = DisqualifyTutorCard(
        tutorId: tutorId,
        name: name,
        imageURL: imageURL,
        rate: rate,
        numberofRating: numberofRating,
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
            backgroundColor: const Color.fromARGB(255, 16, 212, 252),
            headerTitle: 'Tutor Disqualification',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<DisqualifyTutorCard>>(
              future: _fetchApplicationRequests(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DisqualifyTutorCard>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<DisqualifyTutorCard> cards = snapshot.data!;
                  if (cards.isEmpty) {
                    return const Center(
                        child: Text('No tutor under 2.0 found.'));
                  } else {
                    return ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        // Implement search filtering logic if needed
                        DisqualifyTutorCard card = cards[index];
                        return card;
                      },
                    );
                  }
                } else {
                  return Center(child: Text('No tutor under 2.0 found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
