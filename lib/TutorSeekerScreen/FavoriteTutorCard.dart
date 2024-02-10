import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';

class FavoriteTutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;
  final Function(String) onUnfavorite; // Callback function to remove tutor card
  const FavoriteTutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.rating,
    required this.fees,
    required this.tutorPostId,
    required this.onUnfavorite, // Pass callback function from parent
  }) : super(key: key);

  @override
  _FavoriteTutorCardState createState() => _FavoriteTutorCardState();
}

class _FavoriteTutorCardState extends State<FavoriteTutorCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('Tutor Seeker')
              .doc(user.uid)
              .collection('FavoriteTutors')
              .doc(widget.tutorId)
              .get();

      if (doc.exists) {
        setState(() {
          isFavorite = doc.data()?['tutorPostIds']
                  .contains(widget.tutorPostId) ??
              false;
        });
      }
    }
  }

  void _toggleFavorite() {
  setState(() {
    isFavorite = !isFavorite;
  });
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    if (isFavorite) {
      FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(user.uid)
          .collection('FavoriteTutors')
          .doc(widget.tutorId)
          .set({
        'tutorPostIds': FieldValue.arrayUnion([widget.tutorPostId]),
      }, SetOptions(merge: true));
    } else {
      FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(user.uid)
          .collection('FavoriteTutors')
          .doc(widget.tutorId)
          .update({
        'tutorPostIds': FieldValue.arrayRemove([widget.tutorPostId]),
      });
      // Remove the tutor card from the UI when unfavorited
      if (widget.onUnfavorite != null) {
        widget.onUnfavorite(widget.tutorPostId);
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.imageURL),
            ),
            title: Text(widget.name),
            subtitle: Text(widget.subject),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Rating: ${widget.rating}'),
                Text('Price: ${widget.fees}/hr'),
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
                      builder: (context) => TutorDetailPage(
                        tutorId: widget.tutorId,
                        tutorPostId: widget.tutorPostId,
                      ),
                    ),
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
