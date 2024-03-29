
import 'package:edumateapp/TutorSeekerScreen/Favorite.dart';
import 'package:edumateapp/TutorSeekerScreen/MyTutor.dart';
import 'package:edumateapp/TutorSeekerScreen/RateReview.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerApplicationStatus.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerFindTutor.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerPayment.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerPaymentHistory.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/Models/Category.dart';

//all the value of category is created here - no need to create the same category multiple time

const TutorSeekerFunctionCategories = [
  Category(
    id: 'ts1',
    title: 'Find a Tutor',
    color: Colors.white,
    icon: Icons.search,
    nextPage: TutorSeekerFindTutor(),
  ),
  Category(
    id: 'ts2',
    title: 'My Tutor',
    color: Colors.white,
    icon:Icons.person,
    nextPage: MyTutor(),
  ),
  Category(
    id: 'ts3',
    title: 'Favorite',
    color: Colors.white,
    icon:Icons.star,
    nextPage: FavoriteTutor(),
  ),
  Category(
    id: 'ts4',
    title: 'Application Status',
    color: Colors.white,
    icon:Icons.info,
    nextPage: TutorSeekerApplicationStatus(),
  ),
  Category(
    id: 'ts5',
    title: 'Payment',
    color: Colors.white, 
    icon:Icons.payment,
    nextPage: TutorSeekerPayment(),
  ),
  Category(
    id: 'ts6',
    title: 'Payment History',
    color: Colors.white,
    icon:Icons.history,
    nextPage: TutorSeekerPaymentHistory(),
  ),

  Category(
    id: 'ts7',
    title: 'Rate and Review',
    color: Colors.white,
    icon:Icons.reviews,
    nextPage: RateReview(),
  ),
];