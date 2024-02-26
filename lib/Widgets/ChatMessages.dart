import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/Widgets/MessageBubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatMessages extends StatelessWidget {
  final String ReceiverUserId;
  const ChatMessages({
    super.key,
    required this.ReceiverUserId,
  });

  @override
  Widget build(BuildContext context) {
    late String Tutor_TutorSeekerChatId;
    final currentUser = FirebaseAuth.instance.currentUser!;

    final userTypeNotifier =
        Provider.of<UserTypeNotifier>(context, listen: false);
    final userType = userTypeNotifier.userType;
    if (userType == "Tutor") {
      Tutor_TutorSeekerChatId = '${currentUser.uid}_${ReceiverUserId}';
    } else if (userType == "Tutor Seeker") {
      Tutor_TutorSeekerChatId = '${ReceiverUserId}_${currentUser.uid}';
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Chats')
          .doc(Tutor_TutorSeekerChatId)
          .collection('Messages')
          .orderBy('CreatedAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong..'),
          );
        }

        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['SenderId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['SenderId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatMessage['Text'],
                  isMe: currentUser.uid == currentMessageUserId);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage['SenderUserImage'],
                  username: chatMessage['SenderName'],
                  message: chatMessage['Text'],
                  isMe: currentUser.uid == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
