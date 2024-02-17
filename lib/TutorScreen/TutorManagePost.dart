import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorManagePost extends StatefulWidget {
  const TutorManagePost({Key? key}) : super(key: key);

  @override
  _TutorManagePostState createState() => _TutorManagePostState();
}

class _TutorManagePostState extends State<TutorManagePost> {
  late Stream<QuerySnapshot> _tutorPostStream;
  final String _tutorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    _tutorPostStream = FirebaseFirestore.instance
        .collection('Tutor')
        .doc(_tutorId)
        .collection('TutorPost')
        .snapshots();
  }

  Future<void> _deleteTutorPost(String tutorPostId) async {
    await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(_tutorId)
        .collection('TutorPost')
        .doc(tutorPostId)
        .delete();
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
            headerTitle: 'Manage Post',
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tutorPostStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tutor post found.'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        leading: Icon(Icons.book, // Use a suitable icon
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          doc['SubjectsToTeach'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rate: RM ${doc['RatePerHour']}'),
                            Text('Mode: ${doc['Mode']}'),
                            Text('Teaching Level: ${doc['LevelofTeaching']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Tutor Post?'),
                                  content: Text(
                                    'Are you sure you want to delete this tutor post?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteTutorPost(doc.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
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
