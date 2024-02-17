import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorSeekerNotification extends StatefulWidget {
  const TutorSeekerNotification({super.key});

  @override
  State<TutorSeekerNotification> createState() => _TutorSeekerNotificationState();
}

class _TutorSeekerNotificationState extends State<TutorSeekerNotification> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  void fetchNotifications() async {
    // Assuming 'Notification' is the collection where notifications are stored
    var notificationCollection = FirebaseFirestore.instance.collection('TutorSeeker').doc(user?.uid).collection('Notification');
    
    var snapshot = await notificationCollection.orderBy('NotificationTime', descending: true).get();
    notifications = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    
    // Update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: Icon(Icons.notification_important, color: Colors.blue),
            title: Text(notification['Title'] ?? 'No Title'),
            subtitle: Text(notification['Content'] ?? 'No Content'),
            trailing: Text(notification['NotificationTime'] ?? 'No Time'),
          );
        },
      ),
    );
  }
}
