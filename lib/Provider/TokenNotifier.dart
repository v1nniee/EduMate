import 'package:flutter/material.dart';

class UserTokenNotifier with ChangeNotifier {
  String _fcmToken = '';

  String get fcmToken => _fcmToken;

  void setToken(String token) {
    _fcmToken = token;
    notifyListeners(); // Notify all listening widgets to rebuild.
  }
}
