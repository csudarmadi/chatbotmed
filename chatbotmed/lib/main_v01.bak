import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> messages = [];

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.22.17:5000/chat'), // Ganti IP sesuai Flask kamu
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': text}),
      );

      /*
      print('==== FLUTTER HTTP LOG ====');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      */

      if (response.statusCode == 200) {
        final reply = json.decode(response.body)['reply'];
        setState(() {
          messages.add({'role': 'bot', 'text': reply});
        });
      } else {
        setState(() {
          messages.add({'role': 'bot', 'text': '[Server error ${response.statusCode}]'});
        });
      }
    } catch (e) {
      /*
      print('==== FLUTTER ERROR ====');
      print(e);
      setState(() {
        messages.add({'role': 'bot', 'text': '[Gagal menghubungi server]'});
      });
      */
    }

    // Autoscroll
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? Colors.blue[100] : Colors.grey[200];
    final textColor = Colors.black;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message['text'] ?? '',
            style: TextStyle(color: textColor),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("AI Chatbot")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (_, i) => buildMessage(messages[i]),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8, // ➕ ini kuncinya
                top: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: sendMessage,
                      decoration: const InputDecoration.collapsed(hintText: "Tulis pesan..."),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => sendMessage(_controller.text.trim()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
