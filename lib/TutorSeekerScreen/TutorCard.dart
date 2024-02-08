import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;

  const TutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.rating,
    required this.fees, 
    required this.tutorPostId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageURL),
            ),
            title: Text(name),
            subtitle: Text(subject),
            trailing: IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () {
                // Implement favorite functionality
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Rating: $rating'),
                Text('Price: $fees/hr'),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TutorDetailPage(tutorId: tutorId, tutorPostId: tutorPostId,)),
                  );
                },
                child: Text('Details'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement apply functionality
                },
                child: Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
