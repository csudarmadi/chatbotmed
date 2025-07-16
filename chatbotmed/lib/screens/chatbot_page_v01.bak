import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final String _gradioUrl = "https://66b896edaf24a7169b.gradio.live/api/predict";
  Completer<void>? _requestCompleter;

  @override
  void dispose() {
    _controller.dispose();
    _requestCompleter?.complete();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_isLoading) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _requestCompleter = Completer<void>();

    setState(() {
      _messages.insert(0, {'role': 'user', 'text': text});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_gradioUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": [text],
          "fn_index": 0,
          "session_hash": "flutter_${DateTime.now().millisecondsSinceEpoch}"
        }),
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botResponse = data['data'][0]?.toString() ?? "No response";
        setState(() {
          _messages.insert(0, {'role': 'bot', 'text': botResponse});
        });
      } else {
        throw "API Error ${response.statusCode}: ${response.body}";
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            'role': 'bot',
            'text': 'Response timeout. Please try again.'
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            'role': 'bot',
            'text': 'Error: ${e.toString().replaceAll('Exception: ', '')}'
          });
        });
      }
    } finally {
      _requestCompleter?.complete();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(
                  text: message['text']!,
                  isUser: message['role'] == 'user',
                );
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about medications...',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}