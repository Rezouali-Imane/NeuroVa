import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'screens/ai_chat_screen.dart';
import '../auth/state/auth_notifier.dart';

class AIPage extends ConsumerWidget {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 64, color: Colors.blue.shade300),
            const SizedBox(height: 16),
            const Text(
              'Neurova AI Assistant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Chat with your personal AI tutor to get instant answers, study plans, and personalized learning recommendations.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _startChat(context, ref),
              child: const Text('Start Chatting'),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    final aiService = ref.read(aiServiceProvider);

    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    // Extract userId from JWT token
    String userId = 'user';
    if (authState.token != null) {
      try {
        final parts = authState.token!.split('.');
        if (parts.length == 3) {
          // Decode JWT payload
          final String decoded = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final Map<String, dynamic> payload = jsonDecode(decoded);
          userId = payload['userid'] ?? payload['sub'] ?? 'user';
        }
      } catch (e) {
        userId = 'user';
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatScreen(
          userId: userId,
          aiService: aiService,
        ),
      ),
    );
  }
}
