import 'package:edumateapp/TutorSeekerScreen/ApplicationStatusTutorCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class TutorSeekerApplicationStatus extends StatefulWidget {
  const TutorSeekerApplicationStatus({Key? key}) : super(key: key);

  @override
  State<TutorSeekerApplicationStatus> createState() =>
      _TutorSeekerApplicationStatusState();
}

class _TutorSeekerApplicationStatusState
    extends State<TutorSeekerApplicationStatus> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchTerm = '';
  bool _isClickingSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> getAppliedTutorIds(String userId) async {
    QuerySnapshot TutorsSnapshot = await FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(userId)
        .collection('ApplicationRequest')
        .where('Status', isNotEqualTo: 'paid')
        .get();

    List<String> documentIds = TutorsSnapshot.docs
        .map((doc) => doc.id.split('_')[0]) // Correctly splitting the ID.
        .toList();

    return documentIds;
  }

  Future<List<String>> getTutorPostIdsFromAppliedTutors(
      String userId, List<String> appliedTutorIds) async {
    List<String> documentIds = [];

    QuerySnapshot tutorDoc = await FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(userId)
        .collection('ApplicationRequest')
        .where('Status', isNotEqualTo: 'paid')
        .get();

    tutorDoc.docs.forEach((doc) {
      var parts = doc.id.split('_'); // Correct splitting
      if (appliedTutorIds.contains(parts[0])) {
        documentIds.add(parts[1]); // Assuming the format is [tutorId]_[postId]
      }
    });

    return documentIds;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Application Status',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: _isClickingSearch
                    ? IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchTerm = '';
                            _isClickingSearch = false;
                            _searchController.clear(); // Clear text field
                          });
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value.trim().toLowerCase();
                  _isSearching = _searchTerm.isNotEmpty;
                  _isClickingSearch = true;
                });
              },
              onTap: () {
                setState(() {
                  _isClickingSearch = true;
                });
              },
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Tutor').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (_searchTerm.isEmpty && _isClickingSearch) {
                  return SizedBox();
                }
                final filteredDocs = _searchTerm.isNotEmpty
                    ? snapshot.data!.docs.where((doc) {
                        final tutorName = doc['Name'].toString().toLowerCase();
                        return tutorName.contains(_searchTerm);
                      }).toList()
                    : snapshot.data!.docs;
                print(currentUser.uid);
                return FutureBuilder<List<String>>(
                  future: getAppliedTutorIds(currentUser.uid),
                  builder: (context, appliedTutorIdsSnapshot) {
                    if (appliedTutorIdsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (appliedTutorIdsSnapshot.hasError) {
                      return Text('Error: ${appliedTutorIdsSnapshot.error}');
                    } else if (appliedTutorIdsSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'There are no tutors applied now.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      return FutureBuilder<List<String>>(
                        future: getTutorPostIdsFromAppliedTutors(
                            currentUser.uid, appliedTutorIdsSnapshot.data!),
                        builder: (context, tutorPostIdsSnapshot) {
                          if (tutorPostIdsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (tutorPostIdsSnapshot.hasError) {
                            return Text('Error: ${tutorPostIdsSnapshot.error}');
                          } else if (appliedTutorIdsSnapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'There are no tutors applied now.',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final document = filteredDocs[index];
                                final tutorPostIds = tutorPostIdsSnapshot.data!;
                                return StreamBuilder<QuerySnapshot>(
                                  stream: document.reference
                                      .collection('TutorPost')
                                      .where(FieldPath.documentId,
                                          whereIn: tutorPostIds)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot>
                                          tutorPostSnapshot) {
                                    if (!tutorPostSnapshot.hasData) {
                                      return const Card(
                                        child: ListTile(
                                          leading: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    var tutorPosts =
                                        tutorPostSnapshot.data!.docs;
                                    List<Widget> tutorCards = [];

                                    for (var tutorPostDoc in tutorPosts) {
                                      String subject =
                                          tutorPostDoc.get('SubjectsToTeach') ??
                                              'Subject not specified';

                                      String fees =
                                          tutorPostDoc.get('RatePerClass') ??
                                              'Rate not specified';
                                      String tutorPostId = tutorPostDoc.id;

                                      tutorCards.add(
                                        FutureBuilder<DocumentSnapshot>(
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
                                                  leading:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            }
                                            String imageUrl;
                                            double rating = 0.1;
                                            int numberOfRating = 0;
                                            String DocumentUrl = "";

                                            if (userProfileSnapshot
                                                    .data?.exists ??
                                                false) {
                                              imageUrl = userProfileSnapshot
                                                      .data!
                                                      .get('ImageUrl') ??
                                                  'tutor_seeker_profile.png';
                                              rating = userProfileSnapshot.data!
                                                      .get('Rating') ??
                                                  0.1;
                                              numberOfRating =
                                                  userProfileSnapshot.data!.get(
                                                          'NumberOfRating') ??
                                                      0;
                                              DocumentUrl = userProfileSnapshot
                                                      .data!
                                                      .get('DocumentUrl') ??
                                                  "";
                                            } else {
                                              imageUrl =
                                                  'tutor_seeker_profile.png';
                                              rating = 0.1;
                                              numberOfRating = 0;
                                            }

                                            return ApplicationStatusTutorCard(
                                              tutorId: document.id,
                                              tutorPostId: tutorPostId,
                                              name: document['Name'],
                                              subject: subject,
                                              imageURL: imageUrl,
                                              rating: rating,
                                              numberOfRating: numberOfRating,
                                              DocumentUrl: DocumentUrl,
                                              fees: fees,
                                            );
                                          },
                                        ),
                                      );
                                    }

                                    return Column(children: tutorCards);
                                  },
                                );
                              },
                            );
                          }
                        },
                      );
                    }
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
