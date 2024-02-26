import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/Widgets/ChatMessages.dart';
import 'package:edumateapp/Widgets/NewMessage.dart';

class TutorSeekerChat extends StatefulWidget {
  final String ReceiverUserId;
  const TutorSeekerChat({super.key, required this.ReceiverUserId});

  @override
  State<TutorSeekerChat> createState() => _TutorSeekerChatState();
}

class _TutorSeekerChatState extends State<TutorSeekerChat> {
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    //final token = await fcm.getToken();
    //print(token); //you could send this token (via http or the firestore sdk) to a backend
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: Color.fromARGB(255, 255, 255, 115),
            headerTitle: 'Chat',
          ),
          Expanded(
            child: ChatMessages(ReceiverUserId: widget.ReceiverUserId),
          ),
          NewMessage(ReceiverUserId: widget.ReceiverUserId),
        ],
      ),
    );
  }
}
