import 'dart:convert';
import 'package:edumateapp/FCM/SendNotification.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:http/http.dart' as http;
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class TutorNotification extends StatelessWidget {
  const TutorNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final userTokenNotifier =
        Provider.of<UserTokenNotifier>(context, listen: false);
    final fcmToken = userTokenNotifier.fcmToken;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Notification Page"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              SendNotificationClass().sendNotification("title","body",
              fcmToken);
            },
            child: const Text("Hi")),
      ),
    );
  }
}
