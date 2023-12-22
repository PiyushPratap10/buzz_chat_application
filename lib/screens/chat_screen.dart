import 'package:chat_application/widgets/chat_message.dart';
import 'package:chat_application/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          leading: const Image(
            image: AssetImage('assets/images/logob.png'),
            width: 70,
          ),
          title: Text(
            'BuzzChat',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.exit_to_app_rounded))
          ],
        ),
        body: const Column(
          children: [Expanded(child: ChatMessage()), NewMessage()],
        ));
  }
}
