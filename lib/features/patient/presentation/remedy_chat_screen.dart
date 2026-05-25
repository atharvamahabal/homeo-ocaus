import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class RemedyChatScreen extends ConsumerStatefulWidget {
  const RemedyChatScreen({super.key});

  @override
  ConsumerState<RemedyChatScreen> createState() => _RemedyChatScreenState();
}

class _RemedyChatScreenState extends ConsumerState<RemedyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'text': 'Hello! I am your Homeo AI assistant. Ask me anything about symptoms or remedies from the Materia Medica.'
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Use your local IP address here (not localhost if running on physical device)
      final response = await Dio().post(
        'http://192.168.68.104:8000/chat',
        data: {'message': text},
      );

      setState(() {
        _messages.add({
          'role': 'bot',
          'text': response.data['reply'] ?? 'Sorry, I could not understand that.'
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': 'Error: Could not connect to the AI server. Please make sure the backend is running.'
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remedy AI Chatbot'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFDCEDC8) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? const Color(0xFF1B5E20) : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Describe your symptoms...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1B5E20)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
