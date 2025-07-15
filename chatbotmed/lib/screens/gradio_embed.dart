import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; 

class GradioEmbedScreen extends StatefulWidget {
  final String gradioUrl; // Pass your Gradio URL here

  const GradioEmbedScreen({super.key, required this.gradioUrl});

  @override
  State<GradioEmbedScreen> createState() => _GradioEmbedScreenState();
}

class _GradioEmbedScreenState extends State<GradioEmbedScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.gradioUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical AI Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
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