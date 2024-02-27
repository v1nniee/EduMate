import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerChat.dart';

class TutorSeekerTutorSearchScreen extends StatefulWidget {
  @override
  _TutorSeekerTutorSearchScreenState createState() =>
      _TutorSeekerTutorSearchScreenState();
}

class _TutorSeekerTutorSearchScreenState
    extends State<TutorSeekerTutorSearchScreen> {
  List<Map<String, dynamic>> tutors = [];
  List<Map<String, dynamic>> searchResults = [];
  late FocusNode _searchFocusNode; // Declare FocusNode

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(); // Initialize FocusNode
    fetchAllTutors();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  void searchTutor(String query) {
    final results = tutors.where((tutor) {
      final tutorName = tutor['Name'].toLowerCase();
      final input = query.toLowerCase();

      return tutorName.contains(input);
    }).toList();

    setState(() {
      searchResults = results;
    });
  }

  void fetchAllTutors() async {
    var results = await FirebaseFirestore.instance.collection('Tutor').get();
    setState(() {
      tutors =
          results.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Tutors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search for a Tutor',
                border: OutlineInputBorder(),
              ),
              onChanged: searchTutor,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final tutor = searchResults[index];
                return ListTile(
                  title: Text(tutor['Name']),
                  subtitle: Text(tutor['id']),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          TutorSeekerChat(ReceiverUserId: tutor['id']),
                    ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
