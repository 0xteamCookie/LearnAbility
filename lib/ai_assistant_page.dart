import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "LearnAbility",
          style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
        ),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          // Customize the input box
          inputBackgroundColor: Colors.blue, 
          inputTextColor: const Color.fromARGB(255, 255, 255, 255),
          inputTextCursorColor: Colors.blue, 
          inputContainerDecoration: BoxDecoration(
            border: Border.all(color:  Color.fromARGB(0, 158, 158, 158)), 
          ),
           
          // Customize user message bubbles
          primaryColor: Colors.blue, 
          
          userAvatarNameColors: [Colors.blue], 
          receivedMessageBodyTextStyle: TextStyle(
            color: Colors.black, 
          ),
          sentMessageBodyTextStyle: TextStyle(
            color: Colors.white, 
          ),
        ),
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);

    // Simulate an AI response without delay
    final aiMessage = types.TextMessage(
      author: const types.User(id: 'ai'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: 'This is a response from the AI.',
    );

    _addMessage(aiMessage);
  }
}