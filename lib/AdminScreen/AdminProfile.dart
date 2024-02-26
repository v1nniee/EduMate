import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/AdminScreen/AdminSetting.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  late Future<DocumentSnapshot> _userProfileFuture;
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser!;
    _userProfileFuture = FirebaseFirestore.instance
        .collection('Admin')
        .doc(currentUser.uid)
        
        .get();
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
        backgroundColor: const Color.fromARGB(255, 16, 212, 252),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor:  Color.fromARGB(255, 16, 212, 252),
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
                 
                  return Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Card(
                      color: const Color.fromARGB(255, 240, 252, 252),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 50, // Adjust for a larger icon
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage('assets/images/tutor_seeker_profile.png'),
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
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminSetting()),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 16, 212, 252),
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
                      backgroundColor: const Color.fromARGB(255, 16, 212, 252),
                      minimumSize: const Size(
                          double.infinity, 50), // Make the button wider
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
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