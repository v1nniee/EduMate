import 'dart:convert';
import 'package:edumateapp/FCM/SendNotification.dart';
import 'package:http/http.dart' as http;
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminChat extends StatelessWidget {
  const AdminChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Chat Page"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              
            },
            child: const Text("Hi")),
      ),
    );
  }
}
