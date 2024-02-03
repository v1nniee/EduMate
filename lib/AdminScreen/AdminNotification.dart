import 'dart:convert';
import 'package:edumateapp/Widgets/SendNotification.dart';
import 'package:http/http.dart' as http;
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminNotification extends StatelessWidget {
  const AdminNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Notification Page"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              SendNotificationClass().sendNotification("title", "body");
            },
            child: const Text("Hi")),
      ),
    );
  }
}
