import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = Colors.white.withValues(alpha: 0.4);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: SvgPicture.asset(
                    'lib/features/onboarding/assets/fleche2.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Colors.white70,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text(
                    "Back to login",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
              ),

              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        const Text(
                          "NEUROVA",
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: -30,
                          top: -25,
                          child: SvgPicture.asset(
                            'lib/features/onboarding/assets/logo.svg',
                            width: 51,
                            height: 39,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: EntryReveal(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),

                          const Text(
                            "Reset",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 54,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              height: 0.95,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const Text(
                            "Password",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 54,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              height: 0.95,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: "New Password",
                                    labelStyle: TextStyle(color: hintColor),
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 16,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SvgPicture.asset(
                                        'lib/features/onboarding/assets/Icon3.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white70,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: SvgPicture.asset(
                                        'lib/features/onboarding/assets/Icon4.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white70,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return "Password is required";
                                    }
                                    if (v.length < 6) {
                                      return "Minimum 6 characters";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 10),

                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: "Confirm Password",
                                    labelStyle: TextStyle(color: hintColor),
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 16,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SvgPicture.asset(
                                        'lib/features/onboarding/assets/Icon3.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white70,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: SvgPicture.asset(
                                        'lib/features/onboarding/assets/Icon4.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white70,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirm = !_obscureConfirm;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return "Confirm your password";
                                    }
                                    if (v != _passwordController.text) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            height: 67.99,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  188,
                                  241,
                                  224,
                                  228,
                                ),
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Confirm",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
