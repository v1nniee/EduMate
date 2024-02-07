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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorDetailPage(tutorId: tutorId),
          ),
        );
      },
      child: Card(
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
    );
  }
}
