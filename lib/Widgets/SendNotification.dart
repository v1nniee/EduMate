import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class SendNotificationClass {


  Future<void> sendNotification(String title, String body) async {
    const String cloudFunctionEndpoint = 'https://fcm.googleapis.com/fcm/send';

    try {
      Map<String, String> notificationBody = {
        "title": title,
        "body": body,
        "time": "FCM Message"
      };
      print(jsonDecode(jsonEncode(notificationBody)));
      final response = await http.post(
        Uri.parse(cloudFunctionEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAoV0ARLY:APA91bFdeYzs7WX2rhWLYn_ZWej_G0OJKye3_KzpvDjXG5odr4tR07WfnB05PFO1c1FXrSVO9OY5JGXyoDD44L3fq-KR1dc4InnisTn2oWIytb8Wph-_TsHfYI22B703T21avIr8cjqI',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': jsonDecode(jsonEncode(notificationBody)),
          'to':
              "dAuinOMLTJieJYmQfy4AOo:APA91bFNFJhhTWM6n65WLRLGKwsn1bEz_T7WpBGhj53xY0_-Ib9FP5kpSzy_L7PJAYn-_sI1dDBS-pJcwUIaFGzeCkW0cNrs17-iHysnzgd_7VEJceMafNePsdo2fKoNhzVGum5PnJZ9"
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent');
      } else {
        print(response.body);
        print('Failed to send notification');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
