import 'package:edumateapp/TutorSeekerScreen/ApplicationStatusTutorCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class TutorSeekerApplicationRequest extends StatefulWidget {
  const TutorSeekerApplicationRequest({Key? key}) : super(key: key);

  @override
  State<TutorSeekerApplicationRequest> createState() =>
      _TutorSeekerApplicationRequestState();
}

class _TutorSeekerApplicationRequestState
    extends State<TutorSeekerApplicationRequest> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchTerm = '';
  bool _isClickingSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> getAppliedTutorSeekerIds(String userId) async {
    QuerySnapshot favoriteTutorsSnapshot = await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(userId)
        .collection('TutorApplication')
        .get();

    List<String> documentIds = [];
    favoriteTutorsSnapshot.docs.forEach((doc) {
      documentIds.add(doc.id);
    });

    return documentIds;
  }

  Future<List<String>> getTutorPostIdsFromAppliedTutors(
      String userId, List<String> appliedTutorSeekerIds) async {
    List<String> documentIds = [];

    for (String tutorSeekerId in appliedTutorSeekerIds) {
      QuerySnapshot tutorDoc = await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(userId)
          .collection('TutorApplication')
          .doc(tutorSeekerId)
          .collection('TutorPostApplication')
          .get();

      tutorDoc.docs.forEach((doc) {
        documentIds.add(doc.id);
      });
    }
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
            headerTitle: 'Tutor Seeker Application Request',
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
                            _searchController.clear(); 
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
                  return const CircularProgressIndicator();
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
                  future: getAppliedTutorSeekerIds(currentUser.uid),
                  builder: (context, appliedTutorIdsSnapshot) {
                    if (appliedTutorIdsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (appliedTutorIdsSnapshot.hasError) {
                      return Text('Error: ${appliedTutorIdsSnapshot.error}');
                    } else if (appliedTutorIdsSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'There are no tutor seekers applied now.',
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
                            return CircularProgressIndicator();
                          } else if (tutorPostIdsSnapshot.hasError) {
                            return Text('Error: ${tutorPostIdsSnapshot.error}');
                          } else if (appliedTutorIdsSnapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'There are no tutor seekers applied now.',
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
                                          tutorPostDoc.get('RatePerHour') ??
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

                                            String imageUrl =
                                                userProfileSnapshot.data!.exists
                                                    ? userProfileSnapshot.data!
                                                        .get('ImageUrl')
                                                    : 'tutor_seeker_profile.png';

                                            return ApplicationStatusTutorCard(
                                              tutorId: document.id,
                                              tutorPostId: tutorPostId,
                                              name: document['Name'],
                                              subject: subject,
                                              imageURL: imageUrl,
                                              rating: 4.0,
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