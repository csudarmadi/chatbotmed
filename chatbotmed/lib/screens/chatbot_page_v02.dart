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
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final String _apiUrl = "http://192.168.100.4:5000/chat"; // Move to config
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_isLoading || _controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();
    
    // Add user message
    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': text}), // Matches your Flask API
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botResponse = data['reply'] ?? "No response received";
        
        setState(() {
          _messages.insert(0, ChatMessage(
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        throw "Request failed with status ${response.statusCode}";
      }
    } on TimeoutException {
      _showError("Response timeout. Please check your connection.");
    } catch (e) {
      _showError("Error: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _scrollToBottom();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _messages.insert(0, ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Chatbot'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: message.isUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          Text(
            message.isUser ? 'You' : 'Bot',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isError 
                ? Colors.red[100]
                : message.isUser 
                  ? Colors.teal[100] 
                  : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(message.isUser ? 12 : 0),
                bottomRight: Radius.circular(message.isUser ? 0 : 12),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isError ? Colors.red[900] : null,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}