import 'package:flutter/material.dart';

//create this class to store multiple value associated with same id

class Category{
  const Category({
    required this.id,
    required this.title,
    this.color = Colors.white,
    this.icon,
    this.imagePath,
    required this.nextPage,
  });

  //declare variable
  final String id;
  final String title;
  final Color color;
  final IconData? icon;
  final String? imagePath;
  final Widget nextPage;
}