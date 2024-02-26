import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';

class TutorNotification extends StatelessWidget {
  const TutorNotification({Key? key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final notificationsRef = FirebaseFirestore.instance
        .collection('Tutor')
        .doc(currentUser.uid)
        .collection('Notification')
        .where('Status', isEqualTo: 'Sent');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: const Color.fromARGB(255, 255, 116, 36),
            headerTitle: 'Notification',
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: notificationsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final documents = snapshot.data!.docs;

                if (documents.isEmpty) {
                  return Center(child: Text('No notifications available.'));
                }

                // Group notifications by date
                Map<String, List<DocumentSnapshot>> groupedNotifications = {};
                documents.forEach((document) {
                  final notification =
                      document.data() as Map<String, dynamic>;
                  final notificationTime =
                      (notification['NotificationTime'] as Timestamp)
                          .toDate();
                  String date = getDateText(notificationTime);
                  groupedNotifications.putIfAbsent(date, () => []);
                  groupedNotifications[date]!.add(document);
                });

                // Sort keys in descending order
                List<String> sortedKeys = groupedNotifications.keys.toList();
                sortedKeys.sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    String date = sortedKeys[index];
                    List<DocumentSnapshot> notifications =
                        groupedNotifications[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            date,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification =
                                notifications[index].data() as Map<String, dynamic>;
                            final notificationTime =
                                (notification['NotificationTime'] as Timestamp)
                                    .toDate();
                            final content = notification['Content'];
                            final title = notification['Title'];

                            IconData iconData = Icons.notifications;
                            if (title == 'Application Request') {
                              iconData = Icons.assignment;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Card(
                                elevation: 3,
                                child: ListTile(
                                  leading: Icon(
                                    iconData,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  title: Text(
                                    title,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(content),
                                  trailing: Text(
                                    '${notificationTime.hour}:${notificationTime.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle tapping on a notification if needed
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String getDateText(DateTime dateTime) {
    DateTime now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    } else {
      return dateTime.toString().split(' ')[0];
    }
  }
}

