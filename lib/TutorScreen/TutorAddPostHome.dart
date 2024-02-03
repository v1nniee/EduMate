import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Data/TutorSeekerData.dart';
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/TutorScreen/TutorAddPost.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorAddPostHome extends StatelessWidget {
  const TutorAddPostHome({super.key});

  Future<String?> getUserType(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Tutor').doc(userId).get();
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.get('UserType');
    }
    return null;
  }

  void _showAddPostForm(BuildContext context) {
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
          child: TutorAddPost(onSaved: () async {
            Navigator.of(ctx).pop();
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Post Added'),
                content: const Text('Your post has been successfully added.'),
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
          const PageHeader(
              backgroundColor: const Color.fromARGB(255, 255, 255, 115),
              headerTitle: "Tutor Add Post"),
          if (user != null)
            FutureBuilder<String?>(
              future: getUserType(user.uid),
              builder: (context, snapshot) {
                if (snapshot.data == "New Tutor") {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showAddPostForm(context);
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
