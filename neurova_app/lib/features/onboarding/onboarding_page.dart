import 'package:flutter/material.dart';
import 'onboarding1.dart';
import 'onboarding2.dart';
import 'onboarding3.dart';
import 'onboarding4.dart';
import '../auth/signup_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;

  void _goNextPage() {
    if (_currentPage < 3) {
      setState(() {
        _currentPage += 1;
      });
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const Onboarding1();
      case 1:
        return const Onboarding2();
      case 2:
        return const Onboarding3();
      case 3:
      default:
        return const Onboarding4();
    }
  }

  void _goGetStarted() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  Widget _buildSkipButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 16),
        child: Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: _goGetStarted,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              foregroundColor: Colors.white.withValues(alpha: 0.9),
              backgroundColor: Colors.black.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentPage;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          opacity: isActive ? 1.0 : 0.85,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.30),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButton() {
    if (_currentPage < 3) {
      Color backgroundColor = const Color(0xFFECEBBD);
      if (_currentPage == 1) {
        backgroundColor = const Color(0xFFD2C7F2);
      } else if (_currentPage == 2) {
        backgroundColor = const Color(0xFFB284BE);
      }

      return SizedBox(
        width: 63.99,
        height: 63.99,
        child: ElevatedButton(
          onPressed: _goNextPage,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: backgroundColor,
            padding: EdgeInsets.zero,
            elevation: 0,
          ),
          child: const Icon(
            Icons.arrow_forward_outlined,
            color: Colors.black,
            size: 28,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _goGetStarted,
      child: Container(
        width: 174,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8B878), Color(0xFFF5576C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'get started',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 520),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentPage),
              child: _buildPage(_currentPage),
            ),
          ),
          if (_currentPage < 3) _buildSkipButton(),
          if (_currentPage < 3)
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                ignoring: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBottomButton(),
                    const SizedBox(height: 20),
                    _buildDotsIndicator(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
