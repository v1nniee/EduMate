// notification_setup.dart
import 'package:edumateapp/FCM/SendNotification.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:edumateapp/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:edumateapp/FCM/FirebaseAPI.dart';
import 'package:provider/provider.dart';
 // Adjust the import path as necessary

class FCMSetup {
  static Future<void> initFCM(BuildContext context) async {
    await FirebaseAPI().initNotifications(context);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(firebaseMessagingBackgroundHandler);
    final userTokenNotifier =
        Provider.of<UserTokenNotifier>(context, listen: false);
    final fcmToken = userTokenNotifier.fcmToken;
    
    SendNotificationClass().sendNotification("Welcome", "",
        fcmToken);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Initialization settings for Android and iOS (IoS HAVENT DONE)
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamed('/notificationPage');
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          (NotificationResponse response) async {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamed('/notificationPage');
        }
      },
    );
  }
}
