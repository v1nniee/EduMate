import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  final String tutorId;
  final String name;
  final String subject;
  final String imageURL;

  const TutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add padding around the Card
    return Padding(
      padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorDetailPage(tutorId: tutorId),
            ),
          );
        },
        child: Card(
          elevation: 4.0, // Optional: add shadow to card
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageURL),
              onBackgroundImageError: (exception, stackTrace) {
                print("onBackgroundImageError");
              },
            ),
            title: Text(name),
            subtitle: Text(subject),
          ),
        ),
      ),
    );
  }
}