import 'package:edumateapp/Widgets/SendNotification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';

class FirebaseAPI {

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Requesting permission
    await _firebaseMessaging.requestPermission();

    // Getting the token
    final FCMToken = await _firebaseMessaging.getToken();
    print('Token: $FCMToken');

    // Configure foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      if (message.notification != null) {
        showOverlayNotification((context) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading: SizedBox.fromSize(
                    size: const Size(40, 40),
                    child: ClipOval(
                        child: Container(
                      color: Colors.black,
                    ))),
                title: Text(message.notification!.title ?? "No Title"),
                subtitle: Text(message.notification!.body ?? "No Body"),
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context)!.dismiss();
                      
                    }),
              ),
            ),
          );
        }, duration: const Duration(milliseconds: 4000));
      }
    });
  }
}
