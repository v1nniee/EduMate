import 'package:edumateapp/Data/AdminData.dart';
import 'package:edumateapp/Screen/CategoriesScreen.dart';
import 'package:edumateapp/Widgets/HomeHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Home Page"),
        backgroundColor: const Color.fromARGB(255, 16, 212, 252),
        elevation: 0,

      ),
      backgroundColor: const Color.fromARGB(255, 240, 252, 252),
      body: const Column( 
        children: [
          HomeHeader(backgroundColor: Color.fromARGB(255, 16, 212, 252)), // Corrected the parenthesis
          Expanded(
            child: CategoriesScreen(categories: AdminFunctionCategories, backgroundColor:  Color.fromARGB(255, 240, 252, 252), fontSize: 15, iconSize: 30, imageSize: 40),
          ),
        ],
      ),
    );
  }
}