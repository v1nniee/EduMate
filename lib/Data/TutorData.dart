import 'package:edumateapp/TutorScreen/TutorHome.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/Models/Category.dart';

//all the value of category is created here - no need to create the same category multiple time

const TutorFunctionCategories = [
  Category(
    id: 'ts1',
    title: 'Add/Edit Post',
    color: Colors.white,
    icon: Icons.edit, 
    nextPage: TutorHome(),
  ),
  Category(
    id: 'ts2',
    title: 'My Student',
    color: Colors.white,
    icon: Icons.group, 
    nextPage: TutorHome(),
  ),
  Category(
    id: 'ts3',
    title: 'Tutor Seeker Application Request',
    color: Colors.white,
    icon: Icons.assignment,
    nextPage: TutorHome(),
  ),
  Category(
    id: 'ts4',
    title: 'My Student Payment',
    color: Colors.white,
    icon: Icons.payment, 
    nextPage: TutorHome(),
  ),
];