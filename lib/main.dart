//havent debug the background notification to navigate to the notification page.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/AdminScreen/AdminTabScreen.dart';
import 'package:edumateapp/FCM/FCMSetUp.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/TutorScreen/TutorTabScreen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerTabScreen.dart';
import 'package:edumateapp/Screen/Authenticate.dart';
import 'package:edumateapp/Screen/Splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserTypeNotifier>(
          create: (context) => UserTypeNotifier()),
      ChangeNotifierProvider<UserTokenNotifier>(
          create: (context) => UserTokenNotifier()),
    ],
    child: const OverlaySupport.global(child: MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMSetup.initFCM(context);
    });

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
                    return const TutorTabScreen();
                  case 'Tutor Seeker':
                    return const TutorSeekerTabScreen();
                  case 'New Tutor':
                    return const TutorTabScreen();
                  case 'New Tutor Seeker':
                    return const TutorSeekerTabScreen();
                  case 'Admin':
                    return const AdminTabScreen();
                  default:
                    return const AuthenticatePage();
                }
              },
            );
          } else {
            return const AuthenticatePage();
          }
        },
      ),
    );
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
