import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';




class ImageURLManager {
  Future<String?> getImageURL() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null; // Ensure user is not null
    String userId = user.uid;

    DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
        .collection('Users') // Assuming there's a common collection for all users
        .doc(userId)
        .collection('UserProfile')
        .doc(userId)
        .get();

    if (userProfileSnapshot.exists) {
      Map<String, dynamic>? data = userProfileSnapshot.data() as Map<String, dynamic>?;
      return data?['ImageURL']; // Make sure 'ImageURL' matches the field name in Firestore
    } else {
      print('User profile document does not exist.');
      return null;
    }
  }
}

class ProfilePictureNotifier with ChangeNotifier {
  String? _imageURL;

  String? get imageURL => _imageURL;

  Future<void> fetchAndSetImageURL() async {
    var manager = ImageURLManager();
    var finalImageURL = await manager.getImageURL();
    _imageURL = finalImageURL;
    notifyListeners();
  }
}

