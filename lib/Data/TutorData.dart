import 'package:edumateapp/TutorScreen/AvailibilitySlot.dart';
import 'package:edumateapp/TutorScreen/MyStudent.dart';
import 'package:edumateapp/TutorScreen/StudentPayment.dart';
import 'package:edumateapp/TutorScreen/ToPayTutorSeeker.dart';
import 'package:edumateapp/TutorScreen/TutorAddPost.dart';
import 'package:edumateapp/TutorScreen/TutorManagePost.dart';
import 'package:edumateapp/TutorScreen/TutorHome.dart';
import 'package:edumateapp/TutorScreen/TutorSeekerApplicationRequest.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/Models/Category.dart';

//all the value of category is created here - no need to create the same category multiple time

const TutorFunctionCategories = [
  Category(
    id: 't1',
    title: 'Add Post',
    color: Colors.white,
    icon: Icons.add, 
    nextPage: TutorAddPost(),
  ),
  Category(
    id: 't2',
    title: 'Manage Post',
    color: Colors.white,
    icon: Icons.edit, 
    nextPage: TutorManagePost(),
  ),
  Category(
    id: 't3',
    title: 'Time Availibility',
    color: Colors.white,
    icon: Icons.timer, 
    nextPage: AvailabilitySlot(),
  ),
  Category(
    id: 't4',
    title: 'My Student',
    color: Colors.white,
    icon: Icons.group, 
    nextPage: MyStudent(),
  ),
  Category(
    id: 't5',
    title: 'Tutor Seeker Application Request',
    color: Colors.white,
    icon: Icons.assignment,
    nextPage: TutorSeekerApplicationRequest(),
  ),
  Category(
    id: 't6',
    title: 'To Pay Tutor Seeker',
    color: Colors.white,
    icon: Icons.payment, 
    nextPage: ToPayTutorSeeker(),
  ),
  Category(
    id: 't7',
    title: 'My Student Payment',
    color: Colors.white,
    icon: Icons.payment, 
    nextPage: StudentPayment(),
  ),
];