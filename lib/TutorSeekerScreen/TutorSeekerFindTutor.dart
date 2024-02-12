import 'package:edumateapp/TutorSeekerScreen/Favorite.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorCard.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

//SHOULD HAVE SEARCH HISTORY

class TutorSeekerFindTutor extends StatefulWidget {
  const TutorSeekerFindTutor({Key? key}) : super(key: key);

  @override
  State<TutorSeekerFindTutor> createState() => _TutorSeekerFindTutorState();
}

class _TutorSeekerFindTutorState extends State<TutorSeekerFindTutor> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearching = false;
  String _searchTerm = '';
  bool _isClickingSearch = false;
  double _selectedRating = 0;
  String _selectedMode = 'any';
  RangeValues _priceRange = RangeValues(0, 100);
  List<int> _selectedRatings = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rating",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                children: List.generate(5, (index) {
                  int rating = index + 1;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedRatings.contains(rating)) {
                            _selectedRatings.remove(rating);
                          } else {
                            _selectedRatings.add(rating);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: _selectedRatings.contains(rating)
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                      child: Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              const Text(
                "Mode",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildModeButton('any', 'Any'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildModeButton('physical', 'Physical'),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildModeButton('online', 'Online'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildModeButton('hybrid', 'Hybrid'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              const Text(
                "Price Range",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 100, // Adjust the maximum price range as needed
                divisions: 100,
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
                labels: RangeLabels(
                  _priceRange.start.toStringAsFixed(2),
                  _priceRange.end.toStringAsFixed(2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ElevatedButton(
            onPressed: () {
              // Apply filters here
              Navigator.of(context).pop();
            },
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String mode, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        style: ElevatedButton.styleFrom(
          primary: _selectedMode == mode ? Colors.yellow : Colors.grey,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 115),
              ),
              child: Text(
                'Filter Options',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            ),
            _buildFilterOptions(),
          ],
        ),
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Find My Tutor',
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

                return ListView(
                  children: filteredDocs.map((document) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: document.reference
                          .collection('TutorPost')
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
                          String subject =
                              tutorPostDoc.get('SubjectsToTeach') ??
                                  'Subject not specified';
                          String fees = tutorPostDoc.get('RatePerHour') ??
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
                                      leading: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                String imageUrl = userProfileSnapshot
                                        .data!.exists
                                    ? userProfileSnapshot.data!.get('ImageUrl')
                                    : 'tutor_seeker_profile.png';

                                return TutorCard(
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
