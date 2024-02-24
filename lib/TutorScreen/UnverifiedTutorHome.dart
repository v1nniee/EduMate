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

class UnverifiedTutorHome extends StatelessWidget {
  const UnverifiedTutorHome({super.key});

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

    // If there's a user, then let's check the userType and act accordingly
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userTypeNotifier =
            Provider.of<UserTypeNotifier>(context, listen: false);
        final userType = userTypeNotifier.userType;

        switch (userType) {
          case 'Unverified Tutor':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const UnverifiedTutorScreen()),
            );
            break;
          case 'New Tutor':
            _showRegistrationForm(context);
            break;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 244, 236),
      body: Column(
        children: [
          const HomeHeader(backgroundColor: Color.fromARGB(255, 255, 116, 36)),
          // Here you might want to show some content or a loading indicator
          user == null ? CircularProgressIndicator() : const SizedBox.shrink(),
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
      backgroundColor: const Color.fromARGB(255, 255, 116, 36),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // Replace with your route to the login screen
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthenticatePage()));
          },
        ),
      ],
    ),
      backgroundColor: const Color.fromARGB(255, 255, 244, 236),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HomeHeader(
                backgroundColor: Color.fromARGB(255, 255, 116, 36)),
            Spacer(), // Push everything to the middle
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
