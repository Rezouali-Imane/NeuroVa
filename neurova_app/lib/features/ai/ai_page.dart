import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/ai_chat_screen.dart';
import '../auth/state/auth_notifier.dart';
import '../../shared/theme/app_theme.dart' show AppColors, AppTypography;

class AIPage extends ConsumerWidget {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF090816), Color(0xFF0E0C1F), Color(0xFF0A0918)],
                  ),
                  border: Border.all(color: AppColors.glassBorderLight),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC8B8E8), Color(0xFFA2ADD0)],
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: SvgPicture.asset(
                            'lib/features/onboarding/assets/logo.svg',
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Neurova AI',
                              style: AppTypography.title1.copyWith(color: AppColors.white),
                            ),
                            Text(
                              'Built for study, focus, and planning',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'How may I help you today?',
                      style: AppTypography.headline1.copyWith(
                        color: AppColors.white,
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Open the AI chat to generate study plans, review documents, and get personalized support.',
                      style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => _startChat(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC8B8E8), Color(0xFFA2ADD0)],
                            ),
                          ),
                          child: Text(
                            'Start Chatting',
                            textAlign: TextAlign.center,
                            style: AppTypography.body1.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
