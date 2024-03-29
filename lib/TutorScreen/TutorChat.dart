import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:edumateapp/Widgets/ChatMessages.dart';
import 'package:edumateapp/Widgets/NewMessage.dart';

class TutorChat extends StatefulWidget {
  final String ReceiverUserId;
  const TutorChat({super.key, required this.ReceiverUserId});

  @override
  State<TutorChat> createState() => _TutorChatState();
}

class _TutorChatState extends State<TutorChat> {
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
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
      ),
      body: Column(
        children: [
          const PageHeader(
            backgroundColor: const Color.fromARGB(255, 255, 116, 36),
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
