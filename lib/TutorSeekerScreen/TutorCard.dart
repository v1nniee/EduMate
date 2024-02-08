import 'package:edumateapp/Provider/FavoriteTutorsProvider.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorDetailPage.dart';
import 'package:provider/provider.dart';

class TutorCard extends StatefulWidget {
  final String tutorId;
  final String tutorPostId;
  final String name;
  final String subject;
  final String imageURL;
  final double rating;
  final String fees;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const TutorCard({
    Key? key,
    required this.tutorId,
    required this.name,
    required this.subject,
    required this.imageURL,
    required this.rating,
    required this.fees,
    required this.tutorPostId,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _TutorCardState createState() => _TutorCardState();
}


class _TutorCardState extends State<TutorCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    // Initialize isFavorite based on the provider's state
    isFavorite = context.read<FavoriteTutorsProvider>().isFavorite(widget.tutorId);
  }

  @override
  Widget build(BuildContext context) {
    var favoriteProvider = Provider.of<FavoriteTutorsProvider>(context, listen: false);
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
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
                if (isFavorite) {
                  favoriteProvider.addFavoriteTutor(widget.tutorId);
                } else {
                  favoriteProvider.removeFavoriteTutor(widget.tutorId);
                }
              },
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