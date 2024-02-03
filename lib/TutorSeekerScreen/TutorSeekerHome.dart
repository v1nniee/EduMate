import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Data/TutorSeekerData.dart';
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerRegistration.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:edumateapp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorSeekerHome extends StatelessWidget {
  const TutorSeekerHome({super.key});

  Future<String?> getUserType(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Tutor Seeker')
        .doc(userId)
        .get();
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.get('UserType');
    }
    return null;
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
          child: TutorSeekerRegistration(onSaved: () async {
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
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 230),
      body: Column(
        children: [
          const HomeHeader(backgroundColor: Color.fromARGB(255, 255, 255, 115)),
          const Expanded(
            child: CategoriesScreen(
                categories: TutorSeekerFunctionCategories,
                backgroundColor: Color.fromARGB(255, 255, 255, 230)),
          ),
          if (user != null)
            FutureBuilder<String?>(
              future: getUserType(user.uid),
              builder: (context, snapshot) {

                if (snapshot.data == "New Tutor Seeker") {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showRegistrationForm(context);
                  });
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}
