import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/TutorScreen/TutorChat.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerChat.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerTutorSearchScreen.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:edumateapp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TutorHomeChat extends StatefulWidget {
  const TutorHomeChat({super.key, required String ReceiverUserId});

  @override
  _TutorHomeChatState createState() => _TutorHomeChatState();
}

class _TutorHomeChatState extends State<TutorHomeChat> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String TutorName;

  Stream<List<ChatPreviewData>> getChatPreviews() {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userTypeNotifier =
        Provider.of<UserTypeNotifier>(context, listen: false);
    final userType = userTypeNotifier.userType;

    return _firestore
        .collection('Chats')
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatPreviewData> chatPreviews = [];
      for (var chatSnapshot in snapshot.docs) {
        // Extract the tutor and tutor seeker IDs from the chat document ID
        List<String> IDs = chatSnapshot.id.split('_');
        String TutorId = IDs[0];
        String TutorSeekerId = IDs[1];

        bool isUserChat = userType == 'Tutor'
            ? currentUser.uid == TutorId
            : currentUser.uid == TutorSeekerId;

        FirebaseFirestore.instance
            .collection(userType!)
            .doc(TutorId)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            Map<String, dynamic> userProfileData =
                documentSnapshot.data() as Map<String, dynamic>;
            TutorName = userProfileData['Name'];
          } else {
            print("UserProfile document does not exist on the database");
          }
        }).catchError((error) => print("Failed to get user name: $error"));

        if (isUserChat) {
          var messageSnapshot = await chatSnapshot.reference
              .collection('Messages')
              .orderBy('CreatedAt', descending: true)
              .limit(1)
              .get();

          // Assuming the first document contains the latest message details
          if (messageSnapshot.docs.isNotEmpty) {
            var message = messageSnapshot.docs.first;
            var messageData = message.data() as Map<String, dynamic>;

            chatPreviews.add(ChatPreviewData(
              chatId: chatSnapshot.id,
              name: TutorName,
              lastMessage: chatSnapshot.get('LastMessage') ?? 'No message',
              imageUrl: messageData['SenderUserImage'] ?? 'default_image_url',
              timestamp: (messageData['CreatedAt'] as Timestamp).toDate(),
            ));
          }
        }
      }
      return chatPreviews;
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            // Use Expanded to fill the remaining space with the chat list
            child: StreamBuilder<List<ChatPreviewData>>(
              stream: getChatPreviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No chats found"));
                }

                final chatPreviews = snapshot.data!;

                return ListView.builder(
                  itemCount: chatPreviews.length,
                  itemBuilder: (context, index) {
                    final chatPreview = chatPreviews[index];
                    return InkWell(
                      // Wrap ListTile with InkWell for tap functionality
                      onTap: () {
                        // Navigate to the chat screen
                        // You'll need to replace 'TutorChat' with the actual name of your chat screen widget
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TutorChat(
                              ReceiverUserId: chatPreview.chatId.split('_')[1]),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(chatPreview.imageUrl),
                          backgroundColor: Colors.grey.shade200,
                          radius: 24,
                        ),
                        title: Text(chatPreview.name),
                        subtitle: Text(
                          chatPreview.lastMessage,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          _formatTimestamp(chatPreview.timestamp),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
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

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp); // Using the intl package for date formatting
  }
}

class ChatPreviewData {
  final String chatId;
  final String name;
  final String lastMessage;
  final String imageUrl;
  final DateTime timestamp;

  ChatPreviewData({
    required this.chatId,
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    required this.timestamp,
  });
}
