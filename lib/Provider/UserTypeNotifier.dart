import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/main.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTypeNotifier with ChangeNotifier {
  String? _userType;

  String? get userType => _userType;

  Future<void> setUserType(String userId) async {
    var manager = UserTypeManager();
    var userType = await manager.getUserType(userId);
    _userType = userType;
    notifyListeners();
  }
}

class UserTypeManager {
  Future<String?> getUserType(String userId) async {
    // Check local cache first
    final prefs = await SharedPreferences.getInstance();
    final cachedType = prefs.getString('user_type_$userId');
    if (cachedType != null) {
      print("Cached Type: $cachedType");
      if (!(cachedType == "New Tutor Seeker" || cachedType == "New Tutor")) {
        return cachedType;
      }
    }

    // If not in cache, check Firestore
    var firestore = FirebaseFirestore.instance;
    var tutorFuture = firestore.collection('Tutor').doc(userId).get();
    var tutorSeekerFuture =
        firestore.collection('Tutor Seeker').doc(userId).get();
    var adminFuture = firestore.collection('Admin').doc(userId).get();

    // Wait for both queries to complete
    var results =
        await Future.wait([tutorFuture, tutorSeekerFuture, adminFuture]);

    // Check both documents and return the user type
    for (var userDoc in results) {
      if (userDoc.exists) {
        var data = userDoc.data();
        if (data != null) {
          var userType = data['UserType'] as String?;
          if (userType != null) {
            // Save the user type to the cache
            await prefs.setString('user_type_$userId', userType);
            print("User Type: $userType");
            return userType;
          }
        }
      }
    }

    // If no document was found in either collection
    print('User document does not exist in both collections.');
    return null;
  }

  
}
