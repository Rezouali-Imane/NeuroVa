import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import '../auth/state/auth_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: ProfileViewShell(
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              left: -80,
              top: -128,
              child: Opacity(
                opacity: 0.12,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x35A2ADD0), Color(0x1FB284BE), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -80,
              top: 380,
              child: Opacity(
                opacity: 0.07,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x28F8B878), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              color: Color(0x72FFFFFF),
                              fontFamily: 'Syne',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Neurova',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Syne',
                              fontSize: 39,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/profile', extra: authState.isverified),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0x1AB284BE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x55B284BE)),
                          ),
                          child: const Icon(Icons.settings, color: Color(0xFFB284BE), size: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!authState.isverified)
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8B878).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.info_outline, color: Color(0xFFF8B878), size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email Not Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Verify your email to unlock all features',
                                      style: TextStyle(
                                        color: Color(0x82FFFFFF),
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'All features unlocked! Start your journey.',
                                      style: TextStyle(
                                        color: Color(0x82FFFFFF),
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Quick Actions
                  Text(
                    'QUICK ACCESS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontFamily: 'Syne',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      _buildQuickAccessButton('📚 Focus Sessions', () {}),
                      const SizedBox(height: 12),
                      _buildQuickAccessButton('✅ Tasks', () {}),
                      const SizedBox(height: 12),
                      _buildQuickAccessButton('🤖 AI Assistant', () {}),
                      const SizedBox(height: 12),
                      _buildQuickAccessButton('⚙️ Settings', () => context.push('/profile', extra: authState.isverified)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UnifiedBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onNavItemTapped: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildQuickAccessButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.arrow_forward, color: Color(0x82FFFFFF), size: 18),
          ],
        ),
      ),
    );
  }
