import 'package:edumateapp/TutorSeekerScreen/Favorite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorCard.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

//cannot remove favorite directly from the screen yet

class FavoriteTutor extends StatefulWidget {
  const FavoriteTutor({Key? key}) : super(key: key);

  @override
  State<FavoriteTutor> createState() => _FavoriteTutorState();
}

class _FavoriteTutorState extends State<FavoriteTutor> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchTerm = '';
  bool _isClickingSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> getFavoriteTutorIds(String userId) async {
    QuerySnapshot favoriteTutorsSnapshot = await FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(userId)
        .collection('FavoriteTutors')
        .get();

    List<String> documentIds = [];
    favoriteTutorsSnapshot.docs.forEach((doc) {
      documentIds.add(doc.id);
    });

    return documentIds;
  }

  Future<List<String>> getTutorPostIdsFromFavoriteTutors(
      String userId, List<String> favoriteTutorIds) async {
    List<String> tutorPostIds = [];

    for (String tutorId in favoriteTutorIds) {
      DocumentSnapshot tutorDoc = await FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(userId)
          .collection('FavoriteTutors')
          .doc(tutorId)
          .get();

      if (tutorDoc.exists) {
        List<dynamic> tutorPostIdsFromDoc =
            tutorDoc.get('tutorPostIds') as List<dynamic>;
        tutorPostIds
            .addAll(tutorPostIdsFromDoc.map((postId) => postId.toString()));
      }
    }

    return tutorPostIds;
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
            headerTitle: 'Favorite',
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

                return FutureBuilder<List<String>>(
                  future: getFavoriteTutorIds(currentUser.uid),
                  builder: (context, favoriteTutorIdsSnapshot) {
                    if (favoriteTutorIdsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (favoriteTutorIdsSnapshot.hasError) {
                      return Text('Error: ${favoriteTutorIdsSnapshot.error}');
                    } else if (favoriteTutorIdsSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'There are no favorite tutors now.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      return FutureBuilder<List<String>>(
                        future: getTutorPostIdsFromFavoriteTutors(
                            currentUser.uid, favoriteTutorIdsSnapshot.data!),
                        builder: (context, tutorPostIdsSnapshot) {
                          if (tutorPostIdsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (tutorPostIdsSnapshot.hasError) {
                            return Text('Error: ${tutorPostIdsSnapshot.error}');
                          } else if (favoriteTutorIdsSnapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'There are no favorite tutors now.',
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
                                      String mode = tutorPostDoc.get('Mode') ??
                                          'Mode not specified';
                                      String tutorPostId = tutorPostDoc.id;
                                      String imageUrl =
                                          tutorPostDoc.get('ImageUrl') ??
                                              'tutor_seeker_profile.png';

                                      return TutorCard(
                                        tutorId: document.id,
                                        tutorPostId: tutorPostId,
                                        name: document['Name'],
                                        subject: subject,
                                        imageURL: imageUrl,
                                        rating: 4.0,
                                        fees: fees,
                                        mode: mode,
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
