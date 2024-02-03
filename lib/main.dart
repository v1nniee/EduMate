//havent debug the background notification to navigate to the notification page.

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/AdminScreen/AdminTabScreen.dart';
import 'package:edumateapp/TutorScreen/TutorTabScreen.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerNotification.dart';
import 'package:edumateapp/Widgets/FirebaseAPI.dart';
import 'package:edumateapp/Widgets/SendNotification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerTabScreen.dart';
import 'package:edumateapp/Screen/Authenticate.dart';
import 'package:edumateapp/Screen/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true);
  await Firebase.initializeApp();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("message: $message");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
// If onMessage is triggered with a notification, construct our own
// local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: "@mipmap/ic_launcher",
            ),
          ));
    }
  });
}

Future<void> onSelectNotification(String? payload, BuildContext context) async {
  if (payload != null) {
    // Navigate to the notification page
    Navigator.of(context).pushNamed('/notificationPage');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAPI().initNotifications();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(firebaseMessagingBackgroundHandler);
  SendNotificationClass().sendNotification("", "");

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialization settings for Android and iOS (IoS HAVENT DONE)
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

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

  runApp(ChangeNotifierProvider(
    create: (context) => UserTypeNotifier(),
    //child: const OverlaySupport.global(child: MyApp()),
    child: const MyApp(),
  ));
}

class UserTypeNotifier with ChangeNotifier {
  String? _userType;

  UserTypeNotifier();

  String? get userType => _userType;

  Future<void> setUserType(String userId) async {
    String? newUserType = await getUserType(userId);
    if (_userType != newUserType) {
      _userType = newUserType;
      notifyListeners();
    }
  }
}

Future<void> deleteUserTypeFromCollection(String collectionPath) async {
  //collectionPath can be 'Tutor' or 'Tutor Seeker'
  var firestore = FirebaseFirestore.instance;
  var collection = firestore.collection(collectionPath);
  var snapshots = await collection.get();
  for (var doc in snapshots.docs) {
    await doc.reference.update({'UserType': FieldValue.delete()});
  }
}

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/notificationPage': (context) => const TutorSeekerTabScreen(
              initialPageIndex: 1,
            ), // Add this line
      },
      debugShowCheckedModeBanner: false,
      title: 'EduMate',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData && snapshot.data != null) {
            Provider.of<UserTypeNotifier>(context, listen: false)
                .setUserType(snapshot.data!.uid);

            // We use a Consumer here to listen to UserTypeNotifier updates
            return Consumer<UserTypeNotifier>(
              builder: (context, userTypeNotifier, child) {
                final userType = userTypeNotifier.userType;
                print('User type is: $userType');

                switch (userType) {
                  case 'Tutor':
                    return TutorTabScreen();
                  case 'Tutor Seeker':
                    return TutorSeekerTabScreen();
                  case 'New Tutor':
                    return TutorTabScreen();
                  case 'New Tutor Seeker':
                    return TutorSeekerTabScreen();
                  case 'Admin':
                    return AdminTabScreen();
                  default:
                    return const AuthenticatePage();
                }
              },
            );
          } else {
            // If snapshot doesn't have data, meaning no user is logged in
            return const AuthenticatePage();
          }
        },
      ),
    );
  }
}
