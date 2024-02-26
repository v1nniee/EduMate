import 'package:edumateapp/AdminScreen/AdminDisqualifyTutor.dart';
import 'package:edumateapp/AdminScreen/ApproveRejectTutorRegistration.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/Models/Category.dart';

//all the value of category is created here - no need to create the same category multiple time

const AdminFunctionCategories = [

  Category(
    id: 'a1',
    title: 'Tutor Registration Verification',
    color: Colors.white,
    icon: Icons.verified,
    nextPage: ApproveRejectTutorRegistration(),
  ),
  Category(
    id: 'a2',
    title: 'Tutor Disqualification',
    color: Colors.white,
    icon: Icons.cancel,
    nextPage: AdminDisqualifyTutor(),
  ),
];