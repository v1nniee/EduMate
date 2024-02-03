import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TutorProfile extends StatelessWidget {
  const TutorProfile({super.key});

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
