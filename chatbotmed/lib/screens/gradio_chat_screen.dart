import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GradioChatScreen extends StatefulWidget {
  final String gradioUrl;
  
  const GradioChatScreen({super.key, required this.gradioUrl});

  @override
  State<GradioChatScreen> createState() => _GradioChatScreenState();
}

class _GradioChatScreenState extends State<GradioChatScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.gradioUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Medical Assistant"),
        backgroundColor: Colors.teal, // Match your theme
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}