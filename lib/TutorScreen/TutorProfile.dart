import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/TutorScreen/EditTutorProfile.dart';
import 'package:edumateapp/TutorScreen/TutorSetting.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TutorProfile extends StatefulWidget {
  const TutorProfile({super.key});

  @override
  State<TutorProfile> createState() => _TutorProfileState();
}

class _TutorProfileState extends State<TutorProfile> {
  late Future<DocumentSnapshot> _userProfileFuture;
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser!;
    _userProfileFuture = FirebaseFirestore.instance
        .collection('Tutor')
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
            color: const Color.fromARGB(255, 255, 244, 236),
            borderRadius: BorderRadius.circular(15),
          ),
          child: EditTutorProfile(
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
                    .collection('Tutor')
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
            aboutMe: userData['AboutMe'] ?? 'N/A',
            rating: userData['Rating'] ?? 'N/A',
            numberOfRating: userData['NumberOfRating'] ?? 'N/A',
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
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: const Color.fromARGB(255, 255, 116, 36),
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
                      color: const Color.fromARGB(255, 255, 203, 173),
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
                      Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TutorSetting()),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 116, 36),
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
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 116, 36),
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
/*
  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    const Color backgroundColor =
        Color.fromARGB(255, 255, 116, 36); // Orange color

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Tutor Account Page"),
        backgroundColor: backgroundColor, // AppBar color
        centerTitle: true,
      ),
      backgroundColor:
          const Color.fromARGB(255, 255, 244, 236), // Background color
      body: SafeArea(
        child: Column(
          children: [
            AccountHeader(
              backgroundColor: backgroundColor,
              userName: user?.displayName ?? 'Vincent',
              imageRadius: 80.0, // Adjust the profile image radius size here
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              height: MediaQuery.of(context).size.height *
                  0.35, // Adjust the height as needed
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  OptionButton(
                    title: 'Settings',
                    icon: Icons.settings,
                    onTap: () {
                      // TODO: Navigate to settings page
                    },
                  ),
                  const SizedBox(height: 8),
                  OptionButton(
                    title: 'Log out',
                    icon: Icons.logout,
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                  const SizedBox(height: 100),
                  OptionButton(
                    title: 'Delete Account',
                    icon: Icons.delete_forever,
                    onTap: () {
                      // TODO: Handle delete account
                    },
                    backgroundColor:
                        Colors.red, // Delete button background color
                    textColor: Colors.white, // Delete button text color
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountHeader extends StatelessWidget {
  final String userName;
  final Color backgroundColor;
  final double imageRadius;

  const AccountHeader({
    Key? key,
    required this.userName,
    required this.backgroundColor,
    this.imageRadius = 30.0, // Default image radius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: imageRadius, // Use the imageRadius for the size
            backgroundImage: AssetImage(
                'assets/images/tutor_seeker_profile.png'), // Replace with your image path
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black, // Changed text color to black
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to profile details page
            },
            child: Text(
              'See your profile >',
              style:
                  TextStyle(color: Colors.black), // Changed text color to black
            ),
          ),
        ],
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;

  const OptionButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white, // Default background color
    this.textColor = Colors.black, // Default text color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor, // Button background color
          border: Border.all(
              color: backgroundColor == Colors.white
                  ? Colors.grey.shade300
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the children horizontally
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8), // Reduced space between the icon and text
            Text(
              title,
              style: TextStyle(color: textColor), // Text color
            ),
          ],
        ),
      ),
    );
  }
}
*/