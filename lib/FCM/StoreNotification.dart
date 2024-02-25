import 'package:cloud_firestore/cloud_firestore.dart';

class StoreNotification{
  void sendNotificationtoTutorSeeker(String tutorseekerId, String title, String content,
      DateTime NotificationTime) async {
    Map<String, dynamic> NotificationData = {
      'Title': title,
      'Content': content,
      'Status': "Unsend",
      'NotificationTime': NotificationTime,
    };

    try {
      await FirebaseFirestore.instance
          .collection('Tutor Seeker')
          .doc(tutorseekerId)
          .collection('Notification')
          .add(NotificationData);
    } catch (error) {
      print('Error saving notification: $error');
    }
  }

  void sendNotificationtoTutor(String tutorid, String title, String content,
      DateTime NotificationTime) async {
    Map<String, dynamic> NotificationData = {
      'Title': title,
      'Content': content,
      'Status': "Unsend",
      'NotificationTime': NotificationTime,
    };

    try {
      await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(tutorid)
          .collection('Notification')
          .add(NotificationData);
    } catch (error) {
      print('Error saving notification: $error');
    }
  }

  void sendNotificationtoAdmin(String title, String content,
      DateTime NotificationTime) async {
    Map<String, dynamic> NotificationData = {
      'Title': title,
      'Content': content,
      'Status': "Unsend",
      'NotificationTime': NotificationTime,
    };

    try {
      await FirebaseFirestore.instance
          .collection('Admin')
          .doc("IlRy3c7wNpWuvfVeCkLPbHGhg1W2")
          .collection('Notification')
          .add(NotificationData);
    } catch (error) {
      print('Error saving notification: $error');
    }
  }
}