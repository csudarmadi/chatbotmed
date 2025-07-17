// lib/screens/chatbot_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatLog(); // panggil load saat pertama dibuka
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.173:5000/chat'), // GANTI dengan IP Flask kamu
        //Uri.parse('https://csudarmadi.pythonanywhere.com/chat'), // GANTI dengan IP Flask kamu
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['reply'] ?? 'Bot tidak merespon.';
        setState(() {
          _messages.add({'role': 'bot', 'text': reply});
        });
      } else {
        setState(() {
          _messages.add({'role': 'bot', 'text': 'Terjadi kesalahan pada server.'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Tidak dapat menghubungi server.'});
      });
    } finally {
      setState(() => _isLoading = false);
      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      await _saveChatLog();
    }
  }

  Future<void> _loadChatLog() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chatlog');
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() {
        _messages.clear();
        _messages.addAll(
          decoded.map<Map<String, String>>((e) => {
            'role': e['role'] ?? '',
            'text': e['text'] ?? '',
          })
        );
      });
    }
  }

  Future<void> _saveChatLog() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_messages);
    await prefs.setString('chatlog', encoded);
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message['text'] ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot Edukasi Obat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessage(_messages[index]),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Tulis pertanyaan tentang obat...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(_controller.text.trim()),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
