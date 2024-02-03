import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Provider/UserTypeNotifier.dart';
import 'package:edumateapp/main.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class NewMessage extends StatefulWidget {
  final String ReceiverUserId;
  const NewMessage({
    super.key,
    required this.ReceiverUserId,
  });

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  File? pickedFile;
  bool isEmojiVisible = false;
  late String Tutor_TutorSeekerChatId;

  @override
  void dispose() async {
    _messageController.dispose();
    super.dispose();
  }

  void _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          pickedFile = File(result.files.single.path!);
        });
        // Handle the picked file
      }
    } catch (e) {
      debugPrint("Failed to pick file: $e");
    }
  }

  void _captureImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        pickedFile = File(photo.path);
      });
      // Use the pickedFile as needed
    }
  }

  void _insertEmoji() {
    setState(() {
      isEmojiVisible = !isEmojiVisible;
    });
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userTypeNotifier =
          Provider.of<UserTypeNotifier>(context, listen: false);
      final userType = userTypeNotifier.userType;

      var userData = await FirebaseFirestore.instance
          .collection(userType!)
          .doc(user.uid)
          .collection('UserProfile')
          .doc(user.uid)
          .get();

      if (userType == "Tutor") {
        print("New Messageee: TUtor");
        Tutor_TutorSeekerChatId = '${user.uid}_${widget.ReceiverUserId}';
      } else if (userType == "Tutor Seeker") {
        Tutor_TutorSeekerChatId = '${widget.ReceiverUserId}_${user.uid}';
      }
      final userDataMap = userData.data();
      if (userDataMap != null) {
        final name = userDataMap['Name'] as String? ?? '';
        final userImage = userDataMap['ImageUrl'] as String? ?? '';
        await FirebaseFirestore.instance
            .collection('Chats')
            .doc(Tutor_TutorSeekerChatId)
            .collection('Messages')
            .add({
          'Text': enteredMessage,
          'CreatedAt': Timestamp.now(),
          'SenderId': user.uid,
          'SenderName': name,
          'SenderUserImage': userImage,
          'ReceiverId': widget.ReceiverUserId,
        });
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }

    FirebaseFirestore.instance
        .collection('Chats')
        .doc(Tutor_TutorSeekerChatId)
        .set({
      'LastMessage': enteredMessage,
      'LastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _pickDocument,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                labelText: "Send a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}
