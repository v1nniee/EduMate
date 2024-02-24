import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/FCM/SendNotification.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginNotificationChecker {
  // Call this method right after the user successfully logs in.
  Future<void> checkAndSendNotifications(BuildContext context, String UserType) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      final userTokenNotifier = Provider.of<UserTokenNotifier>(context, listen: false);
      final fcmToken = userTokenNotifier.fcmToken;

      CollectionReference notifications = FirebaseFirestore.instance
          .collection(UserType)
          .doc(userId)
          .collection('Notification');

      QuerySnapshot unsentNotifications = await notifications
          .where('Status', isEqualTo: 'Unsend')
          .get();

      for (var doc in unsentNotifications.docs) {
        DocumentReference docRef = doc.reference;

        SendNotificationClass().sendNotification(
          doc['Title'], 
          doc['Content'], 
          fcmToken);

        await docRef.update({'Status': 'Sent'});
      }
    }
  }
}
