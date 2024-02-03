import 'package:flutter/widgets.dart';

Future<void> onSelectNotification(String? payload, BuildContext context) async {
  if (payload != null) {
    // Navigate to the notification page
    Navigator.of(context).pushNamed('/notificationPage');
  }
}