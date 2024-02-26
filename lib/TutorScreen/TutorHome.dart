import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Data/TutorData.dart';
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({super.key});

  @override
  State<TutorHome> createState() => _TutorHomeState();
}

class _TutorHomeState extends State<TutorHome> {
  late Future<String?> _statusFuture;
  bool _navigatedToDisqualify = false;
  @override
  void initState() {
    super.initState();
    _statusFuture = _getStatus();
  }

  Future<String?> getUserType(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Tutor').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.get('UserType');
    }
    return null;
  }

  Future<String?> _getStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('Status');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 203, 173),
      body: FutureBuilder<String?>(
        future: _getStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Check if the status is 'Rejected'
            if (snapshot.data == "Deleted") {
              return DisqualifyTutor();
            }
            // Display the main content of TutorHome if status is not 'Rejected'
            return const Column(
              children: [
                HomeHeader(backgroundColor: Color.fromARGB(255, 255, 116, 36)),
                Expanded(
                  child: CategoriesScreen(
                      categories: TutorFunctionCategories,
                      backgroundColor: Color.fromARGB(255, 255, 244, 236),
                      fontSize: 15,
                      iconSize: 30,
                      imageSize: 40),
                ),
              ],
            );
          } else {
            // Display a loading spinner while waiting for the data
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class DisqualifyTutor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 244, 236),
      body: const Column(
        children: [
          HomeHeader(backgroundColor: Color.fromARGB(255, 255, 116, 36)),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 100,
                      color: Color.fromARGB(255, 255, 116, 36),
                    ),
                    Text(
                      'You Have Been Disqualified',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your account has been disqualified due to violation of our terms of service or low performance ratings. For more information, please contact support.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
