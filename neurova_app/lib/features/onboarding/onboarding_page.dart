import 'dart:ui';

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
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
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
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: 4,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final page = _pageController.hasClients &&
                          _pageController.page != null
                      ? _pageController.page!
                      : _pageController.initialPage.toDouble();

                  final delta = page - index;
                  final absDelta = delta.abs().clamp(0.0, 1.0);
                  final scale = (1.0 - (absDelta * 0.07)).clamp(0.93, 1.0).toDouble();
                  final opacity = (1.0 - absDelta).clamp(0.0, 1.0).toDouble();
                  final translateX =
                      delta * MediaQuery.of(context).size.width * (delta > 0 ? 1.0 : 0.25);
                  final blur = absDelta * 3.0;

                  return Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(translateX, 0),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: blur,
                            sigmaY: blur,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: _buildPage(index),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBottomButton(),
                  if (_currentPage < 3) const SizedBox(height: 20),
                  if (_currentPage < 3) _buildDotsIndicator(),
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
