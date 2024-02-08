import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:flutter/material.dart';

class TutorDetailPage extends StatelessWidget {
  final String tutorId;
  final String tutorPostId;

  const TutorDetailPage({Key? key, required this.tutorId, required this.tutorPostId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            String tutorName = tutorData.get('Name') ?? 'Unavailable';

            return const Column(
              children: [
                PageHeader(
                  backgroundColor: Color.fromARGB(255, 255, 255, 115),
                  headerTitle: 'Tutor Details',
                ),
                SizedBox(height: 20),
                Card(
                  child: ListTile(
                    title: Text('Name: \nExperience:'))
                ),
                
              ],
            );
          },
        ),
      ),
    );
  }
}
