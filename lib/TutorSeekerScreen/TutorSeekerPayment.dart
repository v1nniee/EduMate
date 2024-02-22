import 'package:edumateapp/TutorSeekerScreen/Favorite.dart';
import 'package:edumateapp/TutorSeekerScreen/MyTutorCard.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerPaymentCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorCard.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class TutorSeekerPayment extends StatefulWidget {
  const TutorSeekerPayment({Key? key}) : super(key: key);

  @override
  State<TutorSeekerPayment> createState() => _TutorSeekerPaymentState();
}

class _TutorSeekerPaymentState extends State<TutorSeekerPayment> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchTerm = '';
  bool _isClickingSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            headerTitle: 'Payment',
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
                  return const Center(
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

                return ListView(
                  children: filteredDocs.map((document) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: document.reference
                          .collection('ToPayTutorSeeker')
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> tutorPostSnapshot) {
                        if (!tutorPostSnapshot.hasData) {
                          return const Card(
                            child: ListTile(
                              leading: CircularProgressIndicator(),
                            ),
                          );
                        }

                        var tutorPosts = tutorPostSnapshot.data!.docs;
                        List<Widget> tutorCards = [];

                        for (var tutorPostDoc in tutorPosts) {
                          String subject = tutorPostDoc.get('Subject') ??
                              'Subject not specified';
                          String fees = tutorPostDoc.get('RatePerClass') ??
                              'Rate not specified';

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
                                      leading: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                String imageUrl = userProfileSnapshot
                                        .data!.exists
                                    ? userProfileSnapshot.data!.get('ImageUrl')
                                    : 'tutor_seeker_profile.png';

                                return TutorSeekerPaymentCard(
                                  tutorId: document.id,
                                  tutorPostId: tutorPostDoc.id.split("_")[1],
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
