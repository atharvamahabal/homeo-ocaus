import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/services/settings_provider.dart';

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

  // Repertory Mode state
  bool _isRepertoryMode = false;
  final List<String> _symptoms = [];
  final TextEditingController _symptomController = TextEditingController();

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

  Future<void> _sendMessage({List<String>? symptoms}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && (symptoms == null || symptoms.isEmpty)) return;

    final displayMessage = symptoms != null 
        ? "Repertorizing symptoms: ${symptoms.join(', ')}"
        : text;

    setState(() {
      _messages.add({'role': 'user', 'text': displayMessage});
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final backendIp = ref.read(settingsProvider).backendIp;
      // Use your local IP address from settings
      final response = await Dio().post(
        'http://$backendIp:8000/chat',
        data: {
          'message': text,
          'symptoms': symptoms ?? [],
        },
      );

      setState(() {
        _messages.add({
          'role': 'bot',
          'text': response.data['reply'] ?? 'Sorry, I could not understand that.'
        });
        if (symptoms != null) {
          _symptoms.clear();
          _isRepertoryMode = false;
        }
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

  void _addSymptom() {
    final symptom = _symptomController.text.trim();
    if (symptom.isNotEmpty && _symptoms.length < 5) {
      setState(() {
        _symptoms.add(symptom);
        _symptomController.clear();
      });
    }
  }

  void _showSettingsDialog() {
    final currentIp = ref.read(settingsProvider).backendIp;
    final controller = TextEditingController(text: currentIp);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your PC\'s IPv4 address to connect to the AI server.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Backend IP Address',
                hintText: 'e.g. 192.168.1.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = controller.text.trim();
              if (newIp.isNotEmpty) {
                ref.read(settingsProvider.notifier).updateIp(newIp);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('IP updated to $newIp')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backendIp = ref.watch(settingsProvider).backendIp;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remedy AI Chatbot'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Connection Settings',
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: Icon(_isRepertoryMode ? Icons.chat : Icons.menu_book),
            tooltip: _isRepertoryMode ? 'Switch to Chat' : 'Classical Repertory Mode',
            onPressed: () {
              setState(() {
                _isRepertoryMode = !_isRepertoryMode;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isRepertoryMode)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF1F8E9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REPERTORY MODE (Enter 3-5 Symptoms)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _symptoms.map((s) => Chip(
                      label: Text(s),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() => _symptoms.remove(s));
                      },
                      backgroundColor: const Color(0xFFDCEDC8),
                    )).toList(),
                  ),
                  if (_symptoms.length < 5)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _symptomController,
                            decoration: const InputDecoration(
                              hintText: 'Enter a single symptom/rubric...',
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addSymptom(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
                          onPressed: _addSymptom,
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _symptoms.length >= 3 
                        ? () => _sendMessage(symptoms: _symptoms)
                        : null,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(_symptoms.length < 3 
                        ? 'Add ${3 - _symptoms.length} more symptoms' 
                        : 'REPERTORIZE NOW'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        fontSize: 16,
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
          if (!_isRepertoryMode)
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
