import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(),
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
  List<String> messages = [];

  Future<void> sendMessage(String text) async {
    final url = Uri.parse('http://192.168.100.204:5000'); // ← GANTI dengan IP PC kamu

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': text}),
      );

      //print('==== FLUTTER HTTP LOG ====');
      //print('Status Code: ${response.statusCode}');
      //print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final reply = json.decode(response.body)['reply'];
        setState(() {
          messages.add("You: $text");
          messages.add("Bot: $reply");
        });
      } else {
        setState(() {
          messages.add("Bot: [Server error ${response.statusCode}]");
        });
      }
    } catch (e) {
      //print('==== FLUTTER ERROR ====');
      //print(e);
      setState(() {
        messages.add("Bot: [Gagal menghubungi server]");
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) => ListTile(title: Text(messages[i])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      sendMessage(_controller.text.trim());
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
