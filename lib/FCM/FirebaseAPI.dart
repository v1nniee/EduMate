import 'package:edumateapp/FCM/SendNotification.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(BuildContext context) async {
    // Requesting permission
    await _firebaseMessaging.requestPermission();

    // Getting the token
    final FCMToken = await _firebaseMessaging.getToken();
    print('Token: $FCMToken');

    // Assuming you have access to the context here. If not, you'll need to pass it to this method.
    Provider.of<UserTokenNotifier>(context, listen: false).setToken(FCMToken!);

    /*
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
    */
  }
}
