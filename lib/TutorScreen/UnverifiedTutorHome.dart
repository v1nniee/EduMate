import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Data/TutorData.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/Screen/Authenticate.dart';
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/TutorScreen/TutorRegistration.dart';
import 'package:edumateapp/TutorScreen/TutorTabScreen.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnverifiedTutorHome extends StatefulWidget {
  const UnverifiedTutorHome({super.key});

  @override
  State<UnverifiedTutorHome> createState() => _UnverifiedTutorHomeState();
}

class _UnverifiedTutorHomeState extends State<UnverifiedTutorHome> {
  String _status = '';

  Future<String> _fetchUserStatus(User? user) async {
    if (user == null) {
      return Future.error('No user logged in');
    }

    final tutorSnapshot = await FirebaseFirestore.instance
        .collection('Tutor')
        .doc(user.uid)
        .collection('UserProfile')
        .doc(user.uid)
        .get();

    if (tutorSnapshot.exists && tutorSnapshot.data() != null) {
      return tutorSnapshot.data()!['Status'] as String;
    } else {
      return 'Not found';
    }
  }

  void _showRegistrationForm(BuildContext context) {
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
          child: TutorRegistration(onSaved: () async {
            Navigator.of(ctx).pop(); // Close the TutorRegistration dialog
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Profile Saved'),
                content:
                    const Text('Your profile has been successfully saved.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the AlertDialog
                      setState(() {
                      _status = 'Unverified';
                    });
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildUserStatusBasedScreen(BuildContext context, String status) {
    if (status == 'Unverified') {
      return const UnverifiedTutorScreen();
    } else if (status == 'Rejected') {
      return const RejectedTutorScreen();
    } else {
      Future.microtask(() {
        if (ModalRoute.of(context)!.isCurrent) {
          _showRegistrationForm(context);
        }
      });
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 244, 236),
      body: Column(
        children: [
          const HomeHeader(backgroundColor: Color.fromARGB(255, 255, 116, 36)),
          Expanded(
            child: FutureBuilder<String>(
              future: _fetchUserStatus(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  final status = snapshot.data!;
                  return _buildUserStatusBasedScreen(context, status);
                }
                return const Text('No user data available');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UnverifiedTutorScreen extends StatelessWidget {
  const UnverifiedTutorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 244, 236),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 244, 236),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2, // Take up 2/3 of the screen height
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Register Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36, // Larger font size for the header
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.05), // Adjust the size as needed
                    Container(
                      padding: const EdgeInsets.all(
                          24), // More padding for larger card
                      margin: const EdgeInsets.symmetric(
                          horizontal: 24), // Larger horizontal margin
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners for the card
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Your profile is under review. Your information will be '
                        'updated once the review is done.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              18, // Slightly larger font size for the body
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ],
                ),
              ),
            ),
            Spacer(), // Push everything to the middle
          ],
        ),
      ),
    );
  }
}

class RejectedTutorScreen extends StatelessWidget {
  const RejectedTutorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 244, 236),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 244, 236),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2, // Take up 2/3 of the screen height
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Your registration have been rejected!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36, // Larger font size for the header
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.05), // Adjust the size as needed
                    Container(
                      padding: const EdgeInsets.all(
                          24), // More padding for larger card
                      margin: const EdgeInsets.symmetric(
                          horizontal: 24), // Larger horizontal margin
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners for the card
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Text(
                        'We regret to inform you that your registration has been rejected. '
                        'However, your profile is currently under review by our team. '
                        'We are evaluating the provided information and will update you '
                        'once the review process is complete. If you have any questions or need to '
                        'update your information, please contact support.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16, // Appropriate font size for body text
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ],
                ),
              ),
            ),
            Spacer(), // Push everything to the middle
          ],
        ),
      ),
    );
  }
}
