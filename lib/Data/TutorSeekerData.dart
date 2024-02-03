
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerHome.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerTabScreen.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/Models/Category.dart';
import 'package:edumateapp/TutorScreen/TutorTabScreen.dart';

//all the value of category is created here - no need to create the same category multiple time

// ignore: constant_identifier_names
const TutorSeekerFunctionCategories = [
  Category(
    id: 'ts1',
    title: 'Find a Tutor',
    color: Colors.white,
    icon: Icons.search,
    nextPage: TutorSeekerTabScreen(
              initialPageIndex: 0,
            ),
  ),
  Category(
    id: 'ts2',
    title: 'My Tutor',
    color: Colors.white,
    icon:Icons.person,
    nextPage: TutorSeekerHome(),
  ),
  Category(
    id: 'ts3',
    title: 'Favorite',
    color: Colors.white,
    icon:Icons.star,
    nextPage: TutorSeekerHome(),
  ),
  Category(
    id: 'ts4',
    title: 'Application Status',
    color: Colors.white,
    icon:Icons.info,
    nextPage: TutorSeekerHome(),
  ),
  Category(
    id: 'ts5',
    title: 'Payment',
    color: Colors.white, 
    icon:Icons.payment,
    nextPage: TutorSeekerHome(),
  ),
  Category(
    id: 'ts6',
    title: 'Payment History',
    color: Colors.white,
    icon:Icons.history,
    nextPage: TutorSeekerHome(),
  ),
];