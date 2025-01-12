import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:watts_clone/consts/auth_const.dart';
import 'package:watts_clone/consts/const.dart';
import 'package:watts_clone/controller/chat_controller.dart';
import 'package:intl/intl.dart' as intl;

class ChatBubbleComponent extends StatelessWidget {
  ChatBubbleComponent({super.key, required this.docs});
  final DocumentSnapshot docs;
  final User? user = firebaseAuth.currentUser;
  final chatC = Get.put(ChatController());
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = docs['createdAT'] == null
        ? DateTime.parse(DateTime.now().toString())
        : DateTime.parse(docs['createdAT'].toDate().toString());
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 10,
      child: ListTile(
        onTap: () {
          chatC.getChatID(
              friendId: user!.uid == docs['user_id']
                  ? docs['friend_id']
                  : docs['user_id'],
              friendUserName: user!.uid == docs['user_id']
                  ? docs['friend_name']
                  : docs['user_name'],
              context: context);
        },
        title: Text(
          '${user!.uid == docs['user_id'] ? docs['friend_name'] : docs['user_name']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          typingMethod() == '' ? '${docs['last_msg']}' : typingMethod(),
          maxLines: 1,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        trailing: Directionality(
          textDirection: TextDirection.ltr,
          child: intl.DateFormat('h:mm a').format(dateTime).text.make(),
        ),
      ),
    );
  }

  typingMethod<String>() {
    return docs['user_id'] == user!.uid
        ? docs['friend_typing']
            ? 'Typing...'
            : ''
        : docs['user_typing']
            ? 'Typing...'
            : '';
  }
}
