import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/Screen/Authenticate.dart';
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerRegistration.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerUpdateProfile.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:edumateapp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TutorSeekerProfile extends StatefulWidget {
  const TutorSeekerProfile({super.key});

  @override
  State<TutorSeekerProfile> createState() => _TutorSeekerProfileState();
}

class _TutorSeekerProfileState extends State<TutorSeekerProfile> {
  late Future<DocumentSnapshot> _userProfileFuture;
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser!;
    _userProfileFuture = FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(currentUser.uid)
        .collection('UserProfile')
        .doc(currentUser.uid)
        .get();
  }

  void _showUpdateProfileForm(
      BuildContext context, Map<String, dynamic> userData) {
    imageUrl = userData['ImageUrl'];
    print(imageUrl);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 230),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TutorSeekerUpdateProfile(
            onSaved: () async {
              Navigator.of(ctx).pop();
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profile Saved'),
                  content:
                      const Text('Your profile has been successfully saved.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );

              setState(() {
                _userProfileFuture = FirebaseFirestore.instance
                    .collection('Tutor Seeker')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('UserProfile')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get();
              });
            },
            name: userData['Name'] ?? 'N/A',
            gender: userData['Gender'] ?? 'N/A',
            date: userData['DOB'] ?? 'N/A',
            imageURL: userData['ImageUrl'] ??
                'assets/images/tutor_seeker_profile.png',
            mobileNumber: userData['MobileNumber'] ?? 'N/A',
            address: userData['Address'] ?? 'N/A',
            zip: userData['ZipCode'] ?? 'N/A',
            state: userData['State'] ?? 'N/A',
            city: userData['City'] ?? 'N/A',
            grade: userData['Grade'] ?? 'N/A',
            requirement: userData['Requirement'] ?? 'N/A',
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _getImageProvider() {
    if (imageUrl != null) {
      if (imageUrl!.startsWith('http')) {
        return NetworkImage(imageUrl!);
      } else {
        return AssetImage(imageUrl!);
      }
    } else {
      return AssetImage('assets/images/tutor_seeker_profile.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userTypeNotifier =
        Provider.of<UserTypeNotifier>(context, listen: false);
    final userType = userTypeNotifier.userType;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Account',
          ),
          FutureBuilder<DocumentSnapshot>(
            future: _userProfileFuture,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text("Error fetching user data");
                }
                if (snapshot.hasData) {
                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  imageUrl = userData['ImageUrl'];
                  return Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Card(
                      color: const Color.fromARGB(255, 255, 255,
                          230), 
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 50, // Adjust for a larger icon
                              backgroundColor: Colors.transparent,
                              backgroundImage: _getImageProvider(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Align text to the start (left)
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center the column vertically
                                children: [
                                  Text(
                                    userData['Name'] ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    userType ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: 30), // Adjust for a larger icon
                              onPressed: () =>
                                  _showUpdateProfileForm(context, userData),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
              return const CircularProgressIndicator();
            },
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to settings screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 115),
                      minimumSize: const Size(
                          double.infinity, 50), // Make the button wider
                    ),
                    child: const Text(
                      "Settings",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      // After logout, navigate user to the login screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 115),
                      minimumSize: const Size(
                          double.infinity, 50), // Make the button wider
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "<EduMate>",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
