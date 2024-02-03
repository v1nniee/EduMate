import 'package:flutter/material.dart';

//profileImagePath, backgroundColor, greetingText can be changed

class HomeHeader extends StatelessWidget {
  final String profileImagePath;
  final Color backgroundColor;
  final String greetingText;

  const HomeHeader({
    Key? key,
    this.profileImagePath = 'assets/images/tutor_seeker_profile.png',
    required this.backgroundColor, 
    this.greetingText = 'Good Morning', 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          width: screenWidth,
          height: screenHeight * 0.25,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.19,
            margin: const EdgeInsets.only(top: 20, bottom: 50),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome to the Home Page',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        greetingText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      AssetImage(profileImagePath),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
